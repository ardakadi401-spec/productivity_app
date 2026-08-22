import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../notes/presentation/providers/note_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/usecases/search_usecase.dart';

/// ARCHITECTURE.md §4, #11 — Search'ün kendi Data katmanı yoktur; yalnızca
/// Tasks/Projects/Notes/Habits'in dışa açık Domain UseCase provider'larını
/// okur.
final searchUseCaseProvider = Provider<SearchUseCase>((ref) {
  return SearchUseCase(
    ref.watch(watchTasksUseCaseProvider),
    ref.watch(watchProjectsUseCaseProvider),
    ref.watch(watchNotesUseCaseProvider),
    ref.watch(watchHabitsUseCaseProvider),
  );
});
