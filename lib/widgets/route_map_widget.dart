import 'package:driver_app_saferide/data/models/trip_state_model.dart';
import 'package:flutter/material.dart';

class RouteMapWidget extends StatefulWidget {
  final List<TripStateModel> stops;
  final int currentStopIndex;
  final double? driverLat;
  final double? driverLng;
  const RouteMapWidget({
    super.key,
    required this.stops,
    required this.currentStopIndex,
    this.driverLat,
    this.driverLng,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
