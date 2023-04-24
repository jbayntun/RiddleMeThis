import 'package:shared_preferences/shared_preferences.dart';

class UserKeyHelper {
  static const String _userKeyPrefKey = 'user_key';

  static Future<String?> getUserKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKeyPrefKey);
  }

  static Future<void> setUserKey(String userKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKeyPrefKey, userKey);
  }

  static Future<void> deleteUserKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_userKeyPrefKey);
  }
}
