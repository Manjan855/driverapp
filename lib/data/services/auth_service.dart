import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/driver_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/driver/login',
        data: {'phoneNumber': phoneNumber, 'password': password},
      );

      final token = response.data['token'] as String;
      final driver = DriverModel.fromJson(
        response.data['driver'] ?? response.data,
      );

      await _storage.saveToken(token);

      return AuthResponseModel(token: token, driver: driver);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  String _parseError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'];
      }
      if (e.response?.statusCode == 401) {
        return 'Invalid phone number or password';
      }
      if (e.response?.statusCode == 404) {
        return 'Account not found';
      }
      return 'Something went wrong. Please try again';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your internet';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not reach server. Check your connection';
    }
    return 'Something went wrong. Please try again';
  }
}
