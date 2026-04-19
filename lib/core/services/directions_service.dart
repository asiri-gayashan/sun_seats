import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteData {
  final String mergedPolyline; // single merged encoded string
  final String summary;
  final String distance;
  final String duration;
  final int distanceValue;

  RouteData({
    required this.mergedPolyline,
    required this.summary,
    required this.distance,
    required this.duration,
    required this.distanceValue,
  });
}

class DirectionsService {
  static const String _apiKey = 'AIzaSyDNaXdGGDljKmK8GaY6AnGMEq131yOlbio';

  static Future<List<RouteData>> getRoutePolylines(
    String origin,
    String destination,
    String mode,
  ) async {
    String apiMode = 'driving';
    String extraParams = '';

    if (mode.toLowerCase() == 'train') {
      apiMode = 'transit';
      extraParams =
          '&transit_mode=rail&transit_routing_preference=fewer_transfers';
    } else if (mode.toLowerCase() == 'bus') {
      // Key fix: buses in Sri Lanka work better with driving mode
      // because transit data for LK buses is incomplete in Google Maps
      apiMode = 'driving';
      extraParams = '';
    }

    final originQuery = Uri.encodeComponent('$origin, Sri Lanka');
    final destQuery = Uri.encodeComponent('$destination, Sri Lanka');

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originQuery'
      '&destination=$destQuery'
      '&mode=$apiMode'
      '$extraParams'
      '&alternatives=true'
      '&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw 'Failed to connect to directions service';
    }

    final json = jsonDecode(response.body);

    if (json['status'] != 'OK') {
      throw 'Google Routing Error: ${json['status']} — '
          'Check that both locations are valid Sri Lankan cities.';
    }

    List<RouteData> routes = [];
    final routesJson = json['routes'] as List;

    for (final route in routesJson) {
      final leg = route['legs'][0];

      // ── FIX 1: Use overview_polyline for the full road-snapped route ──
      // This is one single encoded polyline that covers the entire route
      // already road-snapped by Google. Much more accurate than merging steps.
      final String overviewPolyline =
          route['overview_polyline']['points'] as String;

      // ── FIX 2: For transit mode, extract only vehicle (non-walking) steps ──
      // Walking steps go off-road and cause the orange/blue lines to
      // diverge from actual roads.
      String polylineToUse = overviewPolyline;

      if (apiMode == 'transit') {
        polylineToUse = _extractTransitOnlyPolyline(leg['steps']);
        // Fall back to overview if extraction fails
        if (polylineToUse.isEmpty) {
          polylineToUse = overviewPolyline;
        }
      }

      routes.add(
        RouteData(
          mergedPolyline: polylineToUse,
          summary: route['summary'] ?? 'Route',
          distance: leg['distance']['text'] ?? '',
          duration: leg['duration']['text'] ?? '',
          distanceValue: leg['distance']['value'] ?? 0,
        ),
      );
    }

    // Sort bus/other by shortest distance
    if (mode.toLowerCase() == 'bus' || mode.toLowerCase() == 'other') {
      routes.sort((a, b) => a.distanceValue.compareTo(b.distanceValue));
    }

    // Limit to 2 routes
    return routes.length > 2 ? routes.sublist(0, 2) : routes;
  }

  /// For transit routes, merge only the vehicle step polylines (skip walking).
  /// Walking steps are the main cause of off-road segments.
  static String _extractTransitOnlyPolyline(List<dynamic> steps) {
    // Collect all points from vehicle steps only
    List<Map<String, double>> allPoints = [];

    for (final step in steps) {
      final travelMode = step['travel_mode'] as String? ?? '';

      // Skip walking steps — they go off-road
      if (travelMode == 'WALKING') continue;

      final encoded = step['polyline']['points'] as String? ?? '';
      if (encoded.isEmpty) continue;

      final decoded = _decodePolylineToPoints(encoded);
      allPoints.addAll(decoded);
    }

    if (allPoints.isEmpty) return '';

    // Re-encode back to a single polyline string
    return _encodePolyline(allPoints);
  }

  /// Decodes Google encoded polyline to list of {lat, lng} maps
  static List<Map<String, double>> _decodePolylineToPoints(String encoded) {
    List<Map<String, double>> points = [];
    int index = 0;
    int lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add({'lat': lat / 1e5, 'lng': lng / 1e5});
    }
    return points;
  }

  /// Re-encodes a list of points back to Google encoded polyline format
  static String _encodePolyline(List<Map<String, double>> points) {
    StringBuffer result = StringBuffer();

    int prevLat = 0, prevLng = 0;

    for (final point in points) {
      int lat = (point['lat']! * 1e5).round();
      int lng = (point['lng']! * 1e5).round();

      result.write(_encodeValue(lat - prevLat));
      result.write(_encodeValue(lng - prevLng));

      prevLat = lat;
      prevLng = lng;
    }

    return result.toString();
  }

  static String _encodeValue(int value) {
    value = value < 0 ? ~(value << 1) : value << 1;
    StringBuffer chunks = StringBuffer();
    while (value >= 0x20) {
      chunks.writeCharCode(((0x20 | (value & 0x1f)) + 63));
      value >>= 5;
    }
    chunks.writeCharCode(value + 63);
    return chunks.toString();
  }
}