import 'dart:math';

import 'package:driver_app_saferide/core/theme/app_typography.dart';
import 'package:driver_app_saferide/providers/auth_provider.dart';
import 'package:driver_app_saferide/widgets/send_alert_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    // final driverName = authState.driver?.name.split(' ').first ?? 'Driver';
    // Mock trip data — real data comes from backend in later 
    const totalStops = 5;
    const completedStops = 2;
    const tripActive = true;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Instrument bar — always visible, never scrolls ──
            _InstrumentBar(
              busNumber: 'BA 2 KHA 4521',
              routeName: 'Baneshwor → Koteshwor',

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
                    _NextStopCard(scheme: scheme),
                    const SizedBox(height: 12),

                    // Progress ring + student list
                    _ProgressRingSection(
                      completed: completedStops,
                      total: totalStops,
                      scheme: scheme,
                    ),
                    SizedBox(height: 12),

                    // Student list
                    _StudentListCard(scheme: scheme),
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
  final String busNumber;
  final String routeName;
  final bool isActive;
  final ColorScheme scheme;

  const _InstrumentBar({
    required this.busNumber,
    required this.routeName,
    required this.isActive,
    required this.scheme,
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
  final ColorScheme scheme;
  const _NextStopCard({required this.scheme});

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
                  'New Baneshowr Chowk',
                  style: AppTypography.heading(
                    color: scheme.onSurface,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '2 min',
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
const  _ProgressRingSection({
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
 const _StudentListCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final students = [
      {'name': 'Arav Sharma', 'initials': 'AS', 'status': 'boarded'},
      {'name': 'Priya Thapa', 'initials': 'PT', 'status': 'waiting'},
      {'name': 'Sandip Rai', 'initials': 'SR', 'status': 'absent'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: students.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final isLast = i == students.length - 1;
          final status = s['status']!;

          Color statusColor;
          IconData statusIcon;
          switch (status) {
            case 'boarded':
              statusColor = scheme.primary;
              statusIcon = Icons.check_rounded;
              break;
            case 'absent':
              statusColor = scheme.error;
              statusIcon = Icons.close_rounded;
              break;
            default:
              statusIcon = Icons.radio_button_unchecked;
              statusColor = scheme.outline;
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.onSurface.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      s['initials']!,
                      style: AppTypography.mono(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                        size: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s['name']!,
                    style: AppTypography.body(color: scheme.onSurface),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 18),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
