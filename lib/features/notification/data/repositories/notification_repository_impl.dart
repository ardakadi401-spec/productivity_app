import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/notification_request.dart';
import '../../domain/repositories/notification_repository.dart';

/// `flutter_local_notifications` + `timezone` sarmalayıcısı — ARCHITECTURE.md
/// §6.2 "Service" katmanı prensibiyle aynı ilke (ham SDK'yı Domain
/// sözleşmesinin arkasına gizler). Android VE iOS için etkin başlatılır.
/// iOS'ta izin, Android'deki gibi `initialize()` sırasında OTOMATİK
/// istenmez (`DarwinInitializationSettings.requestXPermission: false`) —
/// kullanıcı Ayarlar'da "Bildirimleri Etkinleştir"i açtığında
/// `requestPermission()` üzerinden, Android'le birebir aynı akışla istenir
/// (canlı iOS cihaz testinde bulunan gerçek hata: `iOS:` ayarı hiç
/// verilmediğinden iOS hiçbir zaman izin istemiyordu — Ayarlar
/// uygulamasında "Bildirimler" bölümü bile hiç oluşmuyordu).
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final _tapController = StreamController<String>.broadcast();
  bool _initialized = false;

  static const _channelId = 'reminders';
  static const _channelName = 'Hatırlatmalar';
  static const _channelDescription = 'Görev, alışkanlık ve pomodoro hatırlatmaları';

  @override
  Stream<String> get notificationTaps => _tapController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    try {
      final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimeZone.identifier));
    } catch (_) {
      // Cihaz zaman dilimi çözülemezse UTC'ye düşülür — planlama yine de
      // çalışır, yalnızca saat gösterimi cihaz yereliyle örtüşmeyebilir
      // (nadir bir kurtarma yolu, ana akış değil).
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Android'deki `requestPermission()` ile aynı "kullanıcı Ayarlar'dan
    // açana kadar istenmez" davranışını eşlemek için üçü de false —
    // varsayılan (true) ile `initialize()` iOS'ta izin dialogunu hemen,
    // kullanıcı hiçbir şeye dokunmadan açılışta gösterirdi.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) _tapController.add(payload);
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @override
  Future<bool> requestPermission() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      try {
        final granted = await android.requestNotificationsPermission();
        // Android 12+ tam zamanlı alarm izni ayrıca istenir — reddedilirse
        // `zonedSchedule` yine de `inexact` moda düşerek çalışmaya devam
        // eder (aşağıda `scheduleNotification`), bu yüzden sonucu genel
        // izin durumunu belirlemez.
        await android.requestExactAlarmsPermission();
        return granted ?? false;
      } catch (_) {
        return false;
      }
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      try {
        final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      try {
        return await android.areNotificationsEnabled() ?? false;
      } catch (_) {
        return false;
      }
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      try {
        final options = await ios.checkPermissions();
        return options?.isEnabled ?? false;
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  @override
  Future<void> scheduleNotification(NotificationRequest request) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final scheduledTz = tz.TZDateTime.from(request.scheduledDate, tz.local);
    // Geçmişte kalmış bir zaman planlanırsa plugin hata fırlatır — tek
    // seferlik istekler için bu durum sessizce atlanır (çağıran taraf zaten
    // yalnızca gelecekteki tarihler için planlama yapar, ama savunmacı
    // kalınır).
    if (request.repeat == NotificationRepeatMode.none && !scheduledTz.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _plugin.zonedSchedule(
      id: request.id,
      title: request.title,
      body: request.body,
      scheduledDate: scheduledTz,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: switch (request.repeat) {
        NotificationRepeatMode.none => null,
        NotificationRepeatMode.daily => DateTimeComponents.time,
        NotificationRepeatMode.weekly => DateTimeComponents.dayOfWeekAndTime,
      },
      payload: request.payload,
    );
  }

  @override
  Future<void> cancelNotification(int id) => _plugin.cancel(id: id);

  @override
  Future<String?> getLaunchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }
}
