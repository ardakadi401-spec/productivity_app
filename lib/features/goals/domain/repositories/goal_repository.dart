import '../../../../core/errors/result.dart';
import '../entities/goal.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
///
/// Okuma metotları `Stream` döner (STATE_MANAGEMENT.md §5.2 — Isar üzerinden
/// reaktif). Yazma metotları ARCHITECTURE.md §7.3 gereği `Result` döner.
abstract interface class GoalRepository {
  /// Ağ çağrısı yapmadan yeni bir hedef ID'si tahsis eder (Firestore
  /// client-side doküman ID — offline de çalışır).
  String newGoalId();

  /// `periodType` verilmezse tüm zaman ölçeklerindeki hedefleri (aktif +
  /// geçmiş — PRD Bölüm 6.8 "geçmiş hedeflerin görüntülenebilmesi") döner.
  Stream<List<Goal>> watchGoals({GoalPeriodType? periodType});

  Stream<Goal?> watchGoal(String goalId);

  Future<Result<Goal>> createGoal(Goal goal);

  Future<Result<Goal>> updateGoal(Goal goal);

  /// SCREENS.md §4.14 "kart üstünden hızlı yüzde güncelleme" —
  /// `progressType: manual` hedefler için.
  Future<Result<Goal>> setManualProgress(String goalId, {required int progress});

  /// Dönem sonu otomatik arşivleme (`CheckExpiredGoalsUseCase` tarafından
  /// çağrılır).
  Future<Result<Goal>> setGoalStatus(String goalId, {required GoalStatus status});
}
