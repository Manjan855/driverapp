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

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Handle nested bus/route data from Prisma includes
    final bus = json['bus'] as Map<String, dynamic>?;
    final route = json['route'] as Map<String, dynamic>?;

    // Parse status
    TripStatus status;
    switch (json['tripStatus'] ?? json['status']) {
      case 'in_progress':
      case 'inProgress':
        status = TripStatus.inProgress;
        break;
      case 'completed':
        status = TripStatus.completed;
        break;
      default:
        status = TripStatus.notStarted;
    }

    // Parse stops — may come from route.routeStops or directly
    final stopsJson =
        route?['routeStops'] as List<dynamic>? ??
        json['stops'] as List<dynamic>? ??
        [];

    return TripModel(
      id: json['tripId'] ?? json['id'],
      busNumber: bus?['busNumber'] ?? json['busNumber'] ?? '—',
      routeName: route?['routeName'] ?? json['routeName'] ?? '—',
      status: status,
      startTime: json['departureTime'] != null
          ? DateTime.tryParse(json['departureTime'])
          : null,
      endTime: json['arrivalTime'] != null
          ? DateTime.tryParse(json['arrivalTime'])
          : null,
      stops: stopsJson.map((s) => TripStopModel.fromJson(s)).toList()
        ..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder)),
    );
  }
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

  factory TripStopModel.fromJson(Map<String, dynamic> json) {
    final studentsJson =
        json['students'] as List<dynamic>? ??
        json['student'] as List<dynamic>? ??
        [];

    return TripStopModel(
      id: json['stopId'] ?? json['id'],
      stopName: json['stopName'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      sequenceOrder: json['sequenceOrder'] ?? 0,
      students: studentsJson.map((s) => TripStudentModel.fromJson(s)).toList(),
    );
  }

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

  factory TripStudentModel.fromJson(Map<String, dynamic> json) {
    final name = json['studentName'] ?? json['name'] ?? '';
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .where((w) => w.isNotEmpty)
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join()
        : '?';

    return TripStudentModel(
      id: json['studentId'] ?? json['id'],
      name: name,
      initials: initials,
    );
  }
}

enum AttendanceStatus { waiting, boarded, absent }
