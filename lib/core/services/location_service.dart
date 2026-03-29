import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const String _apiKey =
      'AIzaSyDNaXdGGDljKmK8GaY6AnGMEq131yOlbio'; // Project Maps Key

  static Future<String> getCurrentCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );

    return await _getCityFromCoordinates(position.latitude, position.longitude);
  }

  static Future<String> _getCityFromCoordinates(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK' && (json['results'] as List).isNotEmpty) {
        // Look for locality in address components
        for (var component in json['results'][0]['address_components']) {
          List<dynamic> types = component['types'];
          if (types.contains('locality') ||
              types.contains('administrative_area_level_2')) {
            return component['long_name'];
          }
        }
        // Fallback to formatted address chunk
        String fullAddress = json['results'][0]['formatted_address'];
        return fullAddress.split(',').first;
      }
    }
    throw 'Failed to reverse code coordinates.';
  }
}
