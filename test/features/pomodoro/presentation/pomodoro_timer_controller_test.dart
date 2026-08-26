import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme_mode.dart';
import 'package:productivity_app/features/notification/domain/entities/notification_request.dart';
import 'package:productivity_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:productivity_app/features/notification/domain/utils/notification_id.dart';
import 'package:productivity_app/features/notification/presentation/providers/notification_providers.dart';
import 'package:productivity_app/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:productivity_app/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:productivity_app/features/pomodoro/domain/utils/pomodoro_timer_state.dart';
import 'package:productivity_app/features/pomodoro/presentation/controllers/pomodoro_timer_controller.dart';
import 'package:productivity_app/features/pomodoro/presentation/providers/pomodoro_providers.dart';
import 'package:productivity_app/features/settings/domain/entities/notification_preferences.dart';
import 'package:productivity_app/features/settings/domain/entities/pomodoro_duration_settings.dart';
import 'package:productivity_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:productivity_app/features/settings/presentation/providers/settings_providers.dart';

/// Kontrol edilebilir sahte saat — ROADMAP FAZ 11'in wall-clock
/// yaklaşımını gerçek zaman beklemeden (25 dakika `Future.delayed` yerine)
/// test etmeyi sağlar.
class _FakeClock {
  DateTime current = DateTime(2026, 1, 1, 9);
  DateTime call() => current;
  void advance(Duration d) => current = current.add(d);
}

class _FakePomodoroRepository implements PomodoroRepository {
  final Map<String, PomodoroSession> sessions = {};
  int _counter = 0;

  @override
  String newSessionId() => 'session-${_counter++}';

  @override
  Stream<List<PomodoroSession>> watchSessionsByTask(String taskId) =>
      Stream.value(sessions.values.where((s) => s.taskId == taskId).toList());

  @override
  Future<Result<PomodoroSession>> createSession(PomodoroSession session) async {
    sessions[session.sessionId] = session;
    return Ok(session);
  }

  @override
  Future<Result<PomodoroSession>> completeSession(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  }) async {
    final existing = sessions[sessionId]!;
    final updated = existing.copyWith(actualDuration: actualDuration, isCompleted: isCompleted);
    sessions[sessionId] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<PomodoroSession>> linkSessionToTask(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  }) async {
    final existing = sessions[sessionId]!;
    final updated = existing.copyWith(taskId: taskId, clearTaskId: clearTaskId);
    sessions[sessionId] = updated;
    return Ok(updated);
  }

  @override
  Future<List<PomodoroSession>> getSessionsInRange(DateTime start, DateTime end) async {
    return sessions.values
        .where((s) => !s.startedAt.isBefore(start) && !s.startedAt.isAfter(end))
        .toList();
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  NotificationPreferences preferences = NotificationPreferences.defaults;
  PomodoroDurationSettings pomodoroDurations = PomodoroDurationSettings.defaults;

  @override
  Stream<NotificationPreferences> watchNotificationPreferences() => Stream.value(preferences);

  @override
  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences) =>
      throw UnimplementedError();
  @override
  Stream<AppThemeMode> watchThemeMode() => Stream.value(AppThemeMode.system);
  @override
  Future<Result<void>> updateThemeMode(AppThemeMode mode) => throw UnimplementedError();

  /// Ayarlandığında `watchPomodoroDurationSettings()`, bu tamamlanana kadar
  /// hiçbir değer yaymaz — hydration'ın `start()`'la yarışını
  /// deterministik hale getirmek için (bkz. "çalışan zamanlayıcı
  /// bozulmaz" testi).
  Completer<void>? pomodoroHydrationGate;

  @override
  Stream<PomodoroDurationSettings> watchPomodoroDurationSettings() async* {
    final gate = pomodoroHydrationGate;
    if (gate != null) await gate.future;
    yield pomodoroDurations;
  }

  @override
  Future<Result<void>> updatePomodoroDurationSettings(PomodoroDurationSettings settings) =>
      throw UnimplementedError();
}

class _FakeNotificationRepository implements NotificationRepository {
  final List<NotificationRequest> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool> areNotificationsEnabled() async => true;
  @override
  Stream<String> get notificationTaps => const Stream.empty();
  @override
  Future<String?> getLaunchPayload() async => null;

  @override
  Future<void> scheduleNotification(NotificationRequest request) async {
    scheduled.add(request);
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}

final _pomodoroNotificationId = notificationIdFor('pomodoro-session-end');

void main() {
  late _FakeClock clock;
  late _FakePomodoroRepository repository;
  late _FakeSettingsRepository settingsRepo;
  late _FakeNotificationRepository notificationRepo;
  late ProviderContainer container;

  setUp(() {
    clock = _FakeClock();
    repository = _FakePomodoroRepository();
    settingsRepo = _FakeSettingsRepository();
    notificationRepo = _FakeNotificationRepository();
    container = ProviderContainer(
      overrides: [
        pomodoroRepositoryProvider.overrideWithValue(repository),
        pomodoroClockProvider.overrideWithValue(clock.call),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        notificationRepositoryProvider.overrideWithValue(notificationRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  PomodoroTimerController controller() => container.read(pomodoroTimerControllerProvider.notifier);
  PomodoroTimerState state() => container.read(pomodoroTimerControllerProvider);

  test(
    'start() anında yerele pending kayıt yazar — uygulama hemen kill edilse bile veri kaybı olmaz '
    '(ROADMAP FAZ 11 "kill-safety" mitigasyonu)',
    () async {
      final result = await controller().start();

      expect(result, isA<Ok<void>>());
      expect(repository.sessions, hasLength(1));
      final saved = repository.sessions.values.single;
      expect(saved.isCompleted, isFalse);
      expect(saved.type, PomodoroSessionType.work);
      expect(state().isRunning, isTrue);
    },
  );

  test('start() zaten idle değilse (running/paused) tekrar çağrılırsa no-op olur', () async {
    await controller().start();
    final sessionCountAfterFirstStart = repository.sessions.length;

    await controller().start();

    expect(repository.sessions.length, sessionCountAfterFirstStart);
  });

  test(
    '10+ dakika arka planda kaldıktan sonra checkAndUpdate() doğru kalan süreyi yansıtır '
    '(gerçek zaman beklemeden, ROADMAP FAZ 11 test noktası)',
    () async {
      await controller().start();

      clock.advance(const Duration(minutes: 12));
      await controller().checkAndUpdate();

      expect(state().remaining, const Duration(minutes: 13));
      expect(state().isRunning, isTrue);
    },
  );

  test('faz süresi tamamen dolduğunda otomatik olarak break fazına geçer ve yeni oturum oluşturur', () async {
    await controller().start();
    final workSessionId = state().currentSessionId;

    clock.advance(const Duration(minutes: 25));
    await controller().checkAndUpdate();

    expect(state().phase, PomodoroPhase.breakTime);
    expect(state().isRunning, isTrue);
    expect(state().remaining, const Duration(minutes: 5));
    expect(state().completedWorkSessionCount, 1);
    expect(repository.sessions[workSessionId]?.isCompleted, isTrue);
    expect(repository.sessions[workSessionId]?.actualDuration, const Duration(minutes: 25));
    expect(repository.sessions, hasLength(2));
  });

  test('mola bittiğinde otomatik olarak work fazına döner, görev bağlantısı korunur', () async {
    controller().setTaskId('t1');
    await controller().start();
    clock.advance(const Duration(minutes: 25));
    await controller().checkAndUpdate();
    expect(state().phase, PomodoroPhase.breakTime);

    clock.advance(const Duration(minutes: 5));
    await controller().checkAndUpdate();

    expect(state().phase, PomodoroPhase.work);
    expect(state().remaining, const Duration(minutes: 25));
    final newWorkSessionId = state().currentSessionId;
    expect(repository.sessions[newWorkSessionId]?.taskId, 't1');
  });

  test('mola oturumları göreve bağlanmaz (yalnızca çalışma oturumları görev geçmişinde anlamlıdır)', () async {
    controller().setTaskId('t1');
    await controller().start();
    clock.advance(const Duration(minutes: 25));
    await controller().checkAndUpdate();

    final breakSessionId = state().currentSessionId;
    expect(repository.sessions[breakSessionId]?.taskId, isNull);
  });

  group('pause / resume', () {
    test('pause() ticker\'ı durdurur, remaining değişmeden kalır', () async {
      await controller().start();
      clock.advance(const Duration(minutes: 5));
      await controller().checkAndUpdate();
      expect(state().remaining, const Duration(minutes: 20));

      controller().pause();
      expect(state().isPaused, isTrue);

      // Duraklatılmışken saat ilerlese bile remaining değişmemeli.
      clock.advance(const Duration(hours: 1));
      expect(state().remaining, const Duration(minutes: 20));
    });

    test('resume() kaldığı yerden devam eder, duraklama süresinden etkilenmez', () async {
      await controller().start();
      clock.advance(const Duration(minutes: 5));
      await controller().checkAndUpdate();
      controller().pause();

      clock.advance(const Duration(hours: 2));
      controller().resume();
      expect(state().isRunning, isTrue);
      expect(state().remaining, const Duration(minutes: 20));

      clock.advance(const Duration(minutes: 1));
      await controller().checkAndUpdate();
      expect(state().remaining, const Duration(minutes: 19));
    });

    test('idle iken pause() no-op, running değilken resume() no-op', () {
      controller().pause();
      expect(state().isIdle, isTrue);

      controller().resume();
      expect(state().isIdle, isTrue);
    });
  });

  group('reset()', () {
    test('devam eden oturumu erken/iptal (isCompleted:false) olarak kapatır, doğru actualDuration ile', () async {
      await controller().start();
      final sessionId = state().currentSessionId!;
      clock.advance(const Duration(minutes: 7));
      await controller().checkAndUpdate();

      final result = await controller().reset();

      expect(result, isA<Ok<void>>());
      expect(repository.sessions[sessionId]?.isCompleted, isFalse);
      expect(repository.sessions[sessionId]?.actualDuration, const Duration(minutes: 7));
      expect(state().isIdle, isTrue);
      expect(state().phase, PomodoroPhase.work);
      expect(state().remaining, const Duration(minutes: 25));
    });

    test('hiç oturum yokken (idle) reset() güvenle no-op çalışır', () async {
      final result = await controller().reset();
      expect(result, isA<Ok<void>>());
      expect(state().isIdle, isTrue);
    });
  });

  group('görev bağlama', () {
    test('idle iken setTaskId yalnızca state\'i günceller, repository çağrılmaz', () {
      controller().setTaskId('t1');
      expect(state().taskId, 't1');
      expect(repository.sessions, isEmpty);
    });

    test('çalışırken setTaskId hem state\'i hem kalıcı kaydı günceller', () async {
      await controller().start();
      final sessionId = state().currentSessionId!;

      controller().setTaskId('t1');
      // linkSessionToTask fire-and-forget (unawaited) — mikro görev
      // kuyruğunun tamamlanmasını bekle.
      await Future<void>.delayed(Duration.zero);

      expect(state().taskId, 't1');
      expect(repository.sessions[sessionId]?.taskId, 't1');
    });
  });

  test('setWorkDuration yalnızca idle iken uygulanır, running iken yok sayılır', () async {
    controller().setWorkDuration(const Duration(minutes: 50));
    expect(state().workDuration, const Duration(minutes: 50));
    expect(state().remaining, const Duration(minutes: 50));

    await controller().start();
    controller().setWorkDuration(const Duration(minutes: 10));
    expect(state().workDuration, const Duration(minutes: 50), reason: 'Çalışırken süre değişmemeli');
  });

  group('kalıcı Pomodoro varsayılan süreleri (Settings Screen)', () {
    test('build() sonrası kalıcı ayarlardaki özel süreler hydrate edilir', () async {
      settingsRepo.pomodoroDurations = const PomodoroDurationSettings(workMinutes: 45, breakMinutes: 15);

      controller(); // build() tetiklenir, hydration unawaited başlar.
      await Future<void>.delayed(Duration.zero);

      expect(state().workDuration, const Duration(minutes: 45));
      expect(state().breakDuration, const Duration(minutes: 15));
      expect(state().remaining, const Duration(minutes: 45));
    });

    test(
      'hydration tamamlanmadan önce setWorkDuration çağrılırsa kullanıcının seçimi ezilmez',
      () async {
        settingsRepo.pomodoroDurations = const PomodoroDurationSettings(workMinutes: 45, breakMinutes: 15);

        controller().setWorkDuration(const Duration(minutes: 10));
        await Future<void>.delayed(Duration.zero);

        expect(state().workDuration, const Duration(minutes: 10));
      },
    );

    test('hydration tamamlanmadan önce oturum başlatılırsa çalışan zamanlayıcı bozulmaz', () async {
      // Hydration'ı bilerek kapıda bekletiyoruz ki `start()`'ın state'i
      // `running`e taşıması KESİN olarak hydration'ın state'i okumasından
      // ÖNCE gerçekleşsin — gerçek yarış koşulunu iki olası sıralamadan
      // birine (aksi halde flaky olurdu) deterministik şekilde sabitler.
      final gate = Completer<void>();
      settingsRepo.pomodoroHydrationGate = gate;
      settingsRepo.pomodoroDurations = const PomodoroDurationSettings(workMinutes: 45, breakMinutes: 15);

      await controller().start();
      expect(state().isRunning, isTrue);

      gate.complete();
      await Future<void>.delayed(Duration.zero);

      expect(state().workDuration, const Duration(minutes: 25), reason: 'Hydration çalışan oturumu değiştirmemeli');
      expect(state().isRunning, isTrue);
    });
  });

  group('bildirim planlama/iptal (ROADMAP FAZ 13)', () {
    // `_scheduleEndNotificationSafely` fire-and-forget (unawaited) çağrılır —
    // her eylemden sonra mikro görev kuyruğunun tamamlanmasını bekle.
    Future<void> flush() => Future<void>.delayed(Duration.zero);

    test('start() faz bitiş bildirimini sabit pomodoro kimliğiyle planlar', () async {
      await controller().start();
      await flush();

      expect(notificationRepo.scheduled, hasLength(1));
      final request = notificationRepo.scheduled.single;
      expect(request.id, _pomodoroNotificationId);
      expect(request.title, 'Çalışma Süresi Bitti');
    });

    test('pause() planlanmış bildirimi iptal eder', () async {
      await controller().start();
      await flush();

      controller().pause();
      await flush();

      expect(notificationRepo.cancelled, contains(_pomodoroNotificationId));
    });

    test('resume() bildirimi kaldığı yerden yeniden planlar', () async {
      await controller().start();
      await flush();
      controller().pause();
      await flush();
      notificationRepo.scheduled.clear();

      controller().resume();
      await flush();

      expect(notificationRepo.scheduled, hasLength(1));
      expect(notificationRepo.scheduled.single.id, _pomodoroNotificationId);
    });

    test('reset() devam eden bildirimi iptal eder', () async {
      await controller().start();
      await flush();

      await controller().reset();
      await flush();

      expect(notificationRepo.cancelled, contains(_pomodoroNotificationId));
    });

    test('faz otomatik ilerlediğinde (work→break) yeni faz için bildirim yeniden planlanır', () async {
      await controller().start();
      await flush();

      clock.advance(const Duration(minutes: 25));
      await controller().checkAndUpdate();
      await flush();

      expect(notificationRepo.scheduled.last.title, 'Mola Bitti');
    });

    test('pomodoroAllowed kapalıysa start() bildirim planlamaz', () async {
      settingsRepo.preferences = const NotificationPreferences(
        notificationsEnabled: true,
        taskRemindersEnabled: true,
        habitRemindersEnabled: true,
        pomodoroNotificationsEnabled: false,
      );

      await controller().start();
      await flush();

      expect(notificationRepo.scheduled, isEmpty);
    });

    test('genel bildirim anahtarı kapalıysa start() bildirim planlamaz', () async {
      settingsRepo.preferences = const NotificationPreferences(
        notificationsEnabled: false,
        taskRemindersEnabled: true,
        habitRemindersEnabled: true,
        pomodoroNotificationsEnabled: true,
      );

      await controller().start();
      await flush();

      expect(notificationRepo.scheduled, isEmpty);
    });
  });
}
