import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Splash Screen — SCREENS.md §4.1. Ortalanmış marka/logo alanı dışında
/// hiçbir öğe yok; yönlendirme mantığı taşımaz (tamamen router `redirect`'i
/// tarafından, `authStateProvider`'ın durumuna göre yapılır — bkz.
/// `routes/guards/auth_guard.dart`). Bu ekran yalnızca `checking` durumunda
/// görünür kalır.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Productivity App',
              style: AppTypography.display.copyWith(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
