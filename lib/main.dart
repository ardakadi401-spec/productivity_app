import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/reschedule_all_notifications.dart';
import 'app/sync_bootstrap.dart';
import 'config/firebase_config/firebase_options.dart';
import 'core/storage/isar_provider.dart';
import 'core/sync/sync_coordinator.dart';
import 'features/notification/presentation/providers/notification_providers.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'services/database_service/isar_service.dart';

/// Uygulama giriş noktası — FOLDER_STRUCTURE.md Bölüm 1'e göre minimal
/// tutulur; kök widget kurulumu `app/app.dart`'a devredilir.
///
/// `ProviderScope`, tüm Riverpod provider ağacının köküdür (FAZ 1.5).
/// Bu noktadan itibaren, ARCHITECTURE.md Bölüm 5'teki provider tipi karar
/// kriterleri proje genelinde bağlayıcı kuraldır:
///   - Değişmeyen bağımlılık (repository/usecase/service)  → `Provider`
///   - Tek seferlik asenkron okuma                          → `FutureProvider`
///   - Sürekli/canlı veri kaynağı (auth, sync durumu)        → `StreamProvider`
///   - Çok adımlı senkron kullanıcı etkileşimi                → `NotifierProvider`
///   - Asenkron başlangıçlı, sonradan etkileşimle değişen    → `AsyncNotifierProvider`
/// Provider'ların katmanlara göre gruplanması (Data/Domain/Presentation)
/// ve dosya konumları ARCHITECTURE.md Bölüm 5.2 ile FOLDER_STRUCTURE.md
/// Bölüm 13'te tanımlıdır; bu faz henüz hiçbir feature provider'ı
/// oluşturmaz — yalnızca kök scope kurulur.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final isar = await IsarService.open();

  // `ProviderContainer` burada açıkça kurulur (yalnızca `ProviderScope`
  // yerine) — ROADMAP.md FAZ 13'ün "boot sonrası/soğuk başlatmada yeniden
  // planlama" ve bildirim altyapısı başlatma adımlarının widget ağacı
  // kurulmadan ÖNCE, aynı container üzerinden çalışabilmesi için.
  final container = ProviderContainer(
    overrides: [isarProvider.overrideWithValue(isar), ...syncBootstrapOverrides],
  );

  // PRD §8.1 "soğuk başlatma < 2sn" hedefini korumak için `runApp`
  // beklenmeden arka planda başlatılır (non-blocking).
  unawaited(container.read(notificationRepositoryProvider).initialize());
  unawaited(rescheduleAllNotifications(container));

  // FAZ 14 — `SyncCoordinator`'ı erkenden okumak, `ref.listen(
  // connectivityStatusProvider, ...)` bağlantısını (bkz. core/sync/
  // sync_coordinator.dart) uygulama ömrü boyunca aktive eder; okunmazsa
  // provider hiç oluşturulmaz ve coordinator asla dinlemeye başlamaz.
  container.read(syncCoordinatorProvider);

  // Kalıcı tema tercihini (`themeMode`) oturum-içi `themeModeProvider`'a
  // hydrate eden ve sonraki değişiklikleri geri kalıcılığa yazan köprüyü
  // aynı desenle erkenden aktive eder — okunmazsa hiç kurulmaz.
  container.read(themeModeSyncProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ProductivityApp(),
    ),
  );
}
