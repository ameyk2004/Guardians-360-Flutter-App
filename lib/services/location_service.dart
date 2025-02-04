import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardians_app/config/base_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/global_variable.dart'; // For encoding data into JSON

class LocationService {
  static Timer? _locationTimer;
  final int userID;

  // ✅ Corrected Notifiers
  ValueNotifier<bool> travelModeNotifier = ValueNotifier(false);

  LocationService({required this.userID});

  Future<Map<String, double?>> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {'latitude': null, 'longitude': null};
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return {'latitude': null, 'longitude': null};
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return {'latitude': position.latitude, 'longitude': position.longitude};
  }

  Future<void> startTracking() async {
    print("Tracking started...");

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print("Location permission denied.");
      return;
    }

    // Start sending location every 2 seconds
    _locationTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await sendLocationToFriend(position);
    });
  }

  Future<void> stopTracking() async {
    _locationTimer?.cancel();
    print("Tracking stopped.");
  }

  Future<void> sendLocationToFriend(Position position) async {
    try {
      final url = Uri.parse('${DevConfig().travelAlertServiceBaseUrl}location/$userID');

      final headers = {'Content-Type': 'application/json'};

      if (travel_mode) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          travel_details["location_details"]['destination']?['latitude'] ?? 0.0,
          travel_details["location_details"]['destination']?['longitude'] ?? 0.0,
        );

        print("\nDistance: $distance");

        // ✅ Correct way to update ValueNotifier
        travel_details['distance_to_destination'] = distance; // Update field
      }

      var body = json.encode({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        if (travel_mode) "travel_details": travel_details,
      });

      print(body);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        travelModeNotifier.value = data['travel_mode']; // ✅ This will notify UI
      } else {
        print("Failed to send location: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending location: $e");
    }
  }
}
