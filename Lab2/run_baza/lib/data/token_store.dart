import 'package:shared_preferences/shared_preferences.dart';

/// Only the replaceable access token is stored locally, never a password.
class TokenStore {
  static const key = 'auth_token';

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(key);

  Future<void> save(String token) async {
    if (token.trim().isEmpty) {
      throw const FormatException('The server returned an empty token.');
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(key, token)) {
      throw const TokenStorageException();
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove(key)) throw const TokenStorageException();
  }
}

class TokenStorageException implements Exception {
  const TokenStorageException();
}
