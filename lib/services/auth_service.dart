import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthService {
  static Future<void> logout() async {
    try {
      // Call backend logout (destroy PHP session)
      await ApiClient.post('/logout', {});
    } catch (_) {
      // Ignore API failure, local logout must still happen
    }

    final prefs = await SharedPreferences.getInstance();

    // Clear everything auth-related
    await prefs.clear();
  }
}
