import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final _secureStorage = const FlutterSecureStorage();

  // Kunci penyimpanan
  static const _keySessionToken = 'session_token';
  static const _keyLastUser = 'last_logged_in_user';

  // --- SECURE STORAGE (Untuk Sesi / Keamanan) ---[cite: 1]

  Future<void> saveSession(String token) async {
    await _secureStorage.write(key: _keySessionToken, value: token);
  }

  Future<String?> getSession() async {
    return await _secureStorage.read(key: _keySessionToken);
  }

  Future<void> deleteSession() async {
    await _secureStorage.delete(key: _keySessionToken); // Fitur Logout[cite: 1]
  }

  // --- SHARED PREFERENCES (Untuk Data Non-Sensitif Persistent) ---[cite: 1]

  Future<void> saveLastUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastUser, username);
  }

  Future<String?> getLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastUser);
  }
}