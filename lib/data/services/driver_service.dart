import 'package:dio/dio.dart';
import '../models/driver_model.dart';
import 'api_client.dart';

class DriverService {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/drivers/:id
  Future<DriverModel> getProfile(int driverId) async {
    try {
      final response = await _apiClient.dio.get('/drivers/$driverId');
      return DriverModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load profile');
    }
  }

  /// PUT /api/drivers/:id
  Future<DriverModel> updateProfile({
    required int driverId,
    required String name,
    String? email,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/drivers/$driverId',
        data: {
          'driverName': name,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
      return DriverModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to update profile',
      );
    }
  }

  /// PUT /api/drivers/:id/password  (confirm exact endpoint with teammate)
  Future<void> changePassword({
    required int driverId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.put(
        '/drivers/$driverId/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to change password';
      throw Exception(msg);
    }
  }
}
