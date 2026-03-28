import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteData {
  final String polyline;
  final String summary;
  final String distance;

  RouteData({required this.polyline, required this.summary, required this.distance});
}

class DirectionsService {
  static const String _apiKey = 'AIzaSyDNaXdGGDljKmK8GaY6AnGMEq131yOlbio';

  static Future<RouteData> getRoutePolyline(String origin, String destination, String mode) async {
    // Transit modes handling
    String apiMode = mode.toLowerCase() == 'train' ? 'transit' : 'driving';
    
    // Safety matching for Sri Lankan cities
    final originQuery = Uri.encodeComponent('$origin, Sri Lanka');
    final destQuery = Uri.encodeComponent('$destination, Sri Lanka');

    final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=$originQuery&destination=$destQuery&mode=$apiMode&alternatives=false&key=$_apiKey');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        final route = json['routes'][0];
        final leg = route['legs'][0];
        return RouteData(
          polyline: route['overview_polyline']['points'],
          summary: route['summary'] ?? '',
          distance: leg['distance']['text'] ?? '',
        );
      } else {
        throw 'Google Routing Error: ${json['status']}';
      }
    } else {
      throw 'Failed to connect to directions service';
    }
  }
}
