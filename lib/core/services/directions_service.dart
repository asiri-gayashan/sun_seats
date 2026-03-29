import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteData {
  final String polyline;
  final String summary;
  final String distance;
  final int distanceValue;

  RouteData({
    required this.polyline,
    required this.summary,
    required this.distance,
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
    // Transit modes handling
    String apiMode = mode.toLowerCase() == 'train' ? 'transit' : 'driving';

    // Safety matching for Sri Lankan cities
    final originQuery = Uri.encodeComponent('$origin, Sri Lanka');
    final destQuery = Uri.encodeComponent('$destination, Sri Lanka');

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=$originQuery&destination=$destQuery&mode=$apiMode&alternatives=true&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        List<RouteData> routes = [];
        final routesJson = json['routes'] as List;

        for (int i = 0; i < routesJson.length; i++) {
          final route = routesJson[i];
          final leg = route['legs'][0];
          routes.add(
            RouteData(
              polyline: route['overview_polyline']['points'],
              summary: route['summary'] ?? '',
              distance: leg['distance']['text'] ?? '',
              distanceValue: leg['distance']['value'] ?? 0,
            ),
          );
        }

        if (mode.toLowerCase() == 'bus' || mode.toLowerCase() == 'other') {
          // Sort by shortest distance
          routes.sort((a, b) => a.distanceValue.compareTo(b.distanceValue));
        }

        // Limit to up to 2 routes after sorting
        if (routes.length > 2) {
          routes = routes.sublist(0, 2);
        }

        return routes;
      } else {
        throw 'Google Routing Error: ${json['status']}';
      }
    } else {
      throw 'Failed to connect to directions service';
    }
  }
}
