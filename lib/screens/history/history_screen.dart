import 'package:driver_app_saferide/core/theme/app_typography.dart';
import 'package:driver_app_saferide/data/models/trip_history_model.dart';
import 'package:driver_app_saferide/providers/auth_provider.dart';
import 'package:driver_app_saferide/providers/trip_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Text(
                'Not trips yet',
                style: AppTypography.body(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }
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
              //summary stat
              Container(margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
               decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [],
                ),
              ),
              //trip list
              Expanded(child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: trips.length,
                itemBuilder: (context,index){
                  final trip = trips[index];
                  return Padding(padding: 
                  EdgeInsets.only(bottom: 8),
                  child: _,)
                }))
            ],
          );
        },
        error: (e, s) => Center(
          child: Text(
            'Could not load history',
            style: AppTypography.body(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        loading: () =>
            Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      ),
    );
  }
}
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme scheme;
   const _Stat({
    required this.label,
    required this.value,
    required this.scheme,
  });
   @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.display(
            color: scheme.onSurface,
            size: 22,
          ),
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
class _TripHistoryCard extends StatelessWidget {
  final TripHistoryModel trip;
  final ColorScheme scheme;
  _TripHistoryCard({
    required this.scheme,
    required this.trip
  });
  @override
  Widget build(BuildContext context) {
   final isCancelled = trip.status == 'Cancelled';
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
              //Date colume
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('EEE').format(trip.date),  style: AppTypography.mono(
                      color: scheme.onSurface.withValues(alpha: 0.4),
                      size: 10,
                    ),),
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
                //route info
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(trip.routeName, style: AppTypography.body(
                        color: scheme.onSurface,
                        size: 13,
                      ),),
                      const SizedBox(height: 2),
                      Text( "${trip.departureTime} -> ${trip.arrivalTime}", style: AppTypography.mono(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        size: 11,
                      ),)
                ],)),
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
                child: Text(isCancelled ? 'Cancelled': 'Completed',  style: AppTypography.mono(
                    color: statusColor,
                    size: 10,
                  ),),
                )
            ],

          ),
          if(!isCancelled)...[
            SizedBox(height:10),
            Container(
              height: 0.5,
              color: scheme.outline.withValues(alpha: 0.15),
            ),
            SizedBox(height: 10,),
            //attendance row
            Row(children: [
            Icon(Icons.person_outline, size: 14, color: scheme.onSurface.withValues(alpha: 0.3),),
            SizedBox( height: 6,),
            Text('${trip.boardedCount}/${trip.totalStudents}boarded',style: AppTypography.caption(color: scheme.onSurface.withValues(alpha: 0.5),size: 12),),
            Spacer()
            //mini attendace bar
            SizedBox( height: 80,
            width: 4,
            child: ClipRRect(
             borderRadius: BorderRadius.circular(14), 
              child: LinearProgressIndicator(
                value: trip.attendanceRate,
                backgroundColor: scheme.onSurface.withValues(alpha:  0.08),
                color: trip.attendanceRate == 1.0 ? scheme.secondary : scheme.primary
              ),
              ,
            ),)
            ],)
          ]
        ],
      ),
   );
  }
}