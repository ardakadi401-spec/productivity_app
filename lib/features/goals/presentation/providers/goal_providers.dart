import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/datasources/local/goal_local_datasource.dart';
import '../../data/datasources/remote/goal_remote_datasource.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/check_expired_goals_usecase.dart';
import '../../domain/usecases/create_goal_usecase.dart';
import '../../domain/usecases/update_goal_progress_usecase.dart';
import '../../domain/usecases/update_goal_usecase.dart';
import '../../domain/usecases/watch_goal_usecase.dart';
import '../../domain/usecases/watch_goals_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final goalLocalDatasourceProvider = Provider<GoalLocalDatasource>((ref) {
  return GoalLocalDatasource(ref.watch(isarProvider));
});

final goalRemoteDatasourceProvider = Provider<GoalRemoteDatasource>((ref) {
  return GoalRemoteDatasource();
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(
    ref.watch(goalLocalDatasourceProvider),
    ref.watch(goalRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchGoalsUseCaseProvider = Provider<WatchGoalsUseCase>((ref) {
  return WatchGoalsUseCase(ref.watch(goalRepositoryProvider));
});

final watchGoalUseCaseProvider = Provider<WatchGoalUseCase>((ref) {
  return WatchGoalUseCase(ref.watch(goalRepositoryProvider));
});

final createGoalUseCaseProvider = Provider<CreateGoalUseCase>((ref) {
  return CreateGoalUseCase(ref.watch(goalRepositoryProvider));
});

final updateGoalUseCaseProvider = Provider<UpdateGoalUseCase>((ref) {
  return UpdateGoalUseCase(ref.watch(goalRepositoryProvider));
});

final updateGoalProgressUseCaseProvider = Provider<UpdateGoalProgressUseCase>((ref) {
  return UpdateGoalProgressUseCase(ref.watch(goalRepositoryProvider));
});

/// ARCHITECTURE.md §4 — Goals, Tasks Domain'ine tek yönlü, salt okunur
/// bağımlıdır (yalnızca `linkedTasks` tipi hedeflerin başarı durumunu
/// belirlemek için).
final checkExpiredGoalsUseCaseProvider = Provider<CheckExpiredGoalsUseCase>((ref) {
  return CheckExpiredGoalsUseCase(ref.watch(goalRepositoryProvider), ref.watch(watchTasksUseCaseProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ları ---

/// Goals Screen listesi (SCREENS.md §4.14) — zaman aralığı sekmesi
/// değiştiğinde yeniden dinlenir.
final goalListProvider = StreamProvider.autoDispose.family<List<Goal>, GoalPeriodType?>((
  ref,
  periodType,
) {
  return ref.watch(watchGoalsUseCaseProvider).call(periodType: periodType);
});

final goalDetailProvider = StreamProvider.autoDispose.family<Goal?, String>((ref, goalId) {
  return ref.watch(watchGoalUseCaseProvider).call(goalId);
});

/// Bir hedefin CANLI ilerleme oranı (0–1) — `progressType: manual` için
/// doğrudan `manualProgress`, `linkedTasks` için Tasks'ın canlı stream'inden
/// (Projects'in `projectTaskStatsProvider`'ı ile aynı desen, ARCHITECTURE.md
/// §10.2 döngüsel bağımlılık önleme kuralı ihlal edilmeden — Tasks bunun
/// farkında değildir).
final goalProgressProvider = StreamProvider.autoDispose.family<double, String>((ref, goalId) {
  final goal = ref.watch(goalDetailProvider(goalId)).valueOrNull;
  if (goal == null) return const Stream.empty();

  if (goal.progressType == GoalProgressType.manual) {
    return Stream.value(goal.manualProgressRatio);
  }

  return ref.watch(watchTasksUseCaseProvider).call(filter: TaskFilter.none).map((tasks) {
    if (goal.linkedTaskIds.isEmpty) return 0.0;
    final linked = tasks.where((t) => goal.linkedTaskIds.contains(t.taskId)).toList();
    if (linked.isEmpty) return 0.0;
    final completed = linked.where((t) => t.isCompleted).length;
    return completed / linked.length;
  });
});

/// Hedef oluşturma/düzenleme formundaki bağlı görev seçicisi için — Tasks'ın
/// dışa açık Domain UseCase'i üzerinden (ARCHITECTURE.md §10.2 madde 5,
/// yalnızca Domain UseCase provider'ı import edilebilir; Tasks'ın
/// Presentation katmanındaki `taskListProvider`'ı burada KULLANILMAZ).
final goalAvailableTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(watchTasksUseCaseProvider).call(filter: TaskFilter.none);
});

/// Dashboard'un "Haftalık İlerleme / Hedef Durumu" bölümü (SCREENS.md §5,
/// sıra 4: "aktif hedeflerden en fazla 1 öne çıkan Goal Card") —
/// ARCHITECTURE.md §4.1 örneğiyle aynı desen (Dashboard → Domain UseCase).
/// En yakın son tarihli (`periodEndDate`) devam eden hedef öne çıkarılır.
///
/// Dashboard uygulamanın ilk ekranı olduğundan, bu provider'ın (ilk kez)
/// okunması `goalRepositoryProvider`'ı da örnekler — ROADMAP.md FAZ 8
/// "dönem sonu otomatik arşivleme"nin "uygulama açılışında" tetikleyicisi
/// burada gerçekleşir (Goals Screen açıldığında `GoalListController`'ın
/// tetiklediği kontrolle birlikte "çift mekanizma").
final featuredGoalProvider = StreamProvider.autoDispose<Goal?>((ref) {
  // Bkz. `GoalListController.build()` — Tasks yapılandırılmamışsa bu satır
  // Dashboard'un hedef bölümünü engellememeli.
  try {
    unawaited(ref.read(checkExpiredGoalsUseCaseProvider).call());
  } catch (_) {
    // Sessiz — bir sonraki açılışta tekrar denenir.
  }
  return ref.watch(watchGoalsUseCaseProvider).call().map((goals) {
    final active = goals.where((g) => g.status == GoalStatus.inProgress).toList()
      ..sort((a, b) => a.periodEndDate.compareTo(b.periodEndDate));
    return active.isEmpty ? null : active.first;
  });
});
