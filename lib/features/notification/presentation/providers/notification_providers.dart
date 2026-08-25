import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/cancel_notification_usecase.dart';
import '../../domain/usecases/request_notification_permission_usecase.dart';
import '../../domain/usecases/schedule_notification_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final _flutterLocalNotificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(_flutterLocalNotificationsPluginProvider));
});

// --- Domain katmanı (UseCase provider'ları) ---

final scheduleNotificationUseCaseProvider = Provider<ScheduleNotificationUseCase>((ref) {
  return ScheduleNotificationUseCase(ref.watch(notificationRepositoryProvider));
});

final cancelNotificationUseCaseProvider = Provider<CancelNotificationUseCase>((ref) {
  return CancelNotificationUseCase(ref.watch(notificationRepositoryProvider));
});

final requestNotificationPermissionUseCaseProvider = Provider<RequestNotificationPermissionUseCase>((ref) {
  return RequestNotificationPermissionUseCase(ref.watch(notificationRepositoryProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ı ---

/// Settings Screen'in "izin sistem ayarlarından sonradan iptal edildi mi"
/// denetimi için — bir izin İSTEĞİ TETİKLEMEZ, yalnızca mevcut OS durumunu
/// okur. `autoDispose`: ekrandan her çıkışta temizlenir, her yeniden girişte
/// güncel durum tazelenir.
final osNotificationsEnabledProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(notificationRepositoryProvider).areNotificationsEnabled();
});
