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
        factory TripHistoryModel.fromJson(Map<String, dynamic> json) {
    final bus = json['bus'] as Map<String, dynamic>?;
    final route = json['route'] as Map<String, dynamic>?;

    return TripHistoryModel(
      id: json['tripId'] ?? json['id'],
      date: DateTime.tryParse(
            json['departureTime'] ?? json['date'] ?? '',
          ) ??
          DateTime.now(),
      routeName: route?['routeName'] ?? json['routeName'] ?? '—',
      busNumber: bus?['busNumber'] ?? json['busNumber'] ?? '—',
      totalStudents: json['totalStudents'] ?? 0,
      boardedCount: json['boardedCount'] ?? json['attended'] ?? 0,
      absentCount: json['absentCount'] ?? json['absent'] ?? 0,
      departureTime: json['departureTime'] != null
          ? _formatTime(json['departureTime'])
          : '—',
      arrivalTime: json['arrivalTime'] != null
          ? _formatTime(json['arrivalTime'])
          : '—',
      status: json['tripStatus'] ?? json['status'] ?? 'completed',
    );
  }

  static String _formatTime(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '—';
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }
}

