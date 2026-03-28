import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationState extends ChangeNotifier {
  bool _isFetching = false;
  
  bool get isFetching => _isFetching;

  Future<String?> fetchCurrentLocation() async {
    _isFetching = true;
    notifyListeners();

    try {
      final loc = await LocationService.getCurrentCity();
      _isFetching = false;
      notifyListeners();
      return loc;
    } catch (e) {
      _isFetching = false;
      notifyListeners();
      return null;
    }
  }
}
