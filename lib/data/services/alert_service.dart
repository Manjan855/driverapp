import 'package:driver_app_saferide/data/models/alert_model.dart';

class AlertService {
  Future<void> sendAlert({
    required AlertType type,
    required String message,
    required int tripId,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    // Real: POST /trips/:id/alerts  +  FCM broadcast to all parents
    print("Alert sent: ${type.name} - $message");
  }

  Future<List<AlertModel>> getsentAlert(int tripId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return [
      AlertModel(
        type: AlertType.delay,
        message: 'Heavy traffic near Tinkune. Expecting 15 minute delay.',
        sentAt: DateTime.now().subtract(Duration(minutes: 12)),
        tripId: tripId,
      ),
    ];
  }
}
