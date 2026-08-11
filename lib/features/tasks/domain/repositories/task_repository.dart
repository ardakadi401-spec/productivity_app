import '../../../../core/errors/result.dart';
import '../entities/sub_task.dart';
import '../entities/task.dart';
import '../entities/task_filter.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
///
/// Okuma metotları `Stream` döner (STATE_MANAGEMENT.md §5.2 — Isar
/// üzerinden reaktif; hem yerel değişiklikler hem arka plandaki Firestore
/// senkronizasyonu aynı stream üzerinden UI'a yansır). Yazma metotları
/// ARCHITECTURE.md §7.3 gereği `Result` döner.
abstract interface class TaskRepository {
  /// Ağ çağrısı yapmadan yeni bir görev/alt görev ID'si tahsis eder
  /// (Firestore client-side doküman ID — offline de çalışır). Create
  /// controller'ları, yeni [Task]/[SubTask] entity'sini oluşturmadan önce
  /// bunu çağırır; aynı ID hem Isar'a hem sonradan Firestore'a yazılır.
  String newTaskId();

  String newSubTaskId(String taskId);

  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none});

  Stream<Task?> watchTask(String taskId);

  Stream<List<SubTask>> watchSubTasks(String taskId);

  Future<Result<Task>> createTask(Task task);

  Future<Result<Task>> updateTask(Task task);

  Future<Result<void>> deleteTask(String taskId);

  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted});

  Future<Result<SubTask>> addSubTask(SubTask subTask);

  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted});

  /// Alt görev sayaçlarını (denormalize `subtaskCount`/`completedSubtaskCount`)
  /// gerçek alt görev listesinden yeniden hesaplayıp üst göreve yazar —
  /// DATABASE.md §5.3 "atomic counter update".
  Future<Result<Task>> recalculateTaskProgress(String taskId);

  /// Dashboard'un "Bugünkü Görevler" bölümü için — `GetTodayTasksUseCase`
  /// aracılığıyla tüketilir (ARCHITECTURE.md §4.1 örneği).
  Stream<List<Task>> watchTodayTasks();
}
