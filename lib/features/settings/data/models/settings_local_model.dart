import 'package:isar_community/isar.dart';

part 'settings_local_model.g.dart';

/// `users/{uid}.settings` embedded map'inin bildirim alt kümesi — DATABASE.md
/// §2.3. Diğer feature'ların aksine bu koleksiyon **tekil bir satırdır**
/// (cihaz başına tek oturum açık kullanıcı, `id` her zaman sabit `0`) —
/// Firestore tarafında da ayrı bir koleksiyon değil, `users/{uid}` belgesinin
/// `settings` alt-alanıdır (Authentication'ın sahip olduğu belge; Settings
/// yalnızca `settings.*` alt alanlarını `update()` ile kısmi günceller,
/// belgenin tamamına dokunmaz).
@collection
class SettingsLocalModel {
  Id id = 0;

  late bool notificationsEnabled;
  late bool taskRemindersEnabled;
  late bool habitRemindersEnabled;
  late bool pomodoroNotificationsEnabled;

  /// `AppThemeMode.name` değeri (`'light'`/`'dark'`/`'amoled'`/`'system'`) —
  /// Data katmanı dışına `AppThemeMode` enum'u olarak (bkz.
  /// `SettingsRepositoryImpl`) sızdırılmadan önce burada ham string olarak
  /// tutulur (Isar ilkel alan tercihi, diğer alanlarla tutarlı).
  late String themeMode;

  /// Yeni bir Pomodoro oturumunun başlangıç süreleri (dakika) —
  /// `PomodoroTimerController.build()` tarafından yalnızca controller ilk
  /// oluşturulduğunda okunur (bkz. `PomodoroDurationSettings` doc notu).
  late int pomodoroWorkDurationMinutes;
  late int pomodoroBreakDurationMinutes;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late SettingsSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  /// `users/{uid}` belgesine kısmi (dot-path) güncelleme için — belgenin
  /// tamamını değil yalnızca bildirim alt alanlarını taşır.
  Map<String, dynamic> toFirestoreSettingsPatch() {
    return {
      'settings.notificationsEnabled': notificationsEnabled,
      'settings.taskRemindersEnabled': taskRemindersEnabled,
      'settings.habitRemindersEnabled': habitRemindersEnabled,
      'settings.pomodoroNotificationsEnabled': pomodoroNotificationsEnabled,
      'settings.themeMode': themeMode,
      'settings.pomodoroWorkDuration': pomodoroWorkDurationMinutes,
      'settings.pomodoroBreakDuration': pomodoroBreakDurationMinutes,
    };
  }

  static SettingsLocalModel fromFirestoreSettingsMap(Map<String, dynamic> settings) {
    final now = DateTime.now();
    return SettingsLocalModel()
      ..id = 0
      ..notificationsEnabled = settings['notificationsEnabled'] as bool? ?? true
      ..taskRemindersEnabled = settings['taskRemindersEnabled'] as bool? ?? true
      ..habitRemindersEnabled = settings['habitRemindersEnabled'] as bool? ?? true
      ..pomodoroNotificationsEnabled = settings['pomodoroNotificationsEnabled'] as bool? ?? true
      ..themeMode = settings['themeMode'] as String? ?? 'system'
      ..pomodoroWorkDurationMinutes = settings['pomodoroWorkDuration'] as int? ?? 25
      ..pomodoroBreakDurationMinutes = settings['pomodoroBreakDuration'] as int? ?? 5
      ..syncStatus = SettingsSyncStatusLocal.synced
      ..lastSyncedAt = now
      ..localUpdatedAt = now;
  }

  /// Tek satırlık ayar kaydının yalnızca belirtilen alanlarını değiştirip
  /// gerisini korur — `notificationsEnabled` güncellenirken `themeMode`'un
  /// (veya tersi) sessizce sıfırlanmasını/kaybolmasını önler.
  SettingsLocalModel copyWith({
    bool? notificationsEnabled,
    bool? taskRemindersEnabled,
    bool? habitRemindersEnabled,
    bool? pomodoroNotificationsEnabled,
    String? themeMode,
    int? pomodoroWorkDurationMinutes,
    int? pomodoroBreakDurationMinutes,
  }) {
    return SettingsLocalModel()
      ..id = 0
      ..notificationsEnabled = notificationsEnabled ?? this.notificationsEnabled
      ..taskRemindersEnabled = taskRemindersEnabled ?? this.taskRemindersEnabled
      ..habitRemindersEnabled = habitRemindersEnabled ?? this.habitRemindersEnabled
      ..pomodoroNotificationsEnabled = pomodoroNotificationsEnabled ?? this.pomodoroNotificationsEnabled
      ..themeMode = themeMode ?? this.themeMode
      ..pomodoroWorkDurationMinutes = pomodoroWorkDurationMinutes ?? this.pomodoroWorkDurationMinutes
      ..pomodoroBreakDurationMinutes = pomodoroBreakDurationMinutes ?? this.pomodoroBreakDurationMinutes
      ..syncStatus = SettingsSyncStatusLocal.pendingUpdate
      ..localUpdatedAt = DateTime.now();
  }
}

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. `pendingCreate` yok
/// (satır her zaman ya varsayılanla ya da uzaktan tohumlanır); yalnızca
/// kullanıcı bir tercihi değiştirdiğinde `pendingUpdate` olur.
enum SettingsSyncStatusLocal { synced, pendingUpdate, error }
