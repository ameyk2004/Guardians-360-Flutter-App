import 'package:flutter/foundation.dart';

class LocationProvider extends ChangeNotifier {
  static final LocationProvider _instance = LocationProvider._internal();

  factory LocationProvider() {
    return _instance;
  }

  LocationProvider._internal();

  static LocationProvider get instance => _instance; // Add this getter

  bool _travelMode = false;

  bool get travelMode => _travelMode;

  void updateTravelMode(bool mode) {
    if (_travelMode != mode) {
      _travelMode = mode;
      notifyListeners(); // Ensure UI updates when travelMode changes
    }
  }
}
