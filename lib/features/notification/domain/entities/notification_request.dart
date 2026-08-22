/// Planlanacak tek bir yerel bildirimin saf Domain temsili — hiçbir feature-
/// özgü bilgi taşımaz (görev/alışkanlık/pomodoro kavramlarını bilmez);
/// çağıran feature (Tasks/Habits/Pomodoro) kendi verisinden bunu üretir.
class NotificationRequest {
  const NotificationRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.payload,
    this.repeat = NotificationRepeatMode.none,
  });

  /// `flutter_local_notifications`'ın kendi `int` id şeması —
  /// `notificationIdFor()` (domain/utils) ile üretilir.
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;

  /// ARCHITECTURE.md §9.4 — dokunulunca gidilecek route path'i (örn.
  /// `/tasks/abc123`).
  final String payload;
  final NotificationRepeatMode repeat;
}

/// - `none`: tek seferlik (görev hatırlatması, Pomodoro bitişi).
/// - `daily`: her gün aynı saatte tekrarlar (alışkanlık — `daily` frekans).
/// - `weekly`: haftanın aynı gününde aynı saatte tekrarlar (alışkanlık —
///   `specificDays` frekansının HER seçili günü için ayrı bir istek).
enum NotificationRepeatMode { none, daily, weekly }
