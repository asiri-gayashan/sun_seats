import 'dart:math' as math;

class LatLngNode {
  final double lat;
  final double lng;
  LatLngNode(this.lat, this.lng);
}

class SegmentShade {
  final LatLngNode pt1;
  final LatLngNode pt2;
  final bool isSunOnRight;
  final bool isNoSun;

  SegmentShade({
    required this.pt1,
    required this.pt2,
    required this.isSunOnRight,
    this.isNoSun = false,
  });
}

class ShadeResult {
  final bool isLeftShady;
  final int shadyPercentage;
  final double sunLeftPercentage;
  final double sunRightPercentage;
  final double noSunPercentage;
  final List<SegmentShade> segments;

  ShadeResult({
    required this.isLeftShady,
    required this.shadyPercentage,
    required this.sunLeftPercentage,
    required this.sunRightPercentage,
    required this.noSunPercentage,
    required this.segments,
  });
}

class CalculationEngine {
  /// Decodes Google Maps Encoded Polyline algorithm into coordinate nodes
  static List<LatLngNode> decodePolyline(String encoded) {
    List<LatLngNode> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    if (encoded.isEmpty) return poly;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLngNode((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }

  /// Re-samples a polyline into N evenly spaced segments
  static List<LatLngNode> samplePoints(
    List<LatLngNode> points, {
    int numPoints = 100,
  }) {
    if (points.isEmpty) return [];
    if (points.length <= 2) return points;

    if (points.length >= numPoints) {
      // index-based even sampling is more reliable for short polylines
      return List.generate(numPoints, (i) {
        int idx = (i * (points.length - 1) ~/ (numPoints - 1)).clamp(0, points.length - 1);
        return points[idx];
      });
    }

    double totalDist = 0;
    List<double> cumulativeDist = [0.0];
    for (int i = 0; i < points.length - 1; i++) {
      double d = _haversine(points[i], points[i + 1]);
      totalDist += d;
      cumulativeDist.add(totalDist);
    }

    if (totalDist == 0) return [points.first, points.last];

    double segmentLength = totalDist / (numPoints - 1);
    List<LatLngNode> sampled = [points.first];

    int currIndex = 0;
    for (int i = 1; i < numPoints - 1; i++) {
      double targetDist = i * segmentLength;
      while (currIndex < cumulativeDist.length - 2 &&
          cumulativeDist[currIndex + 1] < targetDist) {
        currIndex++;
      }

      double distBetween =
          cumulativeDist[currIndex + 1] - cumulativeDist[currIndex];
      double fraction = distBetween <= 0
          ? 0
          : ((targetDist - cumulativeDist[currIndex]) / distBetween).clamp(0.0, 1.0);

      double tLat =
          points[currIndex].lat +
          fraction * (points[currIndex + 1].lat - points[currIndex].lat);
      double tLng =
          points[currIndex].lng +
          fraction * (points[currIndex + 1].lng - points[currIndex].lng);
      sampled.add(LatLngNode(tLat, tLng));
    }

    sampled.add(points.last);
    return sampled;
  }

  /// Calculates bearing from pt1 to pt2 in degrees (0 = North, 90 = East)
  static double _calculateBearing(LatLngNode pt1, LatLngNode pt2) {
    double lat1 = _toRadians(pt1.lat);
    double lng1 = _toRadians(pt1.lng);
    double lat2 = _toRadians(pt2.lat);
    double lng2 = _toRadians(pt2.lng);

    double dLon = lng2 - lng1;

    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    bearing = _toDegrees(bearing);
    return (bearing + 360.0) % 360.0;
  }

  /// Converts decimal degrees to radians
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Converts radians to decimal degrees
  static double _toDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// Haversine distance in KM
  static double _haversine(LatLngNode pt1, LatLngNode pt2) {
    const double R = 6371.0;
    double dLat = _toRadians(pt2.lat - pt1.lat);
    double dLon = _toRadians(pt2.lng - pt1.lng);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(pt1.lat)) *
            math.cos(_toRadians(pt2.lat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.asin(math.sqrt(a));
    return R * c;
  }

  /// Calculates which side is shadiest
  static ShadeResult calculateShade(
    List<LatLngNode> path,
    DateTime journeyTime, [
    int utcOffsetMinutes = 330,
  ]) {
    // Create sampled points along path
    final sampled = samplePoints(path, numPoints: 100);

    double speedKmH = 40.0;
    double distSoFar = 0.0;

    double leftDist = 0.0;
    double rightDist = 0.0;
    double noSunDist = 0.0;

    for (int i = 0; i < sampled.length - 1; i++) {
      LatLngNode pt1 = sampled[i];
      LatLngNode pt2 = sampled[i + 1];

      double dist = _haversine(pt1, pt2);
      double hoursElapsed = distSoFar / speedKmH;
      DateTime pointTime = journeyTime.add(
        Duration(minutes: (hoursElapsed * 60).round()),
      );

      double bearing = _calculateBearing(pt1, pt2);

      // Calculate sun azimuth position
      Map<String, double> sunPos = _calculateSunPosition(pointTime, pt1.lat, pt1.lng, utcOffsetMinutes);
      double sunAzimuth = sunPos['azimuth']!;
      double altitude = sunPos['altitude']!;

      if (altitude < 0) {
        noSunDist += dist;
      } else {
        // Compute angle diff: bearing -> sunAzimuth clockwise
        double diff = (sunAzimuth - bearing + 360.0) % 360.0;

        // if diff is between 0 and 180, sun is on the RIGHT side.
        if (diff > 0 && diff < 180) {
          rightDist += dist;
        } else {
          leftDist += dist;
        }
      }

      distSoFar += dist;
    }

    double totalDist = leftDist + rightDist + noSunDist;
    if (totalDist == 0) totalDist = 1;

    double leftPct = leftDist / totalDist;
    double rightPct = rightDist / totalDist;
    double noSunPct = noSunDist / totalDist;

    // The SHADY side is the OPPOSITE of where the sun is hitting.
    // So if rightDist > leftDist, the sun is mostly hitting the right.
    // Ergo, the left side is shady!
    bool isLeftShady = rightDist >= leftDist;
    int percentage = ((isLeftShady ? rightDist : leftDist) / totalDist * 100).round();
    if (noSunPct > 0.99) percentage = 100;

    // Generate segment shades for the actual path to render uncompressed on map
    List<SegmentShade> segments = [];
    distSoFar = 0.0;
    for (int i = 0; i < path.length - 1; i++) {
      LatLngNode p1 = path[i];
      LatLngNode p2 = path[i + 1];

      double dist = _haversine(p1, p2);
      double hoursElapsed = distSoFar / speedKmH;
      DateTime pointTime = journeyTime.add(
        Duration(minutes: (hoursElapsed * 60).round()),
      );

      double b = _calculateBearing(p1, p2);
      Map<String, double> pos = _calculateSunPosition(pointTime, p1.lat, p1.lng, utcOffsetMinutes);
      
      bool sunOnRight = false;
      bool noSun = false;
      if (pos['altitude']! >= 0) {
        double d = (pos['azimuth']! - b + 360.0) % 360.0;
        sunOnRight = (d > 0 && d < 180);
      } else {
        noSun = true;
      }

      segments.add(SegmentShade(pt1: p1, pt2: p2, isSunOnRight: sunOnRight, isNoSun: noSun));
      distSoFar += dist;
    }

    return ShadeResult(
      isLeftShady: isLeftShady,
      shadyPercentage: percentage,
      sunLeftPercentage: leftPct,
      sunRightPercentage: rightPct,
      noSunPercentage: noSunPct,
      segments: segments,
    );
  }

  /// Returns { 'azimuth': double, 'altitude': double }
  static Map<String, double> _calculateSunPosition(
    DateTime dateTime,
    double latitude,
    double longitude,
    int utcOffsetMinutes,
  ) {
    // 1. Subtract the UTC offset effectively.
    // But since `dateTime` was instantiated locally, we want the literal absolute UTC time at that moment.
    // `dateTime.toUtc()` handles it if system time is used, but we assume it's provided as local time 
    // and we forcefully interpret it with the given offset.
    // Correct way: If dateTime is "08:00 AM local" with offset +330, then UTC is 02:30 AM
    final DateTime utcTime = dateTime.isUtc ? dateTime : dateTime.subtract(
      Duration(minutes: utcOffsetMinutes),
    );

    // Calculate Julian Day Number exactly
    int y = utcTime.year;
    int m = utcTime.month;
    int d = utcTime.day;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    int A = y ~/ 100;
    int B = 2 - A + A ~/ 4;
    // Accurate Julian Date including fractional day
    double jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d + B - 1524.5 +
        (utcTime.hour + utcTime.minute / 60.0 + utcTime.second / 3600.0) / 24.0;

    // Calculate T (Julian Centuries from J2000)
    double T = (jd - 2451545.0) / 36525.0;

    // Calculate sun's mean longitude (degrees)
    double l0 = 280.46646 + (36000.76983 * T) + (0.0003032 * T * T);
    l0 = l0 % 360.0;
    if (l0 < 0) l0 += 360.0;

    // Calculate sun's mean anomaly (degrees)
    double mAnomaly = 357.52911 + (35999.05029 * T) - (0.0001536 * T * T);
    mAnomaly = mAnomaly % 360.0;
    if (mAnomaly < 0) mAnomaly += 360.0;

    // Convert to radians for calculation
    double mRad = _toRadians(mAnomaly);

    // Calculate sun's equation of center
    double c =
        (1.914602 - (0.004817 * T) - (0.000014 * T * T)) * math.sin(mRad) +
        (0.019993 - (0.000101 * T)) * math.sin(2 * mRad) +
        0.000029 * math.sin(3 * mRad);

    // Calculate sun's true longitude
    double trueLongitude = l0 + c;
    trueLongitude = trueLongitude % 360.0;
    if (trueLongitude < 0) trueLongitude += 360.0;

    // Calculate sun's apparent longitude (simplified)
    double appLongitude = trueLongitude - 0.00569 - 0.00478 * math.sin(_toRadians(125.04 - 1934.136 * T));
    appLongitude = appLongitude % 360.0;
    if (appLongitude < 0) appLongitude += 360.0;

    // Calculate obliquity of ecliptic
    double epsilon0 =
        23.439291 -
        (0.0130042 * T) -
        (0.00000016 * T * T) +
        (0.000000504 * T * T * T);

    // Correct for nutation
    double n = 125.04 - (1934.136 * T);
    double epsilon = epsilon0 + 0.00256 * math.cos(_toRadians(n));

    // Calculate sun's right ascension and declination
    double epsilonRad = _toRadians(epsilon);
    double appLongRad = _toRadians(appLongitude);

    double yVal = math.cos(epsilonRad) * math.sin(appLongRad);
    double xVal = math.cos(appLongRad);
    double rightAscension = math.atan2(yVal, xVal);
    rightAscension = _toDegrees(rightAscension);
    rightAscension = rightAscension % 360.0;
    if (rightAscension < 0) rightAscension += 360.0;

    double declination = math.asin(math.sin(epsilonRad) * math.sin(appLongRad));
    declination = _toDegrees(declination);

    // Accurate GMST formula
    double gmstDeg = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * T * T - T * T * T / 38710000.0;
    gmstDeg = gmstDeg % 360.0;
    if (gmstDeg < 0) gmstDeg += 360.0;

    // Calculate Local Sidereal Time
    double lst = (gmstDeg + longitude) % 360.0;

    // Calculate Hour Angle
    double ha = lst - rightAscension;
    ha = ha % 360.0;
    if (ha > 180) ha = ha - 360.0;

    // Convert to radians for final calculation
    double latRad = _toRadians(latitude);
    double haRad = _toRadians(ha);
    double declinationRad = _toRadians(declination);

    // Calculate altitude
    double sinAlt =
        math.sin(latRad) * math.sin(declinationRad) +
        math.cos(latRad) * math.cos(declinationRad) * math.cos(haRad);
    double altitude = math.asin(sinAlt);

    // Calculate azimuth
    double cosAz =
        (math.sin(declinationRad) - math.sin(altitude) * math.sin(latRad)) /
        (math.cos(altitude) * math.cos(latRad));
    double sinAz =
        -math.sin(haRad) * math.cos(declinationRad) / math.cos(altitude);

    // Azimuth from south, convert to compass azimuth (0=North, 90=East, etc.)
    double azimuth = math.atan2(sinAz, cosAz);
    azimuth = _toDegrees(azimuth);
    azimuth = (azimuth + 180.0) % 360.0; // Convert from south-based to north-based
    if (azimuth < 0) azimuth += 360.0;

    return {
      'azimuth': azimuth,
      'altitude': _toDegrees(altitude),
    };
  }
}
