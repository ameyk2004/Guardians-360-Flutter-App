import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/base_config.dart';
import '../utils/global_variable.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Ensure initialization happens on the main isolate
  await service.configure(
    iosConfiguration: IosConfiguration(
        autoStart: true, onForeground: onStart, onBackground: onBackground),
    androidConfiguration: AndroidConfiguration(onStart: onStart, isForegroundMode: true),
  );
}

// This function will be executed on foreground
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized(); // Ensure initialization in the main isolate

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
              title: 'Guardians-360', content: 'Tracking location in foreground');
        }
      }

      print("Sending Location in Background");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true
      );

      await _sendLocationToWebhook(position, 27);
      service.invoke('update');
    });
  }
}

// Background task handler
@pragma('vm:entry-point')
Future<bool> onBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

Future<void> _sendLocationToWebhook(Position position, int userID) async {
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

    print("Status code : ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Sent Location to Backend");
      travel_mode = data['travel_mode'];
      print(travel_mode);
    } else {
      print("Failed to send location: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending location: $e");
  }
}
