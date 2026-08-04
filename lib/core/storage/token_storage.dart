import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Equivalente a localStorage.getItem/setItem/removeItem('token' / 'currentUser')
/// pero cifrado en el dispositivo (Keychain en iOS, Keystore en Android).
class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user_json';

  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveUserJson(String userJson) => _storage.write(key: _userKey, value: userJson);
  Future<String?> getUserJson() => _storage.read(key: _userKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
