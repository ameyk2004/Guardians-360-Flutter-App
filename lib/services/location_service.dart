import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardians_app/config/base_config.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../providers/location_provider.dart';
import '../utils/global_variable.dart'; // For encoding data into JSON


class LocationService {
  static Timer? _locationTimer;
  final int userID;

  LocationService({required this.userID});

  // Get the current location
  Future<Map<String, double?>> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {'latitude': null, 'longitude': null};
    }

    // Check if permission is granted before getting the location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print("Location permission is not granted.");
      return {'latitude': null, 'longitude': null};
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return {'latitude': position.latitude, 'longitude': position.longitude};
  }

  // Start location tracking without requesting permission here
  Future<void> startTracking() async {
    // Check if permission is granted before starting the tracking
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print("Location permission is not granted.");
      return;
    }

    print("Tracking started...");

    // Start sending location every 2 seconds
    _locationTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _sendLocationToWebhook(position); // Send location data to webhook
    });
  }

  // Stop location tracking
  Future<void> stopTracking() async {
    _locationTimer?.cancel();
    print("Tracking stopped.");
  }

  // Send the location data to the webhook
  Future<void> _sendLocationToWebhook(Position position) async {
    try {
      final url = Uri.parse('${DevConfig().travelAlertServiceBaseUrl}location/$userID'); // Replace with actual URL

      final headers = {
        'Content-Type': 'application/json',
      };

      var body = json.encode({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        if (travel_mode) "travel_details": travel_details,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        travel_mode = data['travel_mode'];
        print(travel_mode);
      } else {
        print("Failed to send location: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending location: $e");
    }
  }
}




// Map<String, dynamic> travel_details = {
//   "location_details": {
//     "source": {
//       "latitude": 0,
//       "longitude": 0
//     },
//     "destination": {
//       "latitude": 0,
//       "longitude": 0
//     },
//     "notification_frequency": 0
//   },
//   "vehicle_details": {
//     "mode_of_travel": "",
//     "vehicle_number": ""
//   }
// };
//