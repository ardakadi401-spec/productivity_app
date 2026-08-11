import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/sub_task.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../datasources/remote/task_remote_datasource.dart';
import '../mappers/sub_task_mapper.dart';
import '../mappers/task_mapper.dart';
import '../models/sub_task_local_model.dart';
import '../models/task_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması: her yazma
/// önce Isar'a (anında, `pendingX` işaretiyle) yazılır, UI bunu Isar'ın
/// reaktif stream'i üzerinden hemen görür; bağlantı varsa arka planda
/// Firestore'a gönderilir, başarılıysa `synced` işaretlenir, başarısızsa
/// sessizce `pending` kalır (ROADMAP.md FAZ 5 kapsamı — tam kuyruk/çakışma
/// yönetimi FAZ 14'te). Kurucu, bir kerelik "uzaktan çek + LWW ile eşle"
/// senkronizasyonunu (DATABASE.md §12.4) arka planda başlatır; kalıcı
/// realtime dinleyici FAZ 14 kapsamındadır — bu nedenle başka bir cihazda
/// eklenen alt görevler, bu oturumda ilgili görev detayına gidilene kadar
/// (o an tetiklenecek FAZ 14 iyileştirmesine kadar) görünmeyebilir; bilinen,
/// kabul edilmiş bir sınırlama.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final TaskLocalDatasource _local;
  final TaskRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  String newTaskId() => _remote.newTaskId();

  @override
  String newSubTaskId(String taskId) => _remote.newSubTaskId(taskId);

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) {
    return _local.watchTasks().map(
          (models) => _applyFilter(models, filter).map(TaskMapper.toEntity).toList(),
        );
  }

  @override
  Stream<Task?> watchTask(String taskId) {
    return _local.watchTask(taskId).map((m) => m == null ? null : TaskMapper.toEntity(m));
  }

  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) {
    return _local.watchSubTasks(taskId).map((list) => list.map(SubTaskMapper.toEntity).toList());
  }

  @override
  Stream<List<Task>> watchTodayTasks() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _local.watchTasks().map(
          (models) => models
              .where(
                (m) =>
                    !m.isDeleted &&
                    m.dueDate != null &&
                    !m.dueDate!.isBefore(startOfDay) &&
                    m.dueDate!.isBefore(endOfDay),
              )
              .map(TaskMapper.toEntity)
              .toList(),
        );
  }

  @override
  Future<Result<Task>> createTask(Task task) => _guard(() async {
        final model = TaskMapper.fromEntity(task, syncStatus: SyncStatusLocal.pendingCreate);
        await _local.putTask(model);
        await _trySyncTask(model);
        return TaskMapper.toEntity(model);
      });

  @override
  Future<Result<Task>> updateTask(Task task) => _guard(() async {
        final model = TaskMapper.fromEntity(task, syncStatus: SyncStatusLocal.pendingUpdate);
        await _local.putTask(model);
        await _trySyncTask(model);
        return TaskMapper.toEntity(model);
      });

  @override
  Future<Result<void>> deleteTask(String taskId) => _guard(() async {
        final existing = await _local.getByTaskId(taskId);
        if (existing == null) throw const CacheException('Görev bulunamadı.');
        final now = DateTime.now();
        existing
          ..isDeleted = true
          ..deletedAt = now
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = SyncStatusLocal.pendingDelete;
        await _local.putTask(existing);
        await _trySyncTask(existing);
      });

  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) =>
      _guard(() async {
        final existing = await _local.getByTaskId(taskId);
        if (existing == null) throw const CacheException('Görev bulunamadı.');
        final now = DateTime.now();
        existing
          ..status = isCompleted ? TaskStatusLocal.completed : TaskStatusLocal.pending
          ..completedAt = isCompleted ? now : null
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = SyncStatusLocal.pendingUpdate;
        await _local.putTask(existing);
        await _trySyncTask(existing);
        return TaskMapper.toEntity(existing);
      });

  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) => _guard(() async {
        final model = SubTaskMapper.fromEntity(subTask, syncStatus: SyncStatusLocal.pendingCreate);
        await _local.putSubTask(model);
        await _trySyncSubTask(model);
        await _recalculate(subTask.taskId);
        return SubTaskMapper.toEntity(model);
      });

  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) =>
      _guard(() async {
        final existing = await _local.getSubTaskById(subtaskId);
        if (existing == null) throw const CacheException('Alt görev bulunamadı.');
        final now = DateTime.now();
        existing
          ..isCompleted = isCompleted
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = SyncStatusLocal.pendingUpdate;
        await _local.putSubTask(existing);
        await _trySyncSubTask(existing);
        await _recalculate(existing.taskId);
      });

  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => _guard(() => _recalculate(taskId));

  Future<Task> _recalculate(String taskId) async {
    final subtasks = await _local.getSubTasks(taskId);
    final task = await _local.getByTaskId(taskId);
    if (task == null) throw const CacheException('Görev bulunamadı.');
    final now = DateTime.now();
    task
      ..subtaskCount = subtasks.length
      ..completedSubtaskCount = subtasks.where((s) => s.isCompleted).length
      ..updatedAt = now
      ..localUpdatedAt = now
      ..syncStatus = SyncStatusLocal.pendingUpdate;
    await _local.putTask(task);
    await _trySyncTask(task);
    return TaskMapper.toEntity(task);
  }

  List<TaskLocalModel> _applyFilter(List<TaskLocalModel> models, TaskFilter filter) {
    return models.where((m) {
      if (filter.priority != null && m.priority.name != filter.priority!.name) return false;
      if (!filter.includeCompleted && m.status == TaskStatusLocal.completed) return false;
      if (filter.dueOnDate != null) {
        final d = filter.dueOnDate!;
        if (m.dueDate == null) return false;
        final due = m.dueDate!;
        if (due.year != d.year || due.month != d.month || due.day != d.day) return false;
      }
      if (filter.projectId != null && m.projectId != filter.projectId) return false;
      return true;
    }).toList();
  }

  /// Bağlantı varsa Firestore'a gönderir; başarısız olursa sessizce
  /// `pending` bırakır (ARCHITECTURE.md §8.2 — bir sonraki bağlantıda
  /// tekrar denenir, bu tekrar deneme FAZ 5'te `_syncFromRemote`'un
  /// `pendingSync` taramasıyla, FAZ 14'te tam tetikleyici mekanizmasıyla
  /// yapılır).
  Future<void> _trySyncTask(TaskLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setTask(model);
      model
        ..syncStatus = SyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putTask(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _trySyncSubTask(SubTaskLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setSubTask(model.taskId, model);
      model
        ..syncStatus = SyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putSubTask(model);
    } catch (_) {
      // pending kalır.
    }
  }

  /// DATABASE.md §12.4 — bir kerelik uzaktan çekme + Last-Write-Wins eşleme,
  /// ardından yerelde hâlâ `pending*` olan kayıtları göndermeyi dener.
  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteTasks = await _remote.fetchAllTasks();
      for (final remoteTask in remoteTasks) {
        final local = await _local.getByTaskId(remoteTask.taskId);
        if (local == null || remoteTask.updatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putTask(remoteTask);
        }
      }
      final pending = await _local.getPendingSync();
      for (final model in pending) {
        await _trySyncTask(model);
      }
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (e) {
      return Err(_mapToFailure(e));
    }
  }

  Failure _mapToFailure(AppException exception) {
    return switch (exception) {
      CacheException(:final message) => CacheFailure(message),
      NetworkException() => const NetworkFailure('Bağlantını kontrol edip tekrar dene.'),
      AuthException() => const AuthFailure('Oturum bulunamadı, lütfen tekrar giriş yap.'),
      _ => UnknownFailure(exception.message),
    };
  }
}

/// `unawaited` — kurucudaki arka plan senkronizasyonunun bilinçli olarak
/// "fire and forget" olduğunu (ve `dangling future` lint uyarısını) açıkça
/// belirtir.
void unawaited(Future<void> future) {}
