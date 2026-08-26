import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/sync/sync_coordinator.dart';
import '../core/sync/syncable_repository.dart';
import '../features/goals/presentation/providers/goal_providers.dart';
import '../features/habits/presentation/providers/habit_providers.dart';
import '../features/notes/presentation/providers/note_providers.dart';
import '../features/pomodoro/presentation/providers/pomodoro_providers.dart';
import '../features/projects/presentation/providers/project_providers.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import '../features/statistics/presentation/providers/statistics_providers.dart';
import '../features/tags/presentation/providers/tag_providers.dart';
import '../features/tasks/presentation/providers/task_providers.dart';
import '../features/vault/presentation/providers/vault_providers.dart';

/// FAZ 14 — merkezi `SyncCoordinator`'ın (`core/sync/`) gerçekte hangi
/// repository'leri senkronize edeceğinin bağlantı noktası.
///
/// `core/sync/sync_coordinator.dart` hiçbir feature klasörünü import EDEMEZ
/// (ARCHITECTURE.md §10.2 Kural 3 / ROADMAP.md FAZ 2 tamamlanma kriteri) —
/// bu yüzden `syncableRepositoriesProvider`'ın gövdesi orada bilerek boş
/// (`const []`) bırakıldı. Gerçek liste yalnızca burada, uygulamanın
/// kompozisyon kökünde (`main.dart`) bir `Provider` override'ı olarak
/// kurulur — `app/reschedule_all_notifications.dart`'ın "birden fazla
/// feature'ı bir arada bilme, yalnızca kompozisyon kökünde istisnai olarak
/// kabul edilir" ilkesiyle aynı.
///
/// Cast'ler güvenlidir: her repository'nin somut `*RepositoryImpl` sınıfı
/// `SyncableRepository`'yi de implemente eder (bkz. ilgili FAZ 14 ADIM
/// raporları) — yalnızca Domain arayüzü (`TaskRepository` vb.) bunu bilerek
/// dışa açmaz.
final List<Override> syncBootstrapOverrides = [
  syncableRepositoriesProvider.overrideWith(
    (ref) => [
      ref.watch(taskRepositoryProvider) as SyncableRepository,
      ref.watch(habitRepositoryProvider) as SyncableRepository,
      ref.watch(noteRepositoryProvider) as SyncableRepository,
      ref.watch(projectRepositoryProvider) as SyncableRepository,
      ref.watch(goalRepositoryProvider) as SyncableRepository,
      ref.watch(pomodoroRepositoryProvider) as SyncableRepository,
      ref.watch(tagRepositoryProvider) as SyncableRepository,
      ref.watch(statisticsSnapshotRepositoryProvider) as SyncableRepository,
      ref.watch(settingsRepositoryProvider) as SyncableRepository,
      ref.watch(vaultRepositoryProvider) as SyncableRepository,
      ref.watch(vaultFolderRepositoryProvider) as SyncableRepository,
    ],
  ),
];
