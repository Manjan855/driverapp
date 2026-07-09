import 'package:driver_app_saferide/data/models/alert_model.dart';
import 'package:driver_app_saferide/data/services/alert_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final alertServiceProvider = Provider<AlertService>((ref){
  return AlertService();
  
});
class AlertNotifier extends StateNotifier<List<AlertModel>>{
   final AlertService _service;
   AlertNotifier(this._service): super([]);
   Future<bool> sendAlert({
    required AlertType type,
    required String message,
    required int tripId,
   })async{
    try{
      await _service.sendAlert(type: type, message: message, tripId: tripId);
      state = [
        AlertModel(type: type, message: message, sentAt: DateTime.now(), tripId: tripId)
      ];
      return true;

    }catch (e){
      return false;
    }
   }
}
final alertProvider = StateNotifierProvider<AlertNotifier, List<AlertModel>>((ref){
   return AlertNotifier(ref.read(alertServiceProvider));
});