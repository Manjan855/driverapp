import 'package:driver_app_saferide/core/theme/app_typography.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.directions_bus_filled_rounded,
                size: 36,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SafeRide Nepal',
              style: AppTypography.display(size: 22, color: scheme.onSurface),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              strokeWidth: 2.5,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
