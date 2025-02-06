import 'dart:async';
import 'package:guardians_app/services/location_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundTasks {
  /// Initializes and runs background tasks continuously.
  static Future<void> runContinuously() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true, // Keeps service alive
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

  /// Function that runs continuously in the background
  static void onStart(ServiceInstance service) {
    Timer.periodic(Duration(seconds: 10), (timer) async {

    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  /// Webhook function (Modify this based on your existing webhook code)
  static Future<void> sendDataToWebhook() async {
    try {
      var response = await http.post(
        Uri.parse("https://your-webhook-url.com/data"),
        headers: {"Content-Type": "application/json"},
        body: '{"message": "Background task running!"}',
      );

      print("Webhook response: ${response.statusCode}");
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  /// Required for iOS.
  static bool onIosBackground(ServiceInstance service) {
    return true;
  }
}
