import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnectivityInApp {
  static final InternetConnectivityInApp _instance = InternetConnectivityInApp._internal();

  factory InternetConnectivityInApp() {
    return _instance;
  }

  InternetConnectivityInApp._internal();

  final Connectivity _connectivity = Connectivity();

  void listenToConnectivity(BuildContext context) {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      checkConnectivity(results, context);
    });
  }

  void checkConnectivity(List<ConnectivityResult> results, BuildContext context) {
    if (!context.mounted) return;

    bool isConnected = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);

    if (!isConnected) {
      showSnackbar(context, "No Internet Connection", Colors.red);
    } else {
      showSnackbar(context, "Connected to the Internet", Colors.green);
    }
  }

  void showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
