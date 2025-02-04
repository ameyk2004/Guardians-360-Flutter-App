import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Save access token to SharedPreferences
  Future<void> saveAccessToken(String value) async {
    print('--- saveAccessToken ---');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saving access token: $value');
    await prefs.setString("access_token", value);
    print('Access token saved.');
  }

  Future<void> savedeviceToken(String value) async {
    print('--- savedeviceToken ---');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saving device token: $value');
    await prefs.setString("device_token", value);
    print('device token saved.');
  }

  Future<void> savePublicKey(String value) async {
    print('--- savePublicKey ---');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saving PublicKey : $value');
    await prefs.setString("public_key", value);
    print('public_key saved.');
  }

  // Save user details to SharedPreferences as a JSON string
  Future<void> saveUserDetails(String userData) async {
    print('--- saveUserDetails ---');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(userData);  // Convert the userData to a JSON string
    print('Saving user data: $jsonString');
    await prefs.setString("user_data", jsonString);  // Store the string in SharedPreferences
    print('User data saved.');
  }

  // Get data from SharedPreferences
  Future<String?> getData(String key) async {
    print('--- getData ---');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(key);
    if (data != null) {
    } else {
      print('No data found for key: $key');
    }
    return data;
  }

  // Remove data from SharedPreferences
  Future<void> removeCacheData(String key) async {
    print('--- removeCacheData ---');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Removing data for key: $key');
    await prefs.remove(key);
    print('Data removed for key: $key');
  }
}
