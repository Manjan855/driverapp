import 'package:socket_io_client/socket_io_client.dart' as IO;

class DriverSocketService {
  IO.Socket? _socket;

  // Change this to your teammate's real backend URL
  static const String _socketUrl = 'http://YOUR_BACKEND_IP:5000';

  void connect({
    required int tripId,
    required int driverId,
    void Function()? onConnect,
    void Function(dynamic error)? onError,
  }) {
    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('🟢 Driver socket connected');
      // Join as driver for this trip
      _socket!.emit('driver_join', {'tripId': tripId, 'driverId': driverId});
      onConnect?.call();
    });

    _socket!.onError((error) {
      print('🔴 Driver socket error: $error');
      onError?.call(error);
    });
  }

  // Called every time Geolocator gives a new position
  void broadcastLocation({
    required int tripId,
    required double lat,
    required double lng,
  }) {
    if (_socket?.connected != true) return;
    _socket!.emit('location_update', {
      'tripId': tripId,
      'latitude': lat,
      'longitude': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Called when driver marks a student
  void emitStudentEvent({
    required int tripId,
    required int studentId,
    required String eventType, // 'boarded' | 'absent'
    required String stopName,
  }) {
    if (_socket?.connected != true) return;
    _socket!.emit('student_event', {
      'tripId': tripId,
      'studentId': studentId,
      'eventType': eventType,
      'stopName': stopName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
