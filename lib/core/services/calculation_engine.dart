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
