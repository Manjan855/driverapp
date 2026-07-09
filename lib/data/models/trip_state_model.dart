import 'package:driver_app_saferide/data/models/trip_model.dart';

enum TripScreenState { idle, starting, active, ending }
class TripStateModel {
final TripScreenState screenState;
final TripModel? activeTripModel;
final int currentStopIndex ;
final bool isGpsBroadcasting;
final String? errorMessage;
final double? currentLat;
final double? currentLng;
TripStateModel({
  required this.screenState,
 this.isGpsBroadcasting =false,
  this.errorMessage,
  this.currentLat, 
  this.currentLng,
  this.currentStopIndex  = 0,
  this.activeTripModel
});

 const TripStateModel.idle()
:screenState = TripScreenState.idle,
activeTripModel = null,
currentStopIndex = 0,
 isGpsBroadcasting = false,
 errorMessage = null,
 currentLat = null,
 currentLng = null;



   TripStateModel copyWith({
  TripScreenState? screenState,
  TripModel? activeTripModel,
  int? currentStopIndex,
  bool? isGpsBroadcasting,
  String? errorMessage,
  double? currentLat,
  double? currentLng,
}){
  return TripStateModel(screenState: screenState ?? this.screenState,
  activeTripModel: activeTripModel ?? this.activeTripModel,
  isGpsBroadcasting: isGpsBroadcasting ?? this.isGpsBroadcasting,
  currentStopIndex: currentStopIndex ?? this.currentStopIndex,
  errorMessage: errorMessage,
  currentLat: currentLat ?? this.currentLat,
  currentLng: currentLng ?? this.currentLng,
  );
}
}