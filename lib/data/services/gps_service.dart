

import 'package:geolocator/geolocator.dart';

class GpsService {
Stream<Position> get positionStream{
  return Geolocator.getPositionStream(
    locationSettings: LocationSettings(
       accuracy: LocationAccuracy.high,
       distanceFilter: 10,
    )
     

    
  );
}
Future<Position?>  getCurrentPosition()async{
  try{
  final permission = await Geolocator.checkPermission();
  if(permission == LocationPermission.denied){
await Geolocator.requestPermission();
  }
 return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
} catch (e) {
  return null;
}
}
Future<bool> isPermissionGranted()async{
  final permission = await Geolocator.checkPermission();
  return permission == LocationPermission.always ||
   permission == LocationPermission.whileInUse;
}

}