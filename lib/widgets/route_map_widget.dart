import 'dart:io';
import 'package:driver_app_saferide/screens/trip/full_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/map_constants.dart';
import '../data/models/trip_model.dart';

class RouteMapWidget extends StatefulWidget {
  final List<TripStopModel> stops;
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
  MapController? _mapController;
  bool _isMapReady = false;
  bool _routeDrawn = false;

  Future<String> _geoJsonToFileUri(String geoJson, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(geoJson);
    return 'file://${file.path}';
  }

  Future<void> _drawRoute() async {
    final style = _mapController?.style;
    if (style == null || _routeDrawn || widget.stops.isEmpty) return;
    _routeDrawn = true;

    // 1. Route polyline
    final lineCoords = widget.stops
        .map((s) => [s.longitude, s.latitude])
        .toList();

    final lineGeoJson =
        '''
    {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": ${lineCoords.toString()}
      }
    }
    ''';

    await style.addSource(
      GeoJsonSource(
        id: 'route-source',
        data: await _geoJsonToFileUri(lineGeoJson, 'driver_route.geojson'),
      ),
    );

    await style.addLayer(
      LineStyleLayer(
        id: 'route-layer',
        sourceId: 'route-source',
        paint: {
          'line-color': '#FFB020', // amber — matches Driver App accent
          'line-width': 4.0,
          'line-opacity': 0.9,
        },
      ),
    );

    // 2. Stop markers — different colors for completed, current, upcoming
    final stopFeatures = widget.stops
        .asMap()
        .entries
        .map((entry) {
          final i = entry.key;
          final stop = entry.value;
          final status = i < widget.currentStopIndex
              ? 'completed'
              : i == widget.currentStopIndex
              ? 'current'
              : 'upcoming';

          return '''
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [${stop.longitude}, ${stop.latitude}]
        },
        "properties": {
          "status": "$status",
          "name": "${stop.stopName}"
        }
      }
      ''';
        })
        .join(',');

    final stopsGeoJson =
        '''
    {
      "type": "FeatureCollection",
      "features": [$stopFeatures]
    }
    ''';

    await style.addSource(
      GeoJsonSource(
        id: 'stops-source',
        data: await _geoJsonToFileUri(stopsGeoJson, 'driver_stops.geojson'),
      ),
    );

    // Circle color based on status property
    await style.addLayer(
      CircleStyleLayer(
        id: 'stops-layer',
        sourceId: 'stops-source',
        paint: {
          'circle-radius': [
            'case',
            [
              '==',
              ['get', 'status'],
              'current',
            ],
            12.0,
            8.0,
          ],
          'circle-color': [
            'case',
            [
              '==',
              ['get', 'status'],
              'completed',
            ],
            '#3DDC84', // green
            [
              '==',
              ['get', 'status'],
              'current',
            ],
            '#FFB020', // amber
            '#FFFFFF', // white for upcoming
          ],
          'circle-stroke-width': 2.5,
          'circle-stroke-color': [
            'case',
            [
              '==',
              ['get', 'status'],
              'completed',
            ],
            '#FFFFFF',
            [
              '==',
              ['get', 'status'],
              'current',
            ],
            '#FFFFFF',
            '#FFB020',
          ],
        },
      ),
    );

    // 3. Fit camera to show entire route
    final bounds = _calculateBounds();
    await _mapController?.fitBounds(
      bounds: bounds,
      padding: const EdgeInsets.all(48),
    );
  }

  Future<void> _updateDriverMarker() async {
    final style = _mapController?.style;
    if (style == null || widget.driverLat == null || widget.driverLng == null)
      return;

    final driverGeoJson =
        '''
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [${widget.driverLng}, ${widget.driverLat}]
      }
    }
    ''';

    final uri = await _geoJsonToFileUri(
      driverGeoJson,
      'driver_location_${DateTime.now().millisecondsSinceEpoch}.geojson',
    );

    try {
      await style.removeLayer('driver-layer');
      await style.removeSource('driver-source');
    } catch (_) {}

    await style.addSource(GeoJsonSource(id: 'driver-source', data: uri));
    await style.addLayer(
      CircleStyleLayer(
        id: 'driver-layer',
        sourceId: 'driver-source',
        paint: {
          'circle-radius': 10.0,
          'circle-color': '#FFB020',
          'circle-stroke-width': 3.0,
          'circle-stroke-color': '#FFFFFF',
        },
      ),
    );
  }

  LngLatBounds _calculateBounds() {
    double minLat = widget.stops.first.latitude;
    double maxLat = widget.stops.first.latitude;
    double minLng = widget.stops.first.longitude;
    double maxLng = widget.stops.first.longitude;

    for (final stop in widget.stops) {
      if (stop.latitude < minLat) minLat = stop.latitude;
      if (stop.latitude > maxLat) maxLat = stop.latitude;
      if (stop.longitude < minLng) minLng = stop.longitude;
      if (stop.longitude > maxLng) maxLng = stop.longitude;
    }

    return LngLatBounds(
      latitudeNorth: maxLat,
      latitudeSouth: minLat,
      longitudeEast: maxLng,
      longitudeWest: minLng,
    );
  }

  @override
  void didUpdateWidget(RouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Redraw route when current stop changes
    if (oldWidget.currentStopIndex != widget.currentStopIndex) {
      _routeDrawn = false;
      _drawRoute();
    }

    // Update driver marker when GPS changes
    if (oldWidget.driverLat != widget.driverLat ||
        oldWidget.driverLng != widget.driverLng) {
      _updateDriverMarker();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullMapScreen(
              stops: widget.stops,
              currentStopIndex: widget.currentStopIndex,
              driverLat: widget.driverLat,
              driverLng: widget.driverLng,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              MapLibreMap(
                options: MapOptions(
                  initCenter: widget.stops.isNotEmpty
                      ? Geographic(
                          lon: widget.stops[widget.currentStopIndex].longitude,
                          lat: widget.stops[widget.currentStopIndex].latitude,
                        )
                      : Geographic(
                          lon: MapConstants.kathmanduLng,
                          lat: MapConstants.kathmanduLat,
                        ),
                  initZoom: MapConstants.defaultZoom,
                  initStyle: MapConstants.styleUrl,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                // onEvent: (event) {
                //   if (event case MapEventMapCreated()) {
                //     _mapController = event.mapController;
                //   }
                //},
                onStyleLoaded: (style) {
                  setState(() => _isMapReady = true);
                  _drawRoute();
                  if (widget.driverLat != null) {
                    _updateDriverMarker();
                  }
                },
              ),

              // Loading overlay
              if (!_isMapReady)
                Container(
                  color: isDark
                      ? const Color(0xFF141925)
                      : const Color(0xFFEDEFF3),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

              // Current stop label overlay — top left
              if (_isMapReady && widget.stops.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141925).withValues(alpha: 0.92)
                          : Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expand',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
