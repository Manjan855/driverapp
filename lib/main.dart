import 'package:driver_app_saferide/core/constants/app_config.dart';
import 'package:driver_app_saferide/core/router/app_router.dart';
import 'package:driver_app_saferide/core/theme/app_theme.dart';
import 'package:driver_app_saferide/core/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main()async {
   WidgetsFlutterBinding.ensureInitialized();
   AppConfig.validate();
   await Firebase.initializeApp();
   
  runApp(const ProviderScope(child: DriverApp(),));
}

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    routerConfig : router,
      
    );
  }
}
