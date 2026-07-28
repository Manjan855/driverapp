import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/map_constants.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/trip_model.dart';

class FullMapScreen extends StatefulWidget {
  final List<TripStopModel> stops;
  final int currentStopIndex;
  final double? driverLat;
  final double? driverLng;

  const FullMapScreen({
    super.key,
    required this.stops,
    required this.currentStopIndex,
    this.driverLat,
    this.driverLng,
  });

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
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
        data: await _geoJsonToFileUri(lineGeoJson, 'full_route.geojson'),
      ),
    );

    await style.addLayer(
      LineStyleLayer(
        id: 'route-layer',
        sourceId: 'route-source',
        paint: {
          'line-color': '#FFB020',
          'line-width': 5.0,
          'line-opacity': 0.9,
        },
      ),
    );

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
        data: await _geoJsonToFileUri(stopsGeoJson, 'full_stops.geojson'),
      ),
    );

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
            14.0,
            9.0,
          ],
          'circle-color': [
            'case',
            [
              '==',
              ['get', 'status'],
              'completed',
            ],
            '#3DDC84',
            [
              '==',
              ['get', 'status'],
              'current',
            ],
            '#FFB020',
            '#FFFFFF',
          ],
          'circle-stroke-width': 3.0,
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

    // Fit to full route
    final bounds = _calculateBounds();
    await _mapController?.fitBounds(
      bounds: bounds,
      padding: const EdgeInsets.fromLTRB(48, 120, 48, 200),
    );
  }

  Future<void> _addDriverMarker() async {
    final style = _mapController?.style;
    if (style == null || widget.driverLat == null || widget.driverLng == null)
      return;

    final geoJson =
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
      geoJson,
      'full_driver_${DateTime.now().millisecondsSinceEpoch}.geojson',
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
          'circle-radius': 12.0,
          'circle-color': '#FFB020',
          'circle-stroke-width': 4.0,
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStop = widget.stops.isNotEmpty
        ? widget.stops[widget.currentStopIndex]
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
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
            onStyleLoaded: (style) {
              setState(() => _isMapReady = true);
              _drawRoute();
              if (widget.driverLat != null) {_addDriverMarker();}
            },
          ),

          // Loading overlay
          if (!_isMapReady)
            Container(
              color: isDark ? const Color(0xFF0B0E14) : const Color(0xFFEDEFF3),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
            ),

          // ── Top overlay: back button + route label ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Back button — prominent, like InDrive/Yango
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141925).withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Route label pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141925).withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentStop?.stopName ?? 'Route map',
                              style: AppTypography.mono(
                                color: scheme.onSurface,
                                size: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
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

          // ── Bottom overlay: stops list panel ──
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141925).withValues(alpha: 0.96)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: scheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Route progress',
                            style: AppTypography.caption(
                              color: scheme.onSurface.withValues(alpha: 0.5),
                              size: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.currentStopIndex}/${widget.stops.length} stops',
                            style: AppTypography.mono(
                              color: scheme.primary,
                              size: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: widget.stops.isNotEmpty
                              ? widget.currentStopIndex / widget.stops.length
                              : 0,
                          backgroundColor: scheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                          color: scheme.primary,
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Stops list — scrollable, max 3 visible
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        shrinkWrap: true,
                        itemCount: widget.stops.length,
                        itemBuilder: (context, i) {
                          final stop = widget.stops[i];
                          final isPast = i < widget.currentStopIndex;
                          final isCurrent = i == widget.currentStopIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                // Timeline dot
                                Column(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCurrent
                                            ? scheme.primary
                                            : isPast
                                            ? scheme.secondary
                                            : scheme.outline.withValues(
                                                alpha: 0.3,
                                              ),
                                      ),
                                    ),
                                    if (i < widget.stops.length - 1)
                                      Container(
                                        width: 1,
                                        height: 16,
                                        color: scheme.outline.withValues(
                                          alpha: 0.2,
                                        ),
                                        margin: const EdgeInsets.only(top: 2),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    stop.stopName,
                                    style: AppTypography.body(
                                      color: isCurrent
                                          ? scheme.onSurface
                                          : scheme.onSurface.withValues(
                                              alpha: 0.45,
                                            ),
                                      size: isCurrent ? 14 : 13,
                                    ),
                                  ),
                                ),
                                if (isPast)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: scheme.secondary,
                                  ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'NOW',
                                      style: AppTypography.mono(
                                        color: scheme.primary,
                                        size: 9,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
