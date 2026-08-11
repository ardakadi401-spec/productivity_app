import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../providers/task_providers.dart';

/// Tasks Screen (SCREENS.md §4.9) — STATE_MANAGEMENT.md §5.1: `family`
/// modifier ile aktif filtreye göre, Isar'ın reaktif stream'ine doğrudan
/// abone olan tek bir controller; tamamlama/silme eylemlerini de aynı yerden
/// orkestre eder (Isar yazması, `watchTasks` stream'ini otomatik olarak
/// yeniden tetikler — bu nedenle eylem metotları state'i elle güncellemez,
/// yalnızca hatayı çağırana döndürür).
class TaskListController extends AutoDisposeFamilyStreamNotifier<List<Task>, TaskFilter> {
  @override
  Stream<List<Task>> build(TaskFilter arg) {
    return ref.watch(watchTasksUseCaseProvider).call(filter: arg);
  }

  Future<Result<void>> toggleCompleted(String taskId, {required bool isCompleted}) async {
    final result =
        await ref.read(completeTaskUseCaseProvider).call(taskId, isCompleted: isCompleted);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<void>> deleteTask(String taskId) {
    return ref.read(deleteTaskUseCaseProvider).call(taskId);
  }
}

final taskListControllerProvider = StreamNotifierProvider.autoDispose
    .family<TaskListController, List<Task>, TaskFilter>(TaskListController.new);
