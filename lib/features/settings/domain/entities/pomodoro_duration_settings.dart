/// DATABASE.md §2.3 — `users/{uid}.settings.pomodoroWorkDuration`/
/// `pomodoroBreakDuration` alanlarının Domain katmanı saf temsili.
/// Yalnızca YENİ bir Pomodoro oturumu (Pomodoro Screen ilk açıldığında/
/// `PomodoroTimerController.build()`'da) başlangıç süresi olarak okunur —
/// `_DurationPresets`'in oturum-içi geçici geçersiz kılması (yalnızca
/// boştayken, kalıcı olmayan) ile karıştırılmamalıdır.
class PomodoroDurationSettings {
  const PomodoroDurationSettings({required this.workMinutes, required this.breakMinutes});

  final int workMinutes;
  final int breakMinutes;

  /// `AppUserModel.newProfile()` ile birebir aynı varsayılanlar.
  static const defaults = PomodoroDurationSettings(workMinutes: 25, breakMinutes: 5);

  PomodoroDurationSettings copyWith({int? workMinutes, int? breakMinutes}) {
    return PomodoroDurationSettings(
      workMinutes: workMinutes ?? this.workMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
    );
  }
}
