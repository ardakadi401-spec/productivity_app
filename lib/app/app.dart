import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_provider.dart';
import '../routes/app_router/app_router.dart';

/// Uygulama kök widget'ı — FOLDER_STRUCTURE.md Bölüm 1.1'de tanımlanan
/// `app/` klasörünün sorumluluğu (tema/route kurulumunun toplandığı nokta).
///
/// Provider scope kurulumu bilinçli olarak burada değil, `main.dart`'ta
/// (kök seviyede) yapılır — bkz. ROADMAP.md FAZ 1.5. FAZ 3'ten itibaren
/// `ConsumerWidget`: router `routerProvider` üzerinden gerçek Auth Guard'a
/// bağlı. FAZ 4'ten itibaren tema tercihi de gerçek bir provider'a
/// (`themeModeProvider`) bağlı — bkz. `core/theme/theme_mode_provider.dart`.
class ProductivityApp extends ConsumerWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

    return MaterialApp.router(
      title: 'Productivity App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.resolve(mode, platformBrightness),
      routerConfig: router,
    );
  }
}
