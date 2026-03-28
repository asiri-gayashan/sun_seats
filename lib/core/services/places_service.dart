import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String _apiKey = 'AIzaSyDNaXdGGDljKmK8GaY6AnGMEq131yOlbio'; // Project Maps Key

  static Future<List<String>> getPlaceSuggestions(String query) async {
    if (query.trim().length < 2) return [];

    try {
      final encodedQuery = Uri.encodeComponent(query);
      // Restrict results to Sri Lanka (country code: lk)
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$encodedQuery&components=country:lk&key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          return (json['predictions'] as List)
              .map((p) => p['description'] as String)
              .toList();
        }
      }
    } catch (e) {
      // Silently fail autocomplete on error
    }
    return [];
  }
}
