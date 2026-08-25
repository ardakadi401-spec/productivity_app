import '../entities/notification_request.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md §4.2
/// "Notification, diğer feature'lar tarafından tüketilen bir altyapı
/// servisi". Bilinçli olarak Settings'e VE hiçbir feature'ın Domain'ine
/// bağımlı değildir — yalnızca kendi planlama/iptal/izin sorumluluğunu taşır
/// (kullanıcı kararı: "Notification Domain/Service Settings'e bağımlı
/// olmasın").
abstract interface class NotificationRepository {
  /// Uygulama açılışında bir kez çağrılır — plugin + zaman dilimi veritabanı
  /// kurulumu.
  Future<void> initialize();

  /// Android 13+ `POST_NOTIFICATIONS` çalışma zamanı izni. `false` dönerse
  /// çağıran taraf (Settings) kullanıcıyı açıkça bilgilendirmelidir (PRD
  /// §11.2) — bu repository kendisi bir izin reddinde asla fırlatmaz/çökmez.
  Future<bool> requestPermission();

  /// Bir izin isteği TETİKLEMEDEN yalnızca mevcut OS izin durumunu sorgular
  /// — kullanıcı bildirimleri uygulama içinde açık bırakıp izni sistem
  /// ayarlarından SONRADAN iptal ederse bunu tespit edip Settings ekranının
  /// kullanıcıyı bilgilendirebilmesi için (PRD §11.2).
  Future<bool> areNotificationsEnabled();

  /// Aynı `id` ile tekrar çağrılırsa öncekini değiştirir (plugin'in kendi
  /// davranışı) — ayrıca bir "cancel-then-schedule" adımına gerek yoktur.
  Future<void> scheduleNotification(NotificationRequest request);

  Future<void> cancelNotification(int id);

  /// Uygulama ön planda/arka planda iken bildirime dokunulduğunda yayınlanan
  /// `payload` akışı (ARCHITECTURE.md §9.4 — router'a programatik
  /// yönlendirme için).
  Stream<String> get notificationTaps;

  /// Uygulama tamamen kapalıyken bir bildirime dokunularak açıldıysa o
  /// başlangıç `payload`'ını döner; aksi halde `null`.
  Future<String?> getLaunchPayload();
}
