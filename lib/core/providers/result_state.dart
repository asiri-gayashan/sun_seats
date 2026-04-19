import 'package:flutter/material.dart';
import '../services/calculation_engine.dart'; // To get LatLngNode

enum ResultPanelState { empty, loading, success, error }

class MockResultData {
  final bool isLeftShady;
  final int shadyPercentage;
  final double sunLeftPercentage;
  final double sunRightPercentage;
  final double noSunPercentage;
  final String journeySummary;
  final String explanation;
  final bool isNight;
  final List<LatLngNode> routePoints;
  final List<SegmentShade> routeSegments;
  final List<List<LatLngNode>> alternateRoutesPoints;

  MockResultData({
    required this.isLeftShady,
    required this.shadyPercentage,
    required this.sunLeftPercentage,
    required this.sunRightPercentage,
    required this.noSunPercentage,
    required this.journeySummary,
    required this.explanation,
    this.isNight = false,
    required this.routePoints,
    required this.routeSegments,
    this.alternateRoutesPoints = const [],
  });
}

class ResultState extends ChangeNotifier {
  ResultPanelState _status = ResultPanelState.empty;
  String? _errorMessage;
  MockResultData? _resultData;

  ResultPanelState get status => _status;
  String? get errorMessage => _errorMessage;
  MockResultData? get resultData => _resultData;

  void reset() {
    _status = ResultPanelState.empty;
    _errorMessage = null;
    _resultData = null;
    notifyListeners();
  }

  void startLoading() {
    _status = ResultPanelState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _status = ResultPanelState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void setSuccess(MockResultData data) {
    _status = ResultPanelState.success;
    _resultData = data;
    _errorMessage = null;
    notifyListeners();
  }
}
