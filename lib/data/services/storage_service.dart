import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'driver_auth_token';
  static const _driverKey = 'driver_data';

  Future<void> saveToken(String token) async =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() async => _storage.read(key: _tokenKey);
  
  Future<void> saveDriverData(String json) async =>
      _storage.write(key: _driverKey, value: json);

  Future<String?> getDriverData() async => _storage.read(key: _driverKey);
  Future<void> clearAll() async => _storage.deleteAll();

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
