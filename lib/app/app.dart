import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/sync/sync_coordinator.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_provider.dart';
import '../features/notification/presentation/providers/notification_providers.dart';
import '../features/settings/presentation/providers/lock_providers.dart';
import '../routes/app_router/app_router.dart';

/// Uygulama kök widget'ı — FOLDER_STRUCTURE.md Bölüm 1.1'de tanımlanan
/// `app/` klasörünün sorumluluğu (tema/route kurulumunun toplandığı nokta).
///
/// Provider scope kurulumu bilinçli olarak burada değil, `main.dart`'ta
/// (kök seviyede) yapılır — bkz. ROADMAP.md FAZ 1.5. FAZ 3'ten itibaren
/// `ConsumerWidget`: router `routerProvider` üzerinden gerçek Auth Guard'a
/// bağlı. FAZ 4'ten itibaren tema tercihi de gerçek bir provider'a
/// (`themeModeProvider`) bağlı — bkz. `core/theme/theme_mode_provider.dart`.
///
/// FAZ 13'ten itibaren `ConsumerStatefulWidget`: bildirime dokunma
/// (`notificationTaps` akışı) VE soğuk başlatma (`getLaunchPayload`) için
/// router'a programatik yönlendirme burada kurulur (ARCHITECTURE.md §9.4).
class ProductivityApp extends ConsumerStatefulWidget {
  const ProductivityApp({super.key});

  @override
  ConsumerState<ProductivityApp> createState() => _ProductivityAppState();
}

class _ProductivityAppState extends ConsumerState<ProductivityApp> with WidgetsBindingObserver {
  StreamSubscription<String>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _wireNotificationNavigation());
    // PRD §5.7 — soğuk başlatmada da kilit aktifse kilit ekranı gösterilmeli
    // ("Uygulama Arka Plana Alınır / Yeniden Açılır" ikisi de tetikleyici).
    unawaited(_checkLockOnStart());
  }

  /// FAZ 14 — app resume tetikleyicisi (ROADMAP.md §3 "app resume" tetikleyici
  /// listesinde offline→online geçişiyle birlikte anılan ikinci kaynak).
  /// `SyncCoordinator.syncIfOnline` zaten yalnızca bilinen son durum
  /// online'sa bir şey yapar — her resume'da koşulsuz senkronizasyon
  /// ZORLANMAZ.
  ///
  /// FAZ 15 — aynı `resumed` sinyali, kilit aktifse kilit ekranını de
  /// tetikler (ARCHITECTURE.md §13.5, PRD §5.7).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(syncCoordinatorProvider).syncIfOnline());
      unawaited(_checkLockOnStart());
    }
  }

  /// Kilit yöntemi yapılandırılmışsa (`LockSettings.isEnabled`)
  /// `appLockStateProvider`'ı `true` yapar — `lockGuardRedirect` bunu görüp
  /// kullanıcıyı `/lock`'a yönlendirir. Kilit yapılandırılmamışsa (varsayılan)
  /// hiçbir şey yapmaz.
  Future<void> _checkLockOnStart() async {
    try {
      final settings = await ref.read(lockSettingsProvider.future);
      if (settings.isEnabled) {
        ref.read(appLockStateProvider.notifier).state = true;
      }
    } catch (_) {
      // Sessiz — okunamazsa güvenli varsayılan (kilitsiz) korunur.
    }
  }

  // Widget testlerinde (bu widget'ı kuran ama `notificationRepositoryProvider`'ı
  // override etmeyen mevcut testler dahil) gerçek `flutter_local_notifications`
  // platform kanalı bulunmaz — try/catch, diğer feature'ların aynı "sessiz
  // kurtarma" ilkesiyle (bkz. `sync_task_reminder_safely.dart`) hem üretimde
  // hem testte çökmeyi önler; bildirim navigasyonu kritik olmayan bir
  // iyileştirmedir.
  Future<void> _wireNotificationNavigation() async {
    try {
      final repository = ref.read(notificationRepositoryProvider);

      _tapSubscription = repository.notificationTaps.listen((payload) {
        if (payload.isNotEmpty) ref.read(routerProvider).push(payload);
      });

      final launchPayload = await repository.getLaunchPayload();
      if (launchPayload != null && launchPayload.isNotEmpty && mounted) {
        ref.read(routerProvider).push(launchPayload);
      }
    } catch (_) {
      // Sessiz.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
