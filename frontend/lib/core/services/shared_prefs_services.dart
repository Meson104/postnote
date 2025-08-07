import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsServices {
  Future<void> setToken(String token) async {
    // Implementation to save the token in shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    // Implementation to save the token in shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.getString('x-auth-token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-auth-token'); // Removes the token
  }
}
