import 'dart:ui';

import 'package:driver_app_saferide/core/theme/app_typography.dart';
import 'package:driver_app_saferide/data/models/trip_model.dart';
import 'package:driver_app_saferide/data/models/trip_state_model.dart';
import 'package:driver_app_saferide/providers/auth_provider.dart';
import 'package:driver_app_saferide/providers/trip_provider.dart';
import 'package:driver_app_saferide/widgets/route_map_widget.dart';
import 'package:driver_app_saferide/widgets/send_alert_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripScreen extends ConsumerStatefulWidget {
  const TripScreen({super.key});

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverId = ref.read(authProvider).driver?.id ?? 1;
      ref.read(tripProvider.notifier).loadAssignedTrip(driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trip',
          style: AppTypography.heading(color: scheme.onSurface),
        ),
        actions: [
          //AlertButton - always active during the trip
          if (tripState.screenState == TripScreenState.active)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => SendAlertSheet(
                    tripId: tripState.activeTripModel?.id ?? 1,
                  ),
                );
              },
              icon: Icon(Icons.campaign_rounded, color: scheme.error),
              tooltip: 'Send Alert',
            ),

          // GPS indicator
          if (tripState.isGpsBroadcasting)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.secondary.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GPS LIVE',
                    style: AppTypography.mono(
                      color: scheme.secondary,
                      size: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: tripState.activeTripModel == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : TripBody(),
    );
  }
}

class TripBody extends ConsumerWidget {
  // final TripStateModel tripState;
  const TripBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);
    final scheme = Theme.of(context).colorScheme;
    final trip = tripState.activeTripModel;
    if (trip == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }
    final isActive = tripState.screenState == TripScreenState.active;
    final currentStop = isActive
        ? trip.stops[tripState.currentStopIndex]
        : null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Trip info card
                _TripInfoCard(trip: trip, scheme: scheme),
                const SizedBox(height: 12),
                RouteMapWidget(
                  stops: trip.stops,
                  currentStopIndex: 0,
                  driverLat: null,
                  driverLng: null,
                ),
                // Current stop + students (only when active)
                if (isActive && currentStop != null) ...[
                  _CurrentStopCard(stop: currentStop, scheme: scheme),

                  const SizedBox(height: 12),
                  RouteMapWidget(
                    stops: trip.stops,
                    currentStopIndex: tripState.currentStopIndex,
                    driverLat: tripState.currentLat,
                    driverLng: tripState.currentLng,
                  ),
                  const SizedBox(height: 12),
                  _StudentMarkingCard(
                    stop: currentStop,
                    scheme: scheme,
                    onMark: (studentId, status) {
                      ref
                          .read(tripProvider.notifier)
                          .markStudent(studentId: studentId, status: status);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Advance to next stop button
                  if (tripState.currentStopIndex < trip.stops.length - 1)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(tripProvider.notifier).advanceToNextStop();
                        },
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: scheme.primary,
                        ),
                        label: Text(
                          'Next stop: ${trip.stops[tripState.currentStopIndex + 1].stopName}',
                          style: AppTypography.body(color: scheme.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: scheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  // Stop list overview
                  const SizedBox(height: 12),
                  _StopsOverviewCard(
                    stops: trip.stops,
                    currentIndex: tripState.currentStopIndex,
                    scheme: scheme,
                  ),
                ],

                // Not active: show all stops overview
                if (!isActive)
                  _StopsOverviewCard(
                    stops: trip.stops,
                    currentIndex: -1,
                    scheme: scheme,
                  ),
              ],
            ),
          ),
        ),

        // ── Bottom action bar ──
        _TripActionBar(tripState: tripState, scheme: scheme),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip info card
// ─────────────────────────────────────────────────────────────────────────────

class _TripInfoCard extends StatelessWidget {
  final TripModel trip;
  final ColorScheme scheme;

  const _TripInfoCard({required this.trip, required this.scheme});

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
                  trip.busNumber,
                  style: AppTypography.display(
                    color: scheme.onSurface,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip.routeName,
                  style: AppTypography.caption(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${trip.stops.length} stops',
              style: AppTypography.mono(color: scheme.primary, size: 11),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Current stop card
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentStopCard extends StatelessWidget {
  final TripStopModel stop;
  final ColorScheme scheme;

  const _CurrentStopCard({required this.stop, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: scheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STOP',
                  style: AppTypography.mono(color: scheme.primary, size: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  stop.stopName,
                  style: AppTypography.heading(
                    color: scheme.onSurface,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${stop.students.length} students',
            style: AppTypography.caption(
              color: scheme.onSurface.withValues(alpha: 0.5),
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Student marking card — the core interaction, large tap targets
// ─────────────────────────────────────────────────────────────────────────────

class _StudentMarkingCard extends StatelessWidget {
  final TripStopModel stop;
  final ColorScheme scheme;
  final void Function(int studentId, AttendanceStatus status) onMark;

  const _StudentMarkingCard({
    required this.stop,
    required this.scheme,
    required this.onMark,
  });

  @override
  Widget build(BuildContext context) {
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
              'Mark attendance',
              style: AppTypography.heading(
                color: scheme.onSurface.withValues(alpha: 0.6),
                size: 13,
              ),
            ),
          ),
          ...stop.students.asMap().entries.map((entry) {
            final i = entry.key;
            final student = entry.value;
            final isLast = i == stop.students.length - 1;

            return Container(
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.onSurface.withValues(alpha: 0.06),
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: AppTypography.mono(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      student.name,
                      style: AppTypography.body(
                        color: scheme.onSurface,
                        size: 14,
                      ),
                    ),
                  ),
                  // Two action buttons — Boarded / Absent
                  Row(
                    children: [
                      _MarkButton(
                        icon: Icons.check_rounded,
                        label: 'Board',
                        isSelected:
                            student.attendance == AttendanceStatus.boarded,
                        activeColor: scheme.secondary,
                        scheme: scheme,
                        onTap: () =>
                            onMark(student.id, AttendanceStatus.boarded),
                      ),
                      const SizedBox(width: 8),
                      _MarkButton(
                        icon: Icons.close_rounded,
                        label: 'Absent',
                        isSelected:
                            student.attendance == AttendanceStatus.absent,
                        activeColor: scheme.error,
                        scheme: scheme,
                        onTap: () =>
                            onMark(student.id, AttendanceStatus.absent),
                      ),
                    ],
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

class _MarkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const _MarkButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : scheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? activeColor
                  : scheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.mono(
                color: isSelected
                    ? activeColor
                    : scheme.onSurface.withValues(alpha: 0.3),
                size: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stops overview card
// ─────────────────────────────────────────────────────────────────────────────

class _StopsOverviewCard extends StatelessWidget {
  final List<TripStopModel> stops;
  final int currentIndex;
  final ColorScheme scheme;

  const _StopsOverviewCard({
    required this.stops,
    required this.currentIndex,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route stops',
            style: AppTypography.heading(
              color: scheme.onSurface.withValues(alpha: 0.6),
              size: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...stops.asMap().entries.map((entry) {
            final i = entry.key;
            final stop = entry.value;
            final isCurrent = i == currentIndex;
            final isPast = currentIndex >= 0 && i < currentIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                              : scheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      if (i < stops.length - 1)
                        Container(
                          width: 1,
                          height: 20,
                          color: scheme.outline.withValues(alpha: 0.2),
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
                            : scheme.onSurface.withValues(alpha: 0.5),
                        size: isCurrent ? 14 : 13,
                      ),
                    ),
                  ),
                  Text(
                    '${stop.students.length} students',
                    style: AppTypography.caption(
                      color: scheme.onSurface.withValues(alpha: 0.3),
                      size: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip action bar — Start / End trip, always pinned at the bottom
// ─────────────────────────────────────────────────────────────────────────────

class _TripActionBar extends ConsumerWidget {
  final TripStateModel tripState;
  final ColorScheme scheme;

  const _TripActionBar({required this.tripState, required this.scheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = tripState.screenState == TripScreenState.active;
    final isLoading =
        tripState.screenState == TripScreenState.starting ||
        tripState.screenState == TripScreenState.ending;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outline.withValues(alpha: 0.15)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (isActive) {
                    _confirmEndTrip(context, ref);
                  } else {
                    ref.read(tripProvider.notifier).startTrip();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? scheme.error : scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: scheme.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'End trip' : 'Start trip',
                      style: AppTypography.heading(
                        color: scheme.onPrimary,
                        size: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _confirmEndTrip(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'End trip?',
          style: AppTypography.heading(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will stop GPS broadcasting and finalize attendance for all stops.',
          style: AppTypography.body(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.body(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tripProvider.notifier).endTrip();
            },
            child: Text(
              'End trip',
              style: AppTypography.body(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
