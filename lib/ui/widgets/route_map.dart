import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/providers/result_state.dart';
import '../../core/services/calculation_engine.dart';
import '../../core/theme/app_theme.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({super.key});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitRoute();
  }

  static const String _darkMapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#1d2c4d"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8ec3b9"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#1a3646"
          }
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#4b6878"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#304a7d"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#0e1626"
          }
        ]
      }
    ]
    ''';

  void _fitRoute() {
    if (_mapController == null || !mounted) return;
    final state = context.read<ResultState>();
    if (state.status == ResultPanelState.success && state.resultData != null) {
      final points = state.resultData!.routePoints;
      if (points.isEmpty) return;

      double minLat = points.first.lat;
      double maxLat = points.first.lat;
      double minLng = points.first.lng;
      double maxLng = points.first.lng;

      for (var p in points) {
        if (p.lat < minLat) minLat = p.lat;
        if (p.lat > maxLat) maxLat = p.lat;
        if (p.lng < minLng) minLng = p.lng;
        if (p.lng > maxLng) maxLng = p.lng;
      }

      for (var altRoute in state.resultData!.alternateRoutesPoints) {
        for (var point in altRoute) {
          if (point.lat < minLat) minLat = point.lat;
          if (point.lat > maxLat) maxLat = point.lat;
          if (point.lng < minLng) minLng = point.lng;
          if (point.lng > maxLng) maxLng = point.lng;
        }
      }

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50.0, // padding
        ),
      );
    }
  }

  void _openFullscreen(BuildContext context, Set<Polyline> polylines) {
    final state = context.read<ResultState>();
    final data = state.resultData;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Stack(
            children: [
              GoogleMap(
                style: _darkMapStyle,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(7.8731, 80.7718),
                  zoom: 7.0,
                ),
                polylines: polylines,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _fitRouteWithController(controller);
                },
              ),
              if (data != null && !data.isNight)
                Positioned(
                  top: 100,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sun Exposure Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Sun Right: ${data.sunLeftPercentage.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Color(0xFFFFA500),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sun Left: ${data.sunRightPercentage.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No Sun: ${data.noSunPercentage.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _fitRouteWithController(GoogleMapController controller) {
    final state = context.read<ResultState>();
    if (state.status == ResultPanelState.success && state.resultData != null) {
      final points = state.resultData!.routePoints;
      if (points.isEmpty) return;

      double minLat = points.first.lat;
      double maxLat = points.first.lat;
      double minLng = points.first.lng;
      double maxLng = points.first.lng;

      for (var p in points) {
        if (p.lat < minLat) minLat = p.lat;
        if (p.lat > maxLat) maxLat = p.lat;
        if (p.lng < minLng) minLng = p.lng;
        if (p.lng > maxLng) maxLng = p.lng;
      }

      for (var altRoute in state.resultData!.alternateRoutesPoints) {
        for (var point in altRoute) {
          if (point.lat < minLat) minLat = point.lat;
          if (point.lat > maxLat) maxLat = point.lat;
          if (point.lng < minLng) minLng = point.lng;
          if (point.lng > maxLng) maxLng = point.lng;
        }
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            50.0,
          ),
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fitRoute();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ResultState>();

    if (state.status != ResultPanelState.success || state.resultData == null) {
      return const SizedBox.shrink(); // Hide map if no result
    }

    Set<Polyline> polylines = {};

    // Add alternatives if they exist
    for (int i = 0; i < state.resultData!.alternateRoutesPoints.length; i++) {
      final altRoutePoints = state.resultData!.alternateRoutesPoints[i]
          .map((node) => LatLng(node.lat, node.lng))
          .toList();

      polylines.add(
        Polyline(
          polylineId: PolylineId('alternate_$i'),
          points: altRoutePoints,
          color: Colors.blueGrey.withValues(alpha: 0.7),
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

final routePoints = state.resultData!.routePoints
        .map((node) => LatLng(node.lat, node.lng))
        .toList();

    // Draw primary route based on sun hit segments
    final dynamic rawSegments = state.resultData!.routeSegments;
    final List<SegmentShade> segments = rawSegments == null
        ? <SegmentShade>[]
        : List<SegmentShade>.from(rawSegments);

    if ((segments.isEmpty || state.resultData!.isNight) && routePoints.isNotEmpty) {
      // Fallback if night time or segments fail to generate  
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_primary_fallback'),
          points: routePoints,
          color: Colors.blueGrey, // Use a neutral color for night time
          width: 6,
          zIndex: 2,
        ),
      );
    } else {
      List<LatLng> currentPath = [];
      bool? currentSunOnRight;
      int polylineIndex = 0;

      for (var seg in segments) {
        if (currentSunOnRight == null) {
          currentSunOnRight = seg.isSunOnRight;
          currentPath.add(LatLng(seg.pt1.lat, seg.pt1.lng));
        } else if (currentSunOnRight != seg.isSunOnRight) {
          currentPath.add(LatLng(seg.pt1.lat, seg.pt1.lng));

          polylines.add(
            Polyline(
              polylineId: PolylineId('route_primary_$polylineIndex'),
              points: List.from(currentPath),
              color: currentSunOnRight ? Colors.blue : Colors.orange,
              width: 6,
              zIndex: 2,
            ),
          );

          currentPath = [LatLng(seg.pt1.lat, seg.pt1.lng)];
          currentSunOnRight = seg.isSunOnRight;
          polylineIndex++;
        }
        currentPath.add(LatLng(seg.pt2.lat, seg.pt2.lng));
      }

      if (currentPath.isNotEmpty && currentSunOnRight != null) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('route_primary_$polylineIndex'),
            points: currentPath,
            color: currentSunOnRight ? Colors.blue : Colors.orange,
            width: 6,
            zIndex: 2,
          ),
        );
      }
    }

    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.midGray, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            GoogleMap(
              style: _darkMapStyle,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(7.8731, 80.7718), // Center of Sri Lanka
                zoom: 7.0,
              ),
              polylines: polylines,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
            // Floating pill identifying what this is
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.route,
                      color: AppTheme.primaryGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Journey Route',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Fullscreen button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => _openFullscreen(context, polylines),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    color: AppTheme.darkText,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
