import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

/// Project Detail Screen (SCREENS.md §4.8) — projeyi Isar'ın reaktif
/// stream'inden okur; arşivleme eylemini tetikler.
///
/// Ayrıca, projeye bağlı görev sayısı (`projectTaskStatsProvider` —
/// Tasks'ın canlı stream'i) her değiştiğinde, `Project.taskCount`/
/// `completedTaskCount` denormalize alanlarını (DATABASE.md §3.2) arka
/// planda güncel tutmak için `RecalculateProjectProgressUseCase`'i tetikler
/// — bu, yalnızca Projects'in kendi controller'ı içinde, Projects → Tasks
/// tek yönlü okuma bağımlılığıyla yapılır (ARCHITECTURE.md §10.2); Tasks
/// feature'ı bunun farkında bile değildir.
class ProjectDetailController extends AutoDisposeFamilyStreamNotifier<Project?, String> {
  @override
  Stream<Project?> build(String arg) {
    ref.listen(projectTaskStatsProvider(arg), (previous, next) {
      if (!next.hasValue) return;
      ref.read(recalculateProjectProgressUseCaseProvider).call(arg);
    });
    return ref.watch(watchProjectUseCaseProvider).call(arg);
  }

  Future<Result<void>> setArchived({required bool isArchived}) async {
    final result =
        await ref.read(archiveProjectUseCaseProvider).call(arg, isArchived: isArchived);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<void>> delete() => ref.read(deleteProjectUseCaseProvider).call(arg);
}

final projectDetailControllerProvider =
    StreamNotifierProvider.autoDispose.family<ProjectDetailController, Project?, String>(
  ProjectDetailController.new,
);
