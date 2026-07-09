import 'package:driver_app_saferide/data/models/trip_history_model.dart';
import 'package:driver_app_saferide/data/services/trip_history_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tripHistoryServiceProvider = Provider<TripHistoryService>((ref){
return TripHistoryService();
});
final tripHistoryProvider = FutureProvider.family<List<TripHistoryModel>, int>((ref, driverId){
 return ref.read(tripHistoryServiceProvider).getHistory(driverId);
});