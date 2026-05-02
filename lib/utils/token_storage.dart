// utils/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<void> saveToken(String token, String role, String codeExpl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("role", role);
    await prefs.setString("codeExpl", codeExpl);
  }

  static Future<Map<String, String?>> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "token": prefs.getString("token"),
      "role": prefs.getString("role"),
      "codeExpl": prefs.getString("codeExpl"),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
