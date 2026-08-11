import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

/// Projects Screen (SCREENS.md §4.7) — STATE_MANAGEMENT.md §5.1: `family`
/// modifier ile aktif Aktif/Arşivlenmiş filtresine göre, Isar'ın reaktif
/// stream'ine doğrudan abone olan controller; arşivleme eylemini de aynı
/// yerden orkestre eder (Tasks'ın `TaskListController`'ı ile aynı desen).
class ProjectListController extends AutoDisposeFamilyStreamNotifier<List<Project>, ProjectStatus?> {
  @override
  Stream<List<Project>> build(ProjectStatus? arg) {
    return ref.watch(watchProjectsUseCaseProvider).call(status: arg);
  }

  Future<Result<void>> setArchived(String projectId, {required bool isArchived}) async {
    final result =
        await ref.read(archiveProjectUseCaseProvider).call(projectId, isArchived: isArchived);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }
}

final projectListControllerProvider = StreamNotifierProvider.autoDispose
    .family<ProjectListController, List<Project>, ProjectStatus?>(ProjectListController.new);
