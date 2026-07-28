import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/trip_state_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/send_alert_sheet.dart';

// CHANGED: ConsumerWidget → ConsumerStatefulWidget
// so we can load trip data in initState before build runs
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // CHANGED: load trip data immediately on first render
    // so tripProvider is never null when widgets try to read it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverId = ref.read(authProvider).driver?.id ?? 1;
      ref.read(tripProvider.notifier).loadAssignedTrip(driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final driverName = authState.driver?.name.split(' ').first ?? 'Driver';

    final tripState = ref.watch(tripProvider);
    final trip = tripState.activeTripModel;
    // CHANGED: removed isActive local variable since it was unused (line 379 warning)
    // tripActive combines both checks in one place
    final tripActive =
        tripState.screenState == TripScreenState.active && trip != null;

    // CHANGED: explicit null check instead of ?. operator (fixes lines 24,27,39,40 warnings)
    final busNumber = trip == null ? 'BA 2 KHA 4521' : trip.busNumber;
    final routeName = trip == null ? 'Baneshwor → Koteshwor' : trip.routeName;
    final totalStops = trip == null ? 0 : trip.stops.length;
    final completedStops = tripActive ? tripState.currentStopIndex : 0;

    // CHANGED: fully null-safe next stop name
    final nextStopName =
        (tripActive && tripState.currentStopIndex < trip!.stops.length)
        ? trip.stops[tripState.currentStopIndex].stopName
        : 'No active trip';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _InstrumentBar(
              driverName: driverName,
              busNumber: busNumber,
              routeName: routeName,
              isActive: tripActive,
              scheme: scheme,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _NextStopCard(
                      stopName: nextStopName,
                      eta: tripActive ? '— min' : '—',
                      scheme: scheme,
                    ),
                    const SizedBox(height: 12),
                    _ProgressRingSection(
                      // CHANGED: guard against division by zero
                      completed: completedStops,
                      total: totalStops > 0 ? totalStops : 1,
                      scheme: scheme,
                    ),
                    const SizedBox(height: 12),
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

// ─────────────────────────────────────────────────────────────────────────────
// Instrument bar — unchanged from before, just receives computed values
// ─────────────────────────────────────────────────────────────────────────────
class _InstrumentBar extends StatelessWidget {
  final String driverName;
  final String busNumber;
  final String routeName;
  final bool isActive;
  final ColorScheme scheme;

  const _InstrumentBar({
    required this.driverName,
    required this.busNumber,
    required this.routeName,
    required this.isActive,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? scheme.primary.withValues(alpha: 0.3)
              : scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              const SizedBox(width: 8),
              Text(
                isActive ? 'TRIP ACTIVE' : 'NO ACTIVE TRIP',
                style: AppTypography.mono(
                  color: isActive
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.4),
                  size: 11,
                ),
              ),
              const Spacer(),
              Text(
                driverName,
                style: AppTypography.mono(
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  size: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          // Alert button
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

// ─────────────────────────────────────────────────────────────────────────────
// Next stop card — now receives dynamic values
// ─────────────────────────────────────────────────────────────────────────────
class _NextStopCard extends StatelessWidget {
  final String stopName;
  final String eta;
  final ColorScheme scheme;

  const _NextStopCard({
    required this.stopName,
    required this.eta,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  'NEXT STOP',
                  style: AppTypography.mono(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    size: 10,
                  ),
                ),
                const SizedBox(height: 4),
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

// ─────────────────────────────────────────────────────────────────────────────
// Progress ring section — unchanged
// ─────────────────────────────────────────────────────────────────────────────
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
      padding: const EdgeInsets.all(20),
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
                  size: const Size(120, 120),
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
                      color: scheme.primary,
                      size: 26,
                    ),
                    const SizedBox(height: 2),
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
          const SizedBox(height: 12),
          Text(
            '$completed of $total stops complete',
            style: AppTypography.body(
              color: scheme.onSurface.withValues(alpha: 0.7),
              size: 13,
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 7.0;
    const startAngle = -pi / 2;

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

// ─────────────────────────────────────────────────────────────────────────────
// Student list card — fully null-safe, handles no active trip gracefully
// ─────────────────────────────────────────────────────────────────────────────
class _StudentListCard extends StatelessWidget {
  final ColorScheme scheme;
  final TripStateModel tripState;

  const _StudentListCard({required this.scheme, required this.tripState});

  @override
  Widget build(BuildContext context) {
    final trip = tripState.activeTripModel;
    final isActive = tripState.screenState == TripScreenState.active;

    // CHANGED: guard — show idle state when no active trip
    if (trip == null || !isActive) {
      return Container(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 12),
            Text(
              'No active trip',
              style: AppTypography.heading(
                color: scheme.onSurface.withValues(alpha: 0.4),
                size: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Go to the Trip tab to start your route',
              style: AppTypography.caption(
                color: scheme.onSurface.withValues(alpha: 0.3),
                size: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // CHANGED: separate bounds check before accessing stops[index]
    final stops = trip.stops;
    final index = tripState.currentStopIndex;
    if (index >= stops.length) return const SizedBox.shrink();

    final currentStop = stops[index]; // ✅ non-nullable from here on

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
