import 'package:driver_app_saferide/data/models/trip_state_model.dart';
import 'package:driver_app_saferide/data/services/gps_service.dart';
import 'package:driver_app_saferide/data/services/trip_service.dart';
import 'package:driver_app_saferide/providers/trip_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final tripServiceProvider = Provider<TripService>((ref)=> TripService());
final gpsServiceProvider = Provider<GpsService>((ref)=>GpsService());
final tripProvider = StateNotifierProvider<TripNotifier, TripStateModel>((ref){
return TripNotifier(ref.read(tripServiceProvider), ref.read(gpsServiceProvider));
});
