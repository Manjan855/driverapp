// import 'package:dio/dio.dart';
import 'package:dio/dio.dart';

import '../models/alert_model.dart';
import 'api_client.dart';

class AlertService {
  final ApiClient _apiClient = ApiClient();

  /// POST /api/notifications/alert
  Future<void> sendAlert({
    required AlertType type,
    required String message,
    required int tripId,
  }) async {
    try {
      await _apiClient.dio.post(
        '/notifications/alert',
        data: {
          'tripId': tripId,
          'eventType': _alertTypeToString(type),
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to send alert';
      throw Exception(msg);
    }
  }

  String _alertTypeToString(AlertType type) {
    switch (type) {
      case AlertType.delay:
        return 'delay';
      case AlertType.emergency:
        return 'emergency';
      case AlertType.routeChange:
        return 'route_change';
      case AlertType.tripStarted:
        return 'trip_started';
      case AlertType.tripEnded:
        return 'trip_ended';
    }
  }
}
