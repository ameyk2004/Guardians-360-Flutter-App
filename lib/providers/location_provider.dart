import 'package:flutter/foundation.dart';
import 'package:guardians_app/utils/global_variable.dart';

class LocationProvider extends ChangeNotifier {
  static final LocationProvider _instance = LocationProvider._internal();

  factory LocationProvider() {
    return _instance;
  }

  LocationProvider._internal();

  static LocationProvider get instance => _instance; // Add this getter

  bool _travelMode = false;

  bool get travelMode => _travelMode;

  void updateTravelMode(bool newMode) {

    print("Received NewMode : $newMode");
    print("Previous Travel Mode : $travelMode");
    if (_travelMode != newMode) {
      _travelMode = newMode;
      travel_mode = _travelMode;
      notifyListeners(); // Notify all listening widgets


      print("Travel Mode Updated to : $_travelMode");
    }
  }
}
