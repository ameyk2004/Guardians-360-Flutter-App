import 'package:flutter/material.dart';
import 'package:guardians_app/utils/global_variable.dart';

class LocationProvider extends ChangeNotifier {
  bool _travelMode = travel_mode;

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
