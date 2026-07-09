enum TripStatus { notStarted, inProgress, completed }

class TripModel {
  final int id;
  final String busNumber;
  final String routeName;
  final TripStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<TripStopModel> stops;

  TripModel({
    required this.id,
    required this.busNumber,
    required this.routeName,
    required this.status,
    this.startTime,
    this.endTime,
    required this.stops,
  });
}

class TripStopModel {
  final int id;
  final String stopName;
  final double latitude;
  final double longitude;
  final int sequenceOrder;
  final bool isCompleted;
  final List<TripStudentModel> students;

  TripStopModel({
    required this.id,
    required this.stopName,
    required this.latitude,
    required this.longitude,
    required this.sequenceOrder,
    this.isCompleted = false,
    required this.students,
  });

  TripStopModel copyWith({bool? isCompleted}) {
    return TripStopModel(
      id: id,
      stopName: stopName,
      latitude: latitude,
      longitude: longitude,
      sequenceOrder: sequenceOrder,
      isCompleted: isCompleted ?? this.isCompleted,
      students: students,
    );
  }
}

class TripStudentModel {
  final int id;
  final String name;
  final String initials;
  AttendanceStatus attendance;

  TripStudentModel({
    required this.id,
    required this.name,
    required this.initials,
    this.attendance = AttendanceStatus.waiting,
  });
}

enum AttendanceStatus { waiting, boarded, absent }
