import '../../../goals/domain/usecases/watch_goals_usecase.dart';
import '../entities/calendar_event.dart';

/// Calendar Screen'in günlük ajanda bölümü (SCREENS.md §4.13 "Goal Card —
/// o gün bitiyorsa") — hedefler, dönemleri boyunca her günde değil, yalnızca
/// `periodEndDate`'in düştüğü günde ajandada gösterilir (bir haftalık/aylık
/// hedefi her gün tekrar tekrar listelemek ROADMAP.md FAZ 7 riskindeki
/// "aşırı kalabalık" sorununu doğurur). Goals'ın dışa açık
/// `WatchGoalsUseCase`'i üzerinden, doğrudan Data erişimi olmadan
/// (ARCHITECTURE.md §4.1 örneğiyle aynı desen).
class GetGoalsByDateUseCase {
  const GetGoalsByDateUseCase(this._watchGoalsUseCase);

  final WatchGoalsUseCase _watchGoalsUseCase;

  Stream<List<CalendarEvent>> call(DateTime date) {
    return _watchGoalsUseCase().map(
      (goals) => goals
          .where((g) => _isSameDay(g.periodEndDate, date))
          .map(CalendarEvent.fromGoal)
          .toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
