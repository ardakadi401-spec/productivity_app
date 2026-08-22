import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/pomodoro/domain/utils/pomodoro_timer_state.dart';

void main() {
  final base = DateTime(2026, 1, 1, 9);

  test('initial() varsayılan 25/5 dakika ile idle/work fazında kurulur', () {
    final state = PomodoroTimerState.initial();

    expect(state.isIdle, isTrue);
    expect(state.phase, PomodoroPhase.work);
    expect(state.workDuration, const Duration(minutes: 25));
    expect(state.breakDuration, const Duration(minutes: 5));
    expect(state.remaining, const Duration(minutes: 25));
    expect(state.completedWorkSessionCount, 0);
  });

  test('started() targetEndTime\'i now + phaseDuration olarak kurar ve running\'e geçer', () {
    final state = PomodoroTimerState.initial().started(sessionId: 's1', now: base);

    expect(state.isRunning, isTrue);
    expect(state.currentSessionId, 's1');
    expect(state.remaining, const Duration(minutes: 25));
    expect(state.targetEndTime, base.add(const Duration(minutes: 25)));
  });

  group('recompute — wall-clock hedef zamana göre yeniden hesaplama', () {
    test('hedef zamandan önce doğru kalan süreyi döner', () {
      final started = PomodoroTimerState.initial().started(sessionId: 's1', now: base);

      final recomputed = started.recompute(base.add(const Duration(minutes: 10)));

      expect(recomputed.remaining, const Duration(minutes: 15));
    });

    test(
      '10+ dakika arka planda kaldıktan sonra (tek atlanmış tick yerine gerçek saat farkı) '
      'doğru kalan süreyi döner — ROADMAP FAZ 11 test noktası',
      () {
        final started = PomodoroTimerState.initial().started(sessionId: 's1', now: base);

        // Uygulama 12 dakika arka planda kaldı, hiç tick atmadı — tek bir
        // `recompute` çağrısı yine de doğru sonucu vermeli (tick sayısına
        // değil wall-clock farkına dayanır).
        final recomputed = started.recompute(base.add(const Duration(minutes: 12)));

        expect(recomputed.remaining, const Duration(minutes: 13));
        expect(recomputed.isRunning, isTrue);
      },
    );

    test('hedef zaman geçtiyse remaining negatif olmaz, sıfıra kenetlenir', () {
      final started = PomodoroTimerState.initial().started(sessionId: 's1', now: base);

      final recomputed = started.recompute(base.add(const Duration(minutes: 40)));

      expect(recomputed.remaining, Duration.zero);
      expect(recomputed.isFinished, isTrue);
    });

    test('idle/paused iken recompute hiçbir şeyi değiştirmez', () {
      final idle = PomodoroTimerState.initial();
      expect(idle.recompute(base.add(const Duration(minutes: 5))), same(idle));

      final paused = idle.started(sessionId: 's1', now: base).paused();
      expect(paused.recompute(base.add(const Duration(minutes: 5))), same(paused));
    });
  });

  group('pause / resume', () {
    test('paused() targetEndTime\'i temizler, remaining son hesaplanan değerde kalır', () {
      final running = PomodoroTimerState.initial()
          .started(sessionId: 's1', now: base)
          .recompute(base.add(const Duration(minutes: 10)));

      final paused = running.paused();

      expect(paused.isPaused, isTrue);
      expect(paused.targetEndTime, isNull);
      expect(paused.remaining, const Duration(minutes: 15));
    });

    test('resumed() yeni bir wall-clock hedefi mevcut remaining üzerinden kurar', () {
      final paused = PomodoroTimerState.initial()
          .started(sessionId: 's1', now: base)
          .recompute(base.add(const Duration(minutes: 10)))
          .paused();

      final resumeTime = base.add(const Duration(hours: 2));
      final resumed = paused.resumed(now: resumeTime);

      expect(resumed.isRunning, isTrue);
      expect(resumed.remaining, const Duration(minutes: 15));
      expect(resumed.targetEndTime, resumeTime.add(const Duration(minutes: 15)));
    });

    test('pause + resume döngüsü, aradan geçen duraklama süresinden bağımsız doğru kalan süreyi korur', () {
      var state = PomodoroTimerState.initial().started(sessionId: 's1', now: base);
      state = state.recompute(base.add(const Duration(minutes: 5))).paused();
      expect(state.remaining, const Duration(minutes: 20));

      // 3 saat duraklatılmış kalsa bile (uygulama arka planda vs.) remaining
      // değişmemeli — yalnızca `running` iken wall-clock akar.
      state = state.resumed(now: base.add(const Duration(hours: 3)));
      expect(state.remaining, const Duration(minutes: 20));

      state = state.recompute(base.add(const Duration(hours: 3, minutes: 2)));
      expect(state.remaining, const Duration(minutes: 18));
    });
  });

  test('resetToIdle() çalışma fazına döner, oturum/hedef temizlenir, sayaç korunur', () {
    final running = PomodoroTimerState.initial()
        .started(sessionId: 's1', now: base)
        .advancedToNextPhase(nextSessionId: 's2', now: base.add(const Duration(minutes: 25)));
    expect(running.completedWorkSessionCount, 1);

    final reset = running.resetToIdle();

    expect(reset.isIdle, isTrue);
    expect(reset.phase, PomodoroPhase.work);
    expect(reset.remaining, reset.workDuration);
    expect(reset.currentSessionId, isNull);
    expect(reset.targetEndTime, isNull);
    expect(reset.completedWorkSessionCount, 1, reason: 'Sıfırlama toplam tamamlanan oturum sayacını sıfırlamamalı');
  });

  group('advancedToNextPhase — otomatik döngü', () {
    test('work bittiğinde break\'e geçer ve completedWorkSessionCount artar', () {
      final afterWork = PomodoroTimerState.initial()
          .started(sessionId: 's1', now: base)
          .advancedToNextPhase(nextSessionId: 's2', now: base.add(const Duration(minutes: 25)));

      expect(afterWork.phase, PomodoroPhase.breakTime);
      expect(afterWork.isRunning, isTrue);
      expect(afterWork.currentSessionId, 's2');
      expect(afterWork.remaining, const Duration(minutes: 5));
      expect(afterWork.completedWorkSessionCount, 1);
    });

    test('break bittiğinde work\'e döner, sayaç bu geçişte artmaz', () {
      final afterWork = PomodoroTimerState.initial()
          .started(sessionId: 's1', now: base)
          .advancedToNextPhase(nextSessionId: 's2', now: base.add(const Duration(minutes: 25)));

      final afterBreak = afterWork.advancedToNextPhase(
        nextSessionId: 's3',
        now: base.add(const Duration(minutes: 30)),
      );

      expect(afterBreak.phase, PomodoroPhase.work);
      expect(afterBreak.remaining, const Duration(minutes: 25));
      expect(afterBreak.completedWorkSessionCount, 1, reason: 'Yalnızca work->break geçişinde artmalı');
    });

    test('tam bir work→break→work döngüsü sonunda ilk çalışma fazıyla aynı süreye döner', () {
      var state = PomodoroTimerState.initial().started(sessionId: 's1', now: base);
      state = state.advancedToNextPhase(nextSessionId: 's2', now: base.add(const Duration(minutes: 25)));
      state = state.advancedToNextPhase(nextSessionId: 's3', now: base.add(const Duration(minutes: 30)));

      expect(state.phase, PomodoroPhase.work);
      expect(state.remaining, const Duration(minutes: 25));
      expect(state.completedWorkSessionCount, 1);
    });
  });
}
