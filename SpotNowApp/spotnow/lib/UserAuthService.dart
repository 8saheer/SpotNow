import 'package:shared_preferences/shared_preferences.dart';

class UserAuthService {
  static const _loggedInKey = 'is_logged_in';
  static const _userIdKey = 'user_id';

  // Call this after successful login
  static Future<void> setLoggedIn(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_userIdKey);
  }
}
