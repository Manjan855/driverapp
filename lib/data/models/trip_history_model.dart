class TripHistoryModel {
  final int id;
  final DateTime date;
  final String routeName;
  final String busNumber;
  final int totalStudents;
  final int boardedCount;
  final int absentCount;
  final String departureTime;
  final String arrivalTime;
  final String status; // 'completed', 'cancelled'
  TripHistoryModel({
    required this.id,
    required this.date,
    required this.routeName,
    required this.busNumber,
    required this.totalStudents,
    required this.boardedCount,
    required this.absentCount,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
  });
  double get attendanceRate =>
      totalStudents > 0 ? boardedCount / totalStudents : 0.0;
}
