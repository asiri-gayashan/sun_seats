import 'package:flutter/material.dart';

class LocationState extends ChangeNotifier {
  bool _isFetching = false;
  
  bool get isFetching => _isFetching;

  Future<String?> fetchCurrentLocation() async {
    _isFetching = true;
    notifyListeners();

    // Mock API/GPS delay for Phase 3 UI interaction
    await Future.delayed(const Duration(seconds: 1));

    _isFetching = false;
    notifyListeners();

    return 'Colombo, Sri Lanka'; // Mocked location for Phase 3
  }
}
