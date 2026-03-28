import 'package:flutter/material.dart';

class JourneyFormState extends ChangeNotifier {
  String _startLocation = '';
  String _endLocation = '';
  DateTime _journeyDate = DateTime.now();
  TimeOfDay _journeyTime = TimeOfDay.now();
  String _transitMode = 'Bus';
  String _timezone = '(UTC+05:30) Sri Lanka';

  String get startLocation => _startLocation;
  String get endLocation => _endLocation;
  DateTime get journeyDate => _journeyDate;
  TimeOfDay get journeyTime => _journeyTime;
  String get transitMode => _transitMode;
  String get timezone => _timezone;

  void setStartLocation(String val) {
    _startLocation = val;
    notifyListeners();
  }

  void setEndLocation(String val) {
    _endLocation = val;
    notifyListeners();
  }

  void setJourneyDate(DateTime val) {
    _journeyDate = val;
    notifyListeners();
  }

  void setJourneyTime(TimeOfDay val) {
    _journeyTime = val;
    notifyListeners();
  }

  void setTransitMode(String val) {
    _transitMode = val;
    notifyListeners();
  }

  void setTimezone(String val) {
    _timezone = val;
    notifyListeners();
  }

  bool get isValid {
    return _startLocation.trim().isNotEmpty && 
           _endLocation.trim().isNotEmpty && 
           _startLocation.trim().toLowerCase() != _endLocation.trim().toLowerCase();
  }
}
