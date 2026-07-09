import 'package:driver_app_saferide/data/models/auth_state_model.dart';
import 'package:driver_app_saferide/data/services/auth_service.dart';
import 'package:driver_app_saferide/data/services/storage_service.dart';
import 'package:driver_app_saferide/providers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
final authServieProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthStateModel>((ref) {
  return AuthNotifier(
    ref.read(authServieProvider),
    ref.read(storageServiceProvider),
  );
});
