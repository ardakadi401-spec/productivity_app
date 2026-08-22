import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/sub_task.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_sub_task_usecase.dart';
import '../../domain/usecases/complete_sub_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_today_tasks_usecase.dart';
import '../../domain/usecases/recalculate_task_progress_usecase.dart';
import '../../domain/usecases/sync_task_reminder_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/watch_sub_tasks_usecase.dart';
import '../../domain/usecases/watch_task_usecase.dart';
import '../../domain/usecases/watch_tasks_usecase.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final taskLocalDatasourceProvider = Provider<TaskLocalDatasource>((ref) {
  return TaskLocalDatasource(ref.watch(isarProvider));
});

final taskRemoteDatasourceProvider = Provider<TaskRemoteDatasource>((ref) {
  return TaskRemoteDatasource();
});

/// `keepAlive` — repository kurucusu bir kerelik uzaktan senkronizasyonu
/// tetikler (bkz. `TaskRepositoryImpl._syncFromRemote`); `autoDispose`
/// olsaydı her ekran girişinde tekrar örneklenip gereksiz senkronizasyon
/// tetiklenirdi.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    ref.watch(taskLocalDatasourceProvider),
    ref.watch(taskRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchTasksUseCaseProvider = Provider<WatchTasksUseCase>((ref) {
  return WatchTasksUseCase(ref.watch(taskRepositoryProvider));
});

final watchTaskUseCaseProvider = Provider<WatchTaskUseCase>((ref) {
  return WatchTaskUseCase(ref.watch(taskRepositoryProvider));
});

final watchSubTasksUseCaseProvider = Provider<WatchSubTasksUseCase>((ref) {
  return WatchSubTasksUseCase(ref.watch(taskRepositoryProvider));
});

final getTodayTasksUseCaseProvider = Provider<GetTodayTasksUseCase>((ref) {
  return GetTodayTasksUseCase(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  return CompleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final addSubTaskUseCaseProvider = Provider<AddSubTaskUseCase>((ref) {
  return AddSubTaskUseCase(ref.watch(taskRepositoryProvider));
});

final completeSubTaskUseCaseProvider = Provider<CompleteSubTaskUseCase>((ref) {
  return CompleteSubTaskUseCase(ref.watch(taskRepositoryProvider));
});

final recalculateTaskProgressUseCaseProvider = Provider<RecalculateTaskProgressUseCase>((ref) {
  return RecalculateTaskProgressUseCase(ref.watch(taskRepositoryProvider));
});

/// ARCHITECTURE.md §10.2 — Tasks; Settings VE Notification Domain'ine tek
/// yönlü bağımlıdır (ROADMAP.md FAZ 13).
final syncTaskReminderUseCaseProvider = Provider<SyncTaskReminderUseCase>((ref) {
  return SyncTaskReminderUseCase(
    ref.watch(watchNotificationPreferencesUseCaseProvider),
    ref.watch(scheduleNotificationUseCaseProvider),
    ref.watch(cancelNotificationUseCaseProvider),
  );
});

// --- Presentation katmanı — reaktif okuma provider'ları ---

/// Tasks Screen listesi (SCREENS.md §4.9) — filtre değiştiğinde yeniden
/// dinlenir, ekrandan çıkılınca dispose edilir.
final taskListProvider = StreamProvider.autoDispose.family<List<Task>, TaskFilter>((ref, filter) {
  return ref.watch(watchTasksUseCaseProvider).call(filter: filter);
});

final taskDetailProvider = StreamProvider.autoDispose.family<Task?, String>((ref, taskId) {
  return ref.watch(watchTaskUseCaseProvider).call(taskId);
});

final subTasksProvider = StreamProvider.autoDispose.family<List<SubTask>, String>((ref, taskId) {
  return ref.watch(watchSubTasksUseCaseProvider).call(taskId);
});

/// Dashboard'un "Bugünkü Görevler" bölümü — ARCHITECTURE.md §4.1.
final todayTasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  return ref.watch(getTodayTasksUseCaseProvider).call();
});
