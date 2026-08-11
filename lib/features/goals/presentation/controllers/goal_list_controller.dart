import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';

/// Goals Screen (SCREENS.md §4.14) — STATE_MANAGEMENT.md §5.1: `family`
/// modifier ile aktif zaman aralığı sekmesine göre, Isar'ın reaktif
/// stream'ine doğrudan abone olan controller.
///
/// `build()`, ROADMAP.md FAZ 8 "dönem sonu otomatik arşivleme"nin iki
/// tetikleyicisinden biridir (diğeri Dashboard'un öne çıkan hedef
/// provider'ı) — Goals Screen her açıldığında süresi geçmiş hedefler
/// taranır (bkz. `CheckExpiredGoalsUseCase` doc yorumu).
class GoalListController extends AutoDisposeFamilyStreamNotifier<List<Goal>, GoalPeriodType?> {
  @override
  Stream<List<Goal>> build(GoalPeriodType? arg) {
    // Tasks yapılandırılmamışsa (örn. testte `taskRepositoryProvider`
    // override edilmemişse) `CheckExpiredGoalsUseCase`'in Tasks Domain
    // bağımlılığı senkron olarak fırlayabilir — bu, Goals listesinin asıl
    // stream'ini engellememeli (Calendar'ın aynı korumasıyla aynı desen).
    try {
      unawaited(ref.read(checkExpiredGoalsUseCaseProvider).call());
    } catch (_) {
      // Sessiz — bir sonraki açılışta tekrar denenir.
    }
    return ref.watch(watchGoalsUseCaseProvider).call(periodType: arg);
  }

  Future<Result<void>> updateManualProgress(String goalId, int progress) async {
    final result = await ref.read(updateGoalProgressUseCaseProvider).call(goalId, progress: progress);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }
}

final goalListControllerProvider = StreamNotifierProvider.autoDispose
    .family<GoalListController, List<Goal>, GoalPeriodType?>(GoalListController.new);
