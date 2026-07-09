import 'package:driver_app_saferide/data/models/trip_history_model.dart';

class TripHistoryService {
  Future<List<TripHistoryModel>> getHistory(int driverId) async {
    await Future.delayed(Duration(milliseconds: 300));

    final now = DateTime.now();
    return List.generate(14, (i) {
      final date = now.subtract(Duration(days: i));
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      final isCancelled = i == 4;
      if (isWeekend) return null;

      return TripHistoryModel(
        id: 1,
        date: date,
        routeName: 'Baneshwor → Koteshwor',
        busNumber: 'BA 2 KHA 4521',
        totalStudents: 5,
        boardedCount: isCancelled ? 0 : (i == 2 ? 4 : 5),
        absentCount: isCancelled ? 0 : (i == 2 ? 1 : 0),
        departureTime: '7:42 AM',
        arrivalTime: isCancelled ? '-' : '8:45',
        status: isCancelled ? 'Cancelled' : 'Completed',
      );
    }).whereType<TripHistoryModel>().toList();
  }
  Future<TripHistoryModel> getTripDetails(int tripId)async{
    await Future.delayed(Duration(milliseconds: 300));

    return TripHistoryModel(id: tripId, date: DateTime.now().subtract(Duration(days: 1)), routeName: 'Baneshwor → Koteshwor',
      busNumber: 'BA 2 KHA 4521',
      totalStudents: 5,
      boardedCount: 5,
      absentCount: 0,
      departureTime: '7:42 AM',
      arrivalTime: '8:28 AM',
      status: 'completed',);
  }
}
