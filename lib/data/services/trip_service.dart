import 'package:driver_app_saferide/data/models/trip_model.dart';
import 'package:flutter/rendering.dart';

class TripService {
  Future<TripModel> getAssignedTrip( int driverId) async{
    Future.delayed(Duration(milliseconds: 599)); 

    return TripModel(  id: 1,
      busNumber: 'BA 2 KHA 4521',
      routeName: 'Baneshwor → Koteshwor',
      status: TripStatus.notStarted, 
      stops: [TripStopModel( id: 1,
          stopName: 'Mid Baneshwor',
          latitude: 27.6933,
          longitude: 85.3414,
          sequenceOrder: 1,
          students: [
            TripStudentModel(id: 1, name: 'Aarav Sharma', initials: 'AS'),
            TripStudentModel(id: 2, name: 'Priya Thapa', initials: 'PT'),  ],
            
        ),
          TripStopModel(
          id: 2,
          stopName: 'New Baneshwor Chowk',
          latitude: 27.6889,
          longitude: 85.3473,
          sequenceOrder: 2,
          students: [
            TripStudentModel(id: 3, name: 'Sandip Rai', initials: 'SR'),
          ],
        ),
          TripStopModel(
          id: 3,
          stopName: 'Tinkune',
          latitude: 27.6883,
          longitude: 85.3512,
          sequenceOrder: 3,
          students: [
            TripStudentModel(id: 4, name: 'Sita Gurung', initials: 'SG'),
            TripStudentModel(id: 5, name: 'Bikash Poudel', initials: 'BP'),
          ],
        ),
        
        ]);
  }

  Future<void> startTrip(int tripId)async{
    await Future.delayed(Duration(milliseconds: 300));
     // Real: POST /trips/:id/start
  }
  Future<void> endTrip(int tripId) async{
    await Future.delayed(Duration(milliseconds: 300));
      // Real: POST /trips/:id/end
  }
  Future<void> markAttendance({
    required int tripId,
    required int studentId,
    required String status,
    required String stopName,
  })async{
    await Future.delayed(Duration(milliseconds: 300));
     // Real: POST /trips/:id/attendance
    //  print('📋 Marked $studentId as $status at $stopName');
  }
Future<void> broadcastLocation({
  required int tripId,
  required double lat,
  required double lng,

})async{
  // Real: emit via Socket.IO
  debugPrint('Broadcasting:$lat, $lng');
  return ;
}
  
}