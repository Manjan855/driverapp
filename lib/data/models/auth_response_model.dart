import 'package:driver_app_saferide/data/models/driver_model.dart';

class AuthResponseModel {
  final String token;
  final DriverModel driver;
  AuthResponseModel({required this.token, required this.driver});
}
