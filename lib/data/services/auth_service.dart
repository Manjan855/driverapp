
import '../models/driver_model.dart';
import '../models/auth_response_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  // Temporary mock — replace with real Dio call once backend is ready
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock response matching your proposal's driver model
    return AuthResponseModel(
      token: 'mock_driver_token_12345',
      driver: DriverModel(
        id: 1,
        name: 'Ram Bahadur',
        phoneNumber: phoneNumber,
        licenseNumber: 'KA-2345',
        status: 'active',
      ),
    );
  }

  Future<void> logout() async {
    // Real: invalidate token on backend
  }
}
