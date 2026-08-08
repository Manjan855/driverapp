import 'dart:convert';
import 'package:driver_app_saferide/data/models/auth_state_model.dart';
import 'package:driver_app_saferide/data/models/driver_model.dart';
import 'package:driver_app_saferide/data/services/auth_service.dart';
import 'package:driver_app_saferide/data/services/storage_service.dart';
// Note: Changed to standard Riverpod import. If your codebase strictly uses
// a legacy migration path, you can switch back to the legacy import.

import 'package:flutter_riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<AuthStateModel> {
  final AuthService _authService;
  final StorageService _storage;

  AuthNotifier(this._authService, this._storage)
    : super(AuthStateModel.loading()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final hasToken = await _storage.hasToken();
      if (!hasToken) {
        state = AuthStateModel.unauthenticated();
        return;
      }

      final driverJson = await _storage.getDriverData();
      if (driverJson != null) {
        final driver = DriverModel.fromJson(jsonDecode(driverJson));
        state = AuthStateModel.authenticated(driver);
      } else {
        await _storage.clearAll();
        state = AuthStateModel.unauthenticated();
      }
    } catch (e) {
      state = AuthStateModel.unauthenticated();
    }
  }
  Future<void> updateDriver(DriverModel updated) async {
    await _storage.saveDriverData(jsonEncode(updated.toJson()));
    state = AuthStateModel.authenticated(updated);
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = AuthStateModel.loading();
    try {
      final response = await _authService.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      // Save data locally
      await _storage.saveToken(response.token);

      // FIX: Replaced .toJS with standard cross-platform serialization (.toJson())
      await _storage.saveDriverData(jsonEncode(response.driver.toJson()));

      state = AuthStateModel.authenticated(response.driver);
    } on AuthException catch (e) {
      state = AuthStateModel(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
    } catch (e) {
      state = AuthStateModel(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Something went wrong. Please try again',
      );
    }
  }

  // FIX: Neatly tucked back inside the AuthNotifier class body
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Catching network errors on logout so the local state clear proceeds anyway
    } finally {
      await _storage.clearAll();
      state = AuthStateModel.unauthenticated();
    }
  }
}
