import 'package:driver_app_saferide/data/models/driver_model.dart';

enum AuthStatus{ loading, authenticated, unauthenticated}
class AuthStateModel {
final AuthStatus status;
final DriverModel? driver;
final String? errorMessage;
const AuthStateModel({required this.status, this.driver, this.errorMessage});

AuthStateModel.loading()
  :status = AuthStatus.loading,
  driver =null,
  errorMessage = null;

  AuthStateModel.authenticated(DriverModel driver)
  : status = AuthStatus.authenticated,
  driver = driver,
  errorMessage = null;

AuthStateModel.unauthenticated()
:status = AuthStatus.unauthenticated,
driver = null,
errorMessage = null;
 
 bool get isAuthenticated => status == AuthStatus.authenticated;
 bool get isLoading =>status == AuthStatus.loading;
}

