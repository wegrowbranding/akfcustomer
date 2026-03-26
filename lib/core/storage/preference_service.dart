import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String keyToken = 'auth_token';
  static const String keyUserData = 'user_data';

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  static Future<void> saveUserData(String userDataJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserData, userDataJson);
  }

  static Future<String?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserData);
  }

  static Future<void> clearAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyUserData);
  }
}
