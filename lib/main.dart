import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guardians_app/auth_wrapper.dart';
import 'package:guardians_app/firebase_options.dart';
import 'package:guardians_app/screens/adhar_upload_page.dart';
import 'package:guardians_app/screens/friend_pages/contact_page.dart';
import 'package:guardians_app/screens/home_screen.dart';
import 'package:guardians_app/services/device_token_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingHelper().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690), // Your design size
      builder: (_, child) => MaterialApp(
        title: 'Guardians',
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(), // Ensure you're using AuthWrapper as the home widget
      ),
    );
  }
}

