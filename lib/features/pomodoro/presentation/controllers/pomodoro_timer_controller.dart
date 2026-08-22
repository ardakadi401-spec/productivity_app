import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../notification/domain/entities/notification_request.dart';
import '../../../notification/domain/utils/notification_id.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/utils/pomodoro_timer_state.dart';
import '../providers/pomodoro_providers.dart';

/// Pomodoro'nun tek-zamanlayıcı doğası nedeniyle görev/alışkanlıktan farklı
/// olarak TEK bir sabit bildirim kimliği kullanılır — her `start`/`resume`/
/// faz geçişinde bu kimlik yeniden planlanır, `pause`/`reset`'te iptal edilir.
final _pomodoroNotificationId = notificationIdFor('pomodoro-session-end');

/// Pomodoro Screen'in zamanlayıcı durumu (SCREENS.md §4.17) — global (auto
/// dispose değil): "arka planda çalışmaya devam eden zamanlayıcı" gereksinimi
/// (PRD §6.10) yalnızca OS seviyeli arka planı değil, kullanıcının ekrandan
/// ayrılıp geri dönmesini de kapsar; bu yüzden state, Pomodoro Screen
/// kapansa bile korunur (Task Detail'e dönüp tekrar Pomodoro'ya girildiğinde
/// zamanlayıcı kaldığı yerden devam eder).
///
/// Saf `Duration`/`DateTime` aritmetiği `PomodoroTimerState` (Domain) içinde
/// yaşar; bu controller yalnızca `Timer.periodic` orkestrasyonu ve
/// repository IO'sunu (oturum oluşturma/tamamlama) ekler.
class PomodoroTimerController extends Notifier<PomodoroTimerState> {
  Timer? _ticker;

  @override
  PomodoroTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return PomodoroTimerState.initial();
  }

  DateTime _now() => ref.read(pomodoroClockProvider)();

  void setTaskId(String? taskId) {
    if (taskId == state.taskId) return;
    state = taskId == null ? state.copyWith(clearTaskId: true) : state.copyWith(taskId: taskId);
    // Zaten devam eden bir oturum varsa (SCREENS.md §4.17 çalışırken görev
    // değiştirme senaryosu), kalıcı kaydı da güncelle — Notes'un `setLink`
    // deseniyle aynı ilke.
    final sessionId = state.currentSessionId;
    if (sessionId != null) {
      unawaited(
        ref.read(linkSessionToTaskUseCaseProvider).call(
              sessionId,
              taskId: taskId,
              clearTaskId: taskId == null,
            ),
      );
    }
  }

  /// Yalnızca boştayken (henüz başlamamışken) özelleştirilebilir.
  void setWorkDuration(Duration duration) {
    if (!state.isIdle) return;
    state = state.copyWith(
      workDuration: duration,
      remaining: state.phase == PomodoroPhase.work ? duration : state.remaining,
    );
  }

  void setBreakDuration(Duration duration) {
    if (!state.isIdle) return;
    state = state.copyWith(breakDuration: duration);
  }

  Future<Result<void>> start() async {
    if (!state.isIdle) return const Ok(null);
    final result = await _createSession(type: PomodoroSessionType.work, taskId: state.taskId);
    return switch (result) {
      Ok(:final value) => _applyStarted(value.sessionId),
      Err(:final failure) => Err(failure),
    };
  }

  Result<void> _applyStarted(String sessionId) {
    state = state.started(sessionId: sessionId, now: _now());
    _startTicker();
    _scheduleEndNotificationSafely();
    return const Ok(null);
  }

  void pause() {
    if (!state.isRunning) return;
    state = state.recompute(_now()).paused();
    _stopTicker();
    _cancelEndNotificationSafely();
  }

  void resume() {
    if (!state.isPaused) return;
    state = state.resumed(now: _now());
    _startTicker();
    _scheduleEndNotificationSafely();
  }

  /// "Sıfırla" — devam eden bir oturum varsa erken/iptal olarak
  /// (`isCompleted: false`) kapatılır, zamanlayıcı çalışma fazına döner.
  Future<Result<void>> reset() async {
    _stopTicker();
    _cancelEndNotificationSafely();
    final sessionId = state.currentSessionId;
    if (sessionId == null) {
      state = state.resetToIdle();
      return const Ok(null);
    }
    final elapsed = state.phaseDuration - state.recompute(_now()).remaining;
    final result = await ref
        .read(completePomodoroSessionUseCaseProvider)
        .call(sessionId, actualDuration: elapsed, isCompleted: false);
    state = state.resetToIdle();
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  /// Her saniyelik tick'te VE tick'ler arasında (örn. widget testlerinde,
  /// gerçek zaman beklemeden) doğrudan çağrılabilir — wall-clock'a göre
  /// yeniden hesaplar, faz bittiyse otomatik bir sonrakine geçer.
  Future<void> checkAndUpdate() async {
    if (!state.isRunning) return;
    final now = _now();
    final recomputed = state.recompute(now);
    if (!recomputed.isFinished) {
      state = recomputed;
      return;
    }
    await _advanceToNextPhase(now);
  }

  Future<void> _advanceToNextPhase(DateTime now) async {
    final finishedSessionId = state.currentSessionId;
    final wasWork = state.phase == PomodoroPhase.work;
    if (finishedSessionId != null) {
      await ref.read(completePomodoroSessionUseCaseProvider).call(
            finishedSessionId,
            actualDuration: state.phaseDuration,
            isCompleted: true,
          );
    }

    final nextType = wasWork ? PomodoroSessionType.breakTime : PomodoroSessionType.work;
    // Mola oturumları bir göreve "ait" değildir (yalnızca çalışma
    // oturumları görev geçmişinde anlamlıdır) — bkz. `taskId` doc yorumu.
    final nextTaskId = wasWork ? null : state.taskId;
    final result = await _createSession(type: nextType, taskId: nextTaskId);
    switch (result) {
      case Ok(:final value):
        state = state.advancedToNextPhase(nextSessionId: value.sessionId, now: now);
        _startTicker();
        _scheduleEndNotificationSafely();
      case Err():
        // Yeni oturum oluşturulamadıysa zamanlayıcıyı boşta bırak — kullanıcı
        // manuel olarak tekrar başlatabilir; sessiz hata (CacheFailure gibi
        // geçici durumlar bir sonraki eylemde tekrar denenir).
        _cancelEndNotificationSafely();
        state = state.resetToIdle();
    }
  }

  /// ROADMAP.md FAZ 13 — Pomodoro; Settings VE Notification Domain'ine tek
  /// yönlü bağımlıdır. `SyncTaskReminderUseCase`/`SyncHabitReminderUseCase`
  /// ile aynı "tercih kontrolü + cross-feature-test-safety" ilkesi, ancak
  /// Pomodoro'nun kendi controller'ında (ayrı bir Domain usecase'e gerek
  /// olmadan) uygulanır — zamanlayıcı mantığı zaten burada merkezileşmiştir.
  Future<void> _scheduleEndNotificationSafely() async {
    final targetEndTime = state.targetEndTime;
    if (targetEndTime == null) return;
    try {
      final preferences = await ref.read(watchNotificationPreferencesUseCaseProvider).call().first;
      if (!preferences.pomodoroAllowed) return;
      final isWork = state.phase == PomodoroPhase.work;
      await ref.read(scheduleNotificationUseCaseProvider).call(
            NotificationRequest(
              id: _pomodoroNotificationId,
              title: isWork ? 'Çalışma Süresi Bitti' : 'Mola Bitti',
              body: isWork ? 'Mola zamanı!' : 'Çalışmaya devam etmeye hazır mısın?',
              scheduledDate: targetEndTime,
              payload: RoutePaths.pomodoro,
            ),
          );
    } catch (_) {
      // Sessiz — bir sonraki tick/eylemde tekrar denenir.
    }
  }

  void _cancelEndNotificationSafely() {
    try {
      unawaited(ref.read(cancelNotificationUseCaseProvider).call(_pomodoroNotificationId).catchError((_) {}));
    } catch (_) {
      // Sessiz.
    }
  }

  Future<Result<PomodoroSession>> _createSession({
    required PomodoroSessionType type,
    required String? taskId,
  }) {
    final repository = ref.read(pomodoroRepositoryProvider);
    final now = _now();
    final duration = type == PomodoroSessionType.work ? state.workDuration : state.breakDuration;
    final session = PomodoroSession(
      sessionId: repository.newSessionId(),
      taskId: taskId,
      type: type,
      plannedDuration: duration,
      actualDuration: Duration.zero,
      startedAt: now,
      isCompleted: false,
    );
    return ref.read(startPomodoroSessionUseCaseProvider).call(session);
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => unawaited(checkAndUpdate()));
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final pomodoroTimerControllerProvider = NotifierProvider<PomodoroTimerController, PomodoroTimerState>(
  PomodoroTimerController.new,
);
