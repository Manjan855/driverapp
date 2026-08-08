import 'dart:async';

import 'package:driver_app_saferide/data/models/trip_model.dart';
import 'package:driver_app_saferide/data/models/trip_state_model.dart';
import 'package:driver_app_saferide/data/services/driver_socket_service.dart';
import 'package:driver_app_saferide/data/services/gps_service.dart';
import 'package:driver_app_saferide/data/services/trip_service.dart';
import 'package:flutter_riverpod/legacy.dart';

class TripNotifier extends StateNotifier<TripStateModel> {
  final TripService _tripService;
  final GpsService _gpsService;
  StreamSubscription? _gpsSubscription;
  final DriverSocketService _socketService = DriverSocketService();
  TripNotifier(this._tripService, this._gpsService)
    : super(TripStateModel.idle());

  Future<void> loadAssignedTrip(int driverId) async {
    try {
      final trip = await _tripService.getAssignedTrip(driverId);
      state = state.copyWith(
        screenState: TripScreenState.idle,
        activeTripModel: trip,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not load trip data');
    }
  }

  // Future<void> startTrip() async {
  //   if (state.activeTripModel == null) return;
  //   state = state.copyWith(screenState: TripScreenState.starting);
  //   try {
  //     await _tripService.startTrip(state.activeTripModel!.id);
  //     _startGpsBroadcast();
  //     state = state.copyWith(
  //       screenState: TripScreenState.active,
  //       isGpsBroadcasting: true,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       screenState: TripScreenState.idle,
  //       errorMessage: 'Failed to start Trip',
  //     );
  //   }
  // }
   Future<void> startTrip() async {
    if (state.activeTripModel == null) return;
    state = state.copyWith(screenState: TripScreenState.starting);

    try {
      await _tripService.startTrip(state.activeTripModel!.id);

      // Connect socket when trip starts
      _socketService.connect(
        tripId: state.activeTripModel!.id,
        driverId: 1, // replace with real driver ID from auth
        onConnect: () => print('🟢 Driver broadcasting live'),
        onError: (e) => print('🔴 Socket error: $e'),
      );

      _startGpsBroadcast();
      state = state.copyWith(
        screenState: TripScreenState.active,
        isGpsBroadcasting: true,
      );
    } catch (e) {
      state = state.copyWith(
        screenState: TripScreenState.idle,
        errorMessage: 'Failed to start trip',
      );
    }
  }
  void goToPreviousStop() {
    if (state.currentStopIndex <= 0) return; // already at first stop
    state = state.copyWith(currentStopIndex: state.currentStopIndex - 1);
  }

  // Future<void> endTrip() async {
  //   if (state.activeTripModel == null) return;
  //   state = state.copyWith(screenState: TripScreenState.ending);
  //   try {
  //     await _tripService.endTrip(state.activeTripModel!.id);
  //     _stopGpsBroadcast();
  //     state = state.copyWith(
  //       screenState: TripScreenState.idle,
  //       isGpsBroadcasting: false,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       screenState: TripScreenState.active,
  //       errorMessage: 'Failed to end Trip',
  //     );
  //   }
  // }
  Future<void> endTrip() async {
    if (state.activeTripModel == null) return;
    state = state.copyWith(screenState: TripScreenState.ending);

    try {
      await _tripService.endTrip(state.activeTripModel!.id);
      _stopGpsBroadcast();
      _socketService.disconnect(); // ← disconnect socket on trip end
      state = state.copyWith(
        screenState: TripScreenState.idle,
        isGpsBroadcasting: false,
      );
    } catch (e) {
      state = state.copyWith(
        screenState: TripScreenState.active,
        errorMessage: 'Failed to end trip',
      );
    }
  }
  void _startGpsBroadcast() {
    _gpsSubscription = _gpsService.positionStream.listen((position) {
      state = state.copyWith(
        currentLat: position.latitude,
        currentLng: position.longitude,
      );

      // REAL broadcast via socket instead of print
      if (state.activeTripModel != null) {
        _socketService.broadcastLocation(
          tripId: state.activeTripModel!.id,
          lat: position.latitude,
          lng: position.longitude,
        );
      }
    });
  }

  Future<void> markStudent({
    required int studentId,
    required AttendanceStatus status,
  }) async {
    final trip = state.activeTripModel;
    if (trip == null) return;
    final eventType = status == AttendanceStatus.boarded ? 'boarded' : 'absent';
    final currentStop = trip.stops[state.currentStopIndex];
    // Update local state immediately — optimistic update

    final updatedStops = trip.stops.map((stop) {
      if (stop.id != currentStop.id) return stop;
      final updatedStudents = stop.students.map((s) {
        if (s.id != studentId) return s;
        return TripStudentModel(
          id: s.id,
          name: s.name,
          initials: s.initials,
          attendance: status,
        );
      }).toList();
      return TripStopModel(
        id: stop.id,
        stopName: stop.stopName,
        latitude: stop.latitude,
        longitude: stop.longitude,
        sequenceOrder: stop.sequenceOrder,
        students: updatedStudents,
      );
    }).toList();
    state = state.copyWith(
      activeTripModel: TripModel(
        id: trip.id,
        busNumber: trip.busNumber,
        routeName: trip.routeName,
        status: trip.status,
        stops: updatedStops,
      ),
    );
     _socketService.emitStudentEvent(
      tripId: trip.id,
      studentId: studentId,
      eventType: eventType,
      stopName: currentStop.stopName,
    );
    //send to backend
    await _tripService.markAttendance(
      tripId: trip.id,
      studentId: studentId,
      status: status == AttendanceStatus.boarded ? 'boarded' : 'absent',
      stopName: currentStop.stopName,
    );
  }

  void advanceToNextStop() {
    final trip = state.activeTripModel;
    if (trip == null) return;
    final nextIndex = state.currentStopIndex + 1;
    if (nextIndex >= trip.stops.length) return;
    state = state.copyWith(currentStopIndex: nextIndex);
  }

  // void _startGpsBroadcast() {
  //   _gpsSubscription = _gpsService.positionStream.listen((position) {
  //     state = state.copyWith(
  //       currentLat: position.latitude,
  //       currentLng: position.longitude,
  //     );
  //     if (state.activeTripModel != null) {
  //       _tripService.broadcastLocation(
  //         tripId: state.activeTripModel!.id,
  //         lat: position.latitude,
  //         lng: position.longitude,
  //       );
  //     }
  //   });
  // }

  void _stopGpsBroadcast() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }

  @override
  void dispose() {
    _stopGpsBroadcast();
    _socketService.disconnect();
    super.dispose();
  }
}
