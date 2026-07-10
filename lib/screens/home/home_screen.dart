import 'dart:math';

import 'package:driver_app_saferide/core/theme/app_typography.dart';
import 'package:driver_app_saferide/data/models/trip_model.dart';
import 'package:driver_app_saferide/data/models/trip_state_model.dart';
import 'package:driver_app_saferide/providers/auth_provider.dart';
import 'package:driver_app_saferide/providers/trip_provider.dart';

import 'package:driver_app_saferide/widgets/send_alert_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final driverName = authState.driver?.name.split(' ').first ?? 'Driver';
    // Mock trip data — real data comes from backend in later
    final tripState = ref.watch(tripProvider);
    final trip = tripState.activeTripModel!;
    final totalStops = trip?.stops.length ?? 0;
    final completedStops = tripState.currentStopIndex;
    final tripActive = tripState.screenState == TripScreenState.active;
    final nextStop = trip != null && tripActive
        ? trip.stops[tripState.currentStopIndex].stopName
        : 'No active Tripe';
    final nextStopEta = tripActive ? '- min' : '-';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Instrument bar — always visible, never scrolls ──
            _InstrumentBar(
              driverName: driverName,
              busNumber: trip?.busNumber ?? 'BA 2 KHA 4521',
              routeName: trip?.routeName ?? 'Baneshwor → Koteshwor',

              isActive: tripActive,
              scheme: scheme,
            ),

            //scrobale content below
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Next stop card
                    _NextStopCard(
                      scheme: scheme,
                      stopName: nextStop,
                      eta: nextStopEta,
                    ),
                    const SizedBox(height: 12),

                    // Progress ring + student list
                    _ProgressRingSection(
                      completed: completedStops,
                      total: totalStops > 0 ? totalStops : 1,
                      scheme: scheme,
                    ),
                    SizedBox(height: 12),

                    // Student list
                    _StudentListCard(scheme: scheme, tripState: tripState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Instrument bar//
class _InstrumentBar extends StatelessWidget {
  final String driverName;
  final String busNumber;
  final String routeName;
  final bool isActive;
  final ColorScheme scheme;

  const _InstrumentBar({
    required this.busNumber,
    required this.routeName,
    required this.isActive,
    required this.scheme,
    required this.driverName,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? scheme.primary.withValues(alpha: 0.3)
              : scheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              //Active indicator dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? scheme.primary : scheme.outline,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
              SizedBox(height: 8),
              Text(
                isActive ? 'TRIP ACTIVE' : 'NO ACTIVE TRIP',
                style: AppTypography.mono(
                  color: isActive
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.5),
                  size: 11,
                ),
              ),
              Spacer(),

              Text(
                driverName,
                style: AppTypography.mono(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  size: 11,
                ),
              ),
              Text(
                TimeOfDay.now().format(context),
                style: AppTypography.mono(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  size: 11,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            busNumber,
            style: AppTypography.display(color: scheme.onSurface, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            routeName,
            style: AppTypography.caption(
              color: scheme.onSurface.withValues(alpha: 0.5),
              size: 12,
            ),
          ),
          // Add this at the end of the instrument bar's column, after the route name
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => SendAlertSheet(tripId: 1),
                );
              },
              icon: Icon(Icons.campaign_rounded, size: 16, color: scheme.error),
              label: Text(
                'Send alert to parents',
                style: AppTypography.caption(color: scheme.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Next stop card
class _NextStopCard extends StatelessWidget {
  final String eta;
  final String stopName;
  final ColorScheme scheme;
  const _NextStopCard({
    required this.scheme,
    required this.eta,
    required this.stopName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Stop',
                  style: AppTypography.mono(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    size: 10,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  stopName,
                  style: AppTypography.heading(
                    color: scheme.onSurface,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          Text(
            eta,
            style: AppTypography.display(color: scheme.secondary, size: 22),
          ),
        ],
      ),
    );
  }
}

//Progress ring section

class _ProgressRingSection extends StatelessWidget {
  final int completed;
  final int total;
  final ColorScheme scheme;
  const _ProgressRingSection({
    required this.completed,
    required this.total,
    required this.scheme,
  });
  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(120, 120),
                  painter: _RingPainter(
                    progress: progress,
                    ringColor: scheme.primary,
                    trackColor: scheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_bus_filled_rounded,
                      size: 26,
                      color: scheme.primary,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$completed/$total',
                      style: AppTypography.mono(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                        size: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.width / 2);
    final radius = (size.width - 12 / 2);
    const strokeWidth = 7.0;
    const startAngle = -pi / 2;

    //track background circle
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = ringColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
}

// studentListCard
class _StudentListCard extends StatelessWidget {
  final ColorScheme scheme;
  final TripStateModel tripState;
  const _StudentListCard({required this.scheme, required this.tripState});

  @override
  Widget build(BuildContext context) {
    final trip = tripState.activeTripModel;
    final isActive = tripState.screenState == TripScreenState.active;

    if (trip == null) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              Icons.directions_bus_outlined,
              size: 36,
              color: scheme.onSurface.withValues(alpha: 0.2),
            ),
            SizedBox(height: 12),
            Text(
              'No active trip',
              style: AppTypography.heading(
                color: scheme.onSurface.withValues(alpha: 0.4),
                size: 14,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Go to the Trip tab to start your route',
              style: AppTypography.caption(
                color: scheme.onSurface.withValues(alpha: 0.3),
                size: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final stops = trip.stops;
    final index = tripState.currentStopIndex;

    final currentStop = stops[index];
    if (index >= stops.length) {
      SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              'At ${currentStop.stopName}',
              style: AppTypography.heading(
                color: scheme.onSurface.withValues(alpha: 0.6),
                size: 13,
              ),
            ),
          ),
          ...currentStop.students.asMap().entries.map((entry) {
            final i = entry.key;
            final student = entry.value;
            final isLast = i == currentStop.students.length - 1;
            Color statusColor;
            IconData statusIcon;
            switch (student.attendance) {
              case AttendanceStatus.boarded:
                statusColor = scheme.secondary;
                statusIcon = Icons.check_rounded;
                break;
              case AttendanceStatus.absent:
                statusColor = scheme.error;
                statusIcon = Icons.close_rounded;
                break;
              default:
                statusColor = scheme.outline;
                statusIcon = Icons.radio_button_unchecked;
            }
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.onSurface.withValues(alpha: 0.06),
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: AppTypography.mono(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      student.name,
                      style: AppTypography.body(color: scheme.onSurface),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 16),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
