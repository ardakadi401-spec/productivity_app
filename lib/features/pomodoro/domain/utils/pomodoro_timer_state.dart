/// Pomodoro zamanlayıcısının saf durum makinesi — Flutter/Riverpod/`Timer`
/// bağımsız, yalnızca `Duration`/`DateTime` aritmetiği (ROADMAP.md FAZ 11
/// "wall-clock hedef zaman" mitigasyonu). Presentation katmanındaki
/// `PomodoroTimerController` bu saf geçişleri repository IO'suyla
/// orkestre eder — `CalculateStreakUseCase`/`GoalPeriodCalculator` ile aynı
/// "saf Domain algoritması" ilkesi.
library;

enum PomodoroPhase { work, breakTime }

enum PomodoroRunStatus { idle, running, paused }

class PomodoroTimerState {
  const PomodoroTimerState({
    this.status = PomodoroRunStatus.idle,
    this.phase = PomodoroPhase.work,
    required this.workDuration,
    required this.breakDuration,
    required this.remaining,
    this.targetEndTime,
    this.taskId,
    this.currentSessionId,
    this.completedWorkSessionCount = 0,
  });

  factory PomodoroTimerState.initial({
    Duration workDuration = const Duration(minutes: 25),
    Duration breakDuration = const Duration(minutes: 5),
  }) {
    return PomodoroTimerState(
      workDuration: workDuration,
      breakDuration: breakDuration,
      remaining: workDuration,
    );
  }

  final PomodoroRunStatus status;
  final PomodoroPhase phase;
  final Duration workDuration;
  final Duration breakDuration;

  /// Son hesaplanan kalan süre — yalnızca `recompute`/geçiş metotlarınca
  /// güncellenir (STATE_MANAGEMENT.md §12.1/§12.2 — Presentation'da bu tek
  /// alana `select` ile izole abone olunur).
  final Duration remaining;

  /// `running` iken sabit wall-clock hedefi; `idle`/`paused` iken `null`.
  final DateTime? targetEndTime;
  final String? taskId;
  final String? currentSessionId;
  final int completedWorkSessionCount;

  Duration get phaseDuration => phase == PomodoroPhase.work ? workDuration : breakDuration;
  bool get isRunning => status == PomodoroRunStatus.running;
  bool get isPaused => status == PomodoroRunStatus.paused;
  bool get isIdle => status == PomodoroRunStatus.idle;
  bool get isFinished => isRunning && remaining <= Duration.zero;

  PomodoroTimerState copyWith({
    PomodoroRunStatus? status,
    PomodoroPhase? phase,
    Duration? workDuration,
    Duration? breakDuration,
    Duration? remaining,
    DateTime? targetEndTime,
    bool clearTargetEndTime = false,
    String? taskId,
    bool clearTaskId = false,
    String? currentSessionId,
    bool clearCurrentSessionId = false,
    int? completedWorkSessionCount,
  }) {
    return PomodoroTimerState(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      remaining: remaining ?? this.remaining,
      targetEndTime: clearTargetEndTime ? null : (targetEndTime ?? this.targetEndTime),
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      currentSessionId: clearCurrentSessionId ? null : (currentSessionId ?? this.currentSessionId),
      completedWorkSessionCount: completedWorkSessionCount ?? this.completedWorkSessionCount,
    );
  }

  /// Wall-clock hedef zamana göre kalan süreyi yeniden hesaplar — her
  /// saniyelik tick'te VE arka plandan öne dönüşte çağrılır. `targetEndTime`
  /// yalnızca start/resume'da yeniden kurulur; bu sayede kaç tick
  /// atlanmış olursa olsun (Doze/arka plan askıya alma) sonuç her zaman
  /// doğrudur — atlanan tick sayısına değil, gerçek saate göre hesaplanır.
  PomodoroTimerState recompute(DateTime now) {
    if (!isRunning || targetEndTime == null) return this;
    final diff = targetEndTime!.difference(now);
    return copyWith(remaining: diff.isNegative ? Duration.zero : diff);
  }

  /// Boştan (veya sıfırlanmış durumdan) bir oturum başlatır.
  PomodoroTimerState started({required String sessionId, required DateTime now}) {
    return copyWith(
      status: PomodoroRunStatus.running,
      remaining: phaseDuration,
      targetEndTime: now.add(phaseDuration),
      currentSessionId: sessionId,
    );
  }

  PomodoroTimerState paused() {
    return copyWith(status: PomodoroRunStatus.paused, clearTargetEndTime: true);
  }

  PomodoroTimerState resumed({required DateTime now}) {
    return copyWith(status: PomodoroRunStatus.running, targetEndTime: now.add(remaining));
  }

  /// "Sıfırla" eylemi — her zaman çalışma fazına döner; görev seçimi ve
  /// toplam tamamlanan oturum sayacı korunur (yalnızca aktif zamanlayıcı
  /// sıfırlanır).
  PomodoroTimerState resetToIdle() {
    return copyWith(
      status: PomodoroRunStatus.idle,
      phase: PomodoroPhase.work,
      remaining: workDuration,
      clearTargetEndTime: true,
      clearCurrentSessionId: true,
    );
  }

  /// Bir faz doğal olarak bitince bir sonraki faza otomatik geçiş
  /// (SCREENS.md §4.17 "otomatik olarak mola/çalışma döngüsüne geçilir").
  PomodoroTimerState advancedToNextPhase({required String nextSessionId, required DateTime now}) {
    final wasWork = phase == PomodoroPhase.work;
    final nextPhase = wasWork ? PomodoroPhase.breakTime : PomodoroPhase.work;
    final nextDuration = nextPhase == PomodoroPhase.work ? workDuration : breakDuration;
    return copyWith(
      phase: nextPhase,
      status: PomodoroRunStatus.running,
      remaining: nextDuration,
      targetEndTime: now.add(nextDuration),
      currentSessionId: nextSessionId,
      completedWorkSessionCount: wasWork ? completedWorkSessionCount + 1 : completedWorkSessionCount,
    );
  }
}
