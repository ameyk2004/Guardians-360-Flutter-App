import 'dart:async';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:guardians_app/config/base_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../utils/global_variable.dart';
import 'cache_service.dart';

Future<void> initService() async {
  print("Reached");
  final service = FlutterBackgroundService();
  await service.configure(iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration
        (
          onStart: onStart,
          isForegroundMode: true,
          autoStart: true
      )
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  String? userDataString = await CacheService().getData("user_data");

  var userData;

  if (userDataString == null || userDataString.isEmpty) {
    userDataString = '{}';
  }
  else{
    print("\n\n");
    userData = jsonDecode(jsonDecode(userDataString));
    print("User ID FETCHED IN BACKGROUND : ${userData['userID']}");
  }


  if (service is AndroidServiceInstance){
    // Making the app run in foreground mode so that app is not killed
    service.setAsForegroundService();

    service.on('setAsForeground').listen((event){
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event){
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event){
    service.stopSelf();
  });

  // Changed interval from 1s → 5s to prevent rate limiting & battery drain
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    Position? position = await getCurrentLocation();
    if (position != null) {
      print("User Location: Lat: ${position.latitude}, Lng: ${position.longitude}");

      await _sendLocationToFriend(position, int.parse(userData['userID'] )?? 0);
    }
  });

}

Future<Position?> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permission denied");
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Location permission permanently denied");
    return null;
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<void> _sendLocationToWebhook(Position position, int userID) async {
  try {
    final url = Uri.parse('${DevConfig().travelAlertServiceBaseUrl}location/${userID}');
    final headers = {
      'Content-Type': 'application/json',
    };
    var body = json.encode({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String()
    });
    final response = await http.post(url, headers: headers, body: body);
    print("Status code : ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Sent Location to Backend");
      print("Data : $data");
    } else {
      print("Failed to send location: ${response.statusCode}");
    }
  }
  catch (e) {
    print("Error sending location: $e");
  }
}

Future<void> _sendLocationToFriend(Position position, int userID) async {
  try {
    final url = Uri.parse('${DevConfig().travelAlertServiceBaseUrl}location/$userID'); // Replace with actual URL

    final headers = {
      'Content-Type': 'application/json',
    };

    if(travel_mode){
      double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          travel_details["location_details"]['destination']['latitude'],
          travel_details["location_details"]['destination']['longitude']
      );

      print("\ndistance : $distance");
      travel_details['distance_to_destination'] = distance;
    }

    var body = json.encode({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
      if (travel_mode) "travel_details": travel_details,
    });

    // print("Sending location: $body");
    final response = await http.post(url, headers: headers, body: body);
    print("Status code : ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      travel_mode = data['travel_mode'];

      LocationProvider.instance.updateTravelMode(travel_mode);

      print("Provider Updated");
      print("Sent Location to Backend");
      print("Data : $data");

    } else {
      print("Failed to send location: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending location: $e");
  }
}