import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/trip_history_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_history_provider.dart';
import '../../widgets/shimmer_box.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final driverId = ref.watch(authProvider).driver?.id ?? 1;
    final historyAsync = ref.watch(tripHistoryProvider(driverId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trip History',
          style: AppTypography.heading(color: scheme.onSurface),
        ),
      ),
      body: historyAsync.when(
        // ── LOADING: shimmer skeleton ──
        loading: () => Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ShimmerBox(
                    width: 60,
                    height: 40,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  ShimmerBox(
                    width: 60,
                    height: 40,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  ShimmerBox(
                    width: 60,
                    height: 40,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: 6,
                itemBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ShimmerBox(
                          width: 44,
                          height: 36,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(
                                width: 140,
                                height: 13,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 6),
                              ShimmerBox(
                                width: 90,
                                height: 11,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        ShimmerBox(
                          width: 70,
                          height: 22,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── ERROR state ──
        error: (e, s) => Center(
          child: Text(
            'Could not load history',
            style: AppTypography.body(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),

        // ── DATA: real content — _Stat and _TripHistoryCard used here ──
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Text(
                'No trips yet',
                style: AppTypography.body(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          // Computed summary values
          final totalTrips = trips.length;
          final completedTrips = trips
              .where((t) => t.status == 'completed')
              .length;
          final totalStudents = trips.fold<int>(
            0,
            (sum, t) => sum + t.boardedCount,
          );

          return Column(
            children: [
              // ── Stats card — uses _Stat widget ──
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // CHANGED: now actually calling _Stat
                    _Stat(
                      label: 'Total trips',
                      value: '$totalTrips',
                      scheme: scheme,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: scheme.outline.withValues(alpha: 0.2),
                    ),
                    _Stat(
                      label: 'Completed',
                      value: '$completedTrips',
                      scheme: scheme,
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: scheme.outline.withValues(alpha: 0.2),
                    ),
                    _Stat(
                      label: 'Students\ntransported',
                      value: '$totalStudents',
                      scheme: scheme,
                    ),
                  ],
                ),
              ),

              // ── Trip list — uses _TripHistoryCard widget ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      // CHANGED: now actually calling _TripHistoryCard
                      child: _TripHistoryCard(
                        trip: trips[index],
                        scheme: scheme,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Stat widget — shows a single summary number with label
// ─────────────────────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme scheme;

  const _Stat({required this.label, required this.value, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.display(color: scheme.onSurface, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption(
            color: scheme.onSurface.withValues(alpha: 0.5),
            size: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TripHistoryCard widget — shows one trip entry in the list
// ─────────────────────────────────────────────────────────────────────────────
class _TripHistoryCard extends StatelessWidget {
  final TripHistoryModel trip;
  final ColorScheme scheme;

  const _TripHistoryCard({required this.trip, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final isCancelled = trip.status == 'cancelled';
    final statusColor = isCancelled ? scheme.error : scheme.secondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Date column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE').format(trip.date),
                    style: AppTypography.mono(
                      color: scheme.onSurface.withValues(alpha: 0.4),
                      size: 10,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(trip.date),
                    style: AppTypography.heading(
                      color: scheme.onSurface,
                      size: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Route info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.routeName,
                      style: AppTypography.body(
                        color: scheme.onSurface,
                        size: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.departureTime} → ${trip.arrivalTime}',
                      style: AppTypography.mono(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        size: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCancelled ? 'Cancelled' : 'Completed',
                  style: AppTypography.mono(color: statusColor, size: 10),
                ),
              ),
            ],
          ),

          // Attendance row — only shown for completed trips
          if (!isCancelled) ...[
            const SizedBox(height: 10),
            Container(
              height: 0.5,
              color: scheme.outline.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 14,
                  color: scheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 6),
                Text(
                  '${trip.boardedCount}/${trip.totalStudents} boarded',
                  style: AppTypography.caption(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    size: 12,
                  ),
                ),
                const Spacer(),

                // Mini attendance progress bar
                SizedBox(
                  width: 80,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: trip.attendanceRate,
                      backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                      color: trip.attendanceRate == 1.0
                          ? scheme.secondary
                          : scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(trip.attendanceRate * 100).round()}%',
                  style: AppTypography.mono(
                    color: trip.attendanceRate == 1.0
                        ? scheme.secondary
                        : scheme.primary,
                    size: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
