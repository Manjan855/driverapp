// enum AlertType { delay, routeChange, emergency, tripStrted, tripEnded }

// class AlertModel {
//   final AlertType type;
//   final String message;
//   final int tripId;
//   final DateTime sentAt;

//   AlertModel({
//     required this.type,
//     required this.message,
//     required this.sentAt,
//     required this.tripId,
//   });
//   String get typeLabel {
//     switch (type) {
//       case AlertType.delay:
//         return 'Delay';
//       case AlertType.emergency:
//         return 'Emergency';
//       case AlertType.routeChange:
//         return 'Route Change';
//       case AlertType.tripStrted:
//         return 'Trip Started';
//       case AlertType.tripEnded:
//         return 'Trip Ended';
//     }
//   }
 
// }
enum AlertType { delay, emergency, routeChange, tripStarted, tripEnded }

extension AlertTypeLabel on AlertType {
  String get typeLabel {
    switch (this) {
      case AlertType.delay:
        return 'Delay';
      case AlertType.emergency:
        return 'Emergency';
      case AlertType.routeChange:
        return 'Route Change';
      case AlertType.tripStarted:
        return 'Trip Started';
      case AlertType.tripEnded:
        return 'Trip Ended';
    }
  }
}
  class AlertModel {
  final AlertType type;
  final String message;
  final int tripId;
  final DateTime sentAt;

  AlertModel({
    required this.type,
    required this.message,
    required this.tripId,
    required this.sentAt,
  });
 
}

