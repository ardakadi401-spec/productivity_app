import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/tasks/data/datasources/local/task_local_datasource.dart';
import 'package:productivity_app/features/tasks/data/datasources/remote/task_remote_datasource.dart';
import 'package:productivity_app/features/tasks/data/models/sub_task_local_model.dart';
import 'package:productivity_app/features/tasks/data/models/task_local_model.dart';
import 'package:productivity_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';

class _MockLocal extends Mock implements TaskLocalDatasource {}

class _MockRemote extends Mock implements TaskRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

Task _task({String taskId = 't1'}) => Task(
      taskId: taskId,
      title: 'Görev',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

TaskLocalModel _model({String taskId = 't1', SyncStatusLocal syncStatus = SyncStatusLocal.pendingCreate}) {
  final now = DateTime(2026, 1, 1);
  return TaskLocalModel()
    ..taskId = taskId
    ..title = 'Görev'
    ..priority = TaskPriorityLocal.medium
    ..status = TaskStatusLocal.pending
    ..subtaskCount = 0
    ..completedSubtaskCount = 0
    ..createdAt = now
    ..updatedAt = now
    ..isDeleted = false
    ..syncStatus = syncStatus
    ..localUpdatedAt = now;
}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late _MockConnectivity connectivity;
  late TaskRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
    registerFallbackValue(
      SubTaskLocalModel()
        ..subtaskId = 'x'
        ..taskId = 'x'
        ..title = 'x'
        ..isCompleted = false
        ..order = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026)
        ..syncStatus = SyncStatusLocal.pendingCreate
        ..localUpdatedAt = DateTime(2026),
    );
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    // Kurucu, arka planda bir kerelik `_syncFromRemote` tetikler — testlerin
    // deterministik kalması için varsayılan olarak "bağlantı yok" stub'lanır;
    // ilgili testler bunu kendi içinde geçersiz kılar.
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = TaskRepositoryImpl(local, remote, connectivity);
  });

  group('createTask', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putTask(any())).thenAnswer((_) async {});

      final result = await repository.createTask(_task());

      expect(result, isA<Ok<Task>>());
      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.syncStatus, SyncStatusLocal.pendingCreate);
      verifyNever(() => remote.setTask(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putTask(any())).thenAnswer((_) async {});
      when(() => remote.setTask(any())).thenAnswer((_) async {});

      await repository.createTask(_task());

      verify(() => remote.setTask(any())).called(1);
      final calls = verify(() => local.putTask(captureAny())).captured.cast<TaskLocalModel>();
      expect(calls.last.syncStatus, SyncStatusLocal.synced);
    });

    test('remote gönderimi başarısız olursa kayıt pending kalır ama Ok döner', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putTask(any())).thenAnswer((_) async {});
      when(() => remote.setTask(any())).thenThrow(const NetworkException('boom'));

      final result = await repository.createTask(_task());

      expect(result, isA<Ok<Task>>());
      final calls = verify(() => local.putTask(captureAny())).captured.cast<TaskLocalModel>();
      expect(calls.last.syncStatus, SyncStatusLocal.pendingCreate);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putTask(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createTask(_task());

      expect(result, isA<Err<Task>>());
      final failure = (result as Err).failure;
      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'disk dolu');
    });
  });

  group('deleteTask', () {
    test('mevcut kaydı soft-delete olarak işaretler (isDeleted/deletedAt/pendingDelete)', () async {
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => _model());
      when(() => local.putTask(any())).thenAnswer((_) async {});

      final result = await repository.deleteTask('t1');

      expect(result, isA<Ok<void>>());
      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.isDeleted, isTrue);
      expect(captured.deletedAt, isNotNull);
      expect(captured.syncStatus, SyncStatusLocal.pendingDelete);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getByTaskId('missing')).thenAnswer((_) async => null);

      final result = await repository.deleteTask('missing');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('setTaskCompleted', () {
    test('tamamlandı olarak işaretlerken completedAt doldurur', () async {
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => _model());
      when(() => local.putTask(any())).thenAnswer((_) async {});

      final result = await repository.setTaskCompleted('t1', isCompleted: true);

      expect(result, isA<Ok<Task>>());
      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.status, TaskStatusLocal.completed);
      expect(captured.completedAt, isNotNull);
    });
  });

  group('addSubTask ve recalculateTaskProgress', () {
    SubTask subTask({String subtaskId = 's1', bool isCompleted = false}) => SubTask(
          subtaskId: subtaskId,
          taskId: 't1',
          title: 'Alt görev',
          isCompleted: isCompleted,
          order: 0,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

    test('0 alt görev -> subtaskCount/completedSubtaskCount 0 olarak yeniden hesaplanır', () async {
      when(() => local.putSubTask(any())).thenAnswer((_) async {});
      when(() => local.getSubTasks('t1')).thenAnswer((_) async => []);
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => _model());
      when(() => local.putTask(any())).thenAnswer((_) async {});

      await repository.addSubTask(subTask());

      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.subtaskCount, 0);
      expect(captured.completedSubtaskCount, 0);
    });

    test('tüm alt görevler tamamlandığında completedSubtaskCount == subtaskCount', () async {
      when(() => local.putSubTask(any())).thenAnswer((_) async {});
      when(() => local.getSubTasks('t1')).thenAnswer(
        (_) async => [
          SubTaskLocalModel()
            ..subtaskId = 's1'
            ..taskId = 't1'
            ..title = 'a'
            ..isCompleted = true
            ..order = 0
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026)
            ..syncStatus = SyncStatusLocal.synced
            ..localUpdatedAt = DateTime(2026),
          SubTaskLocalModel()
            ..subtaskId = 's2'
            ..taskId = 't1'
            ..title = 'b'
            ..isCompleted = true
            ..order = 1
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026)
            ..syncStatus = SyncStatusLocal.synced
            ..localUpdatedAt = DateTime(2026),
        ],
      );
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => _model());
      when(() => local.putTask(any())).thenAnswer((_) async {});

      await repository.recalculateTaskProgress('t1');

      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.subtaskCount, 2);
      expect(captured.completedSubtaskCount, 2);
    });

    test('kısmi tamamlanma -> oranı doğru yansıtır (1/2)', () async {
      when(() => local.getSubTasks('t1')).thenAnswer(
        (_) async => [
          SubTaskLocalModel()
            ..subtaskId = 's1'
            ..taskId = 't1'
            ..title = 'a'
            ..isCompleted = true
            ..order = 0
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026)
            ..syncStatus = SyncStatusLocal.synced
            ..localUpdatedAt = DateTime(2026),
          SubTaskLocalModel()
            ..subtaskId = 's2'
            ..taskId = 't1'
            ..title = 'b'
            ..isCompleted = false
            ..order = 1
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026)
            ..syncStatus = SyncStatusLocal.synced
            ..localUpdatedAt = DateTime(2026),
        ],
      );
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => _model());
      when(() => local.putTask(any())).thenAnswer((_) async {});

      final result = await repository.recalculateTaskProgress('t1');

      final task = (result as Ok<Task>).value;
      expect(task.subtaskCount, 2);
      expect(task.completedSubtaskCount, 1);
      expect(task.completionRatio, 0.5);
    });
  });

  group('syncPending — FAZ 14 ADIM 5 (SyncCoordinator giriş noktası)', () {
    test('offline durumda hiçbir şey yapmaz', () async {
      // setUp zaten connectivity.isConnected: false stub'ladı; kurucunun
      // arka plan `_syncFromRemote`'unun bu no-op'u tamamlaması için bekle.
      await Future<void>.delayed(Duration.zero);

      await repository.syncPending();

      verifyNever(() => remote.setTask(any()));
    });

    test('pendingCreate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: SyncStatusLocal.pendingCreate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setTask(any())).thenAnswer((_) async {});
      when(() => local.putTask(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setTask(pendingModel)).called(1);
      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.syncStatus, SyncStatusLocal.synced);
      expect(captured.lastSyncedAt, isNotNull);
    });

    test('pendingUpdate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: SyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setTask(any())).thenAnswer((_) async {});
      when(() => local.putTask(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setTask(pendingModel)).called(1);
      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.syncStatus, SyncStatusLocal.synced);
    });

    test('pendingDelete kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: SyncStatusLocal.pendingDelete)
        ..isDeleted = true
        ..deletedAt = DateTime(2026, 1, 2);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setTask(any())).thenAnswer((_) async {});
      when(() => local.putTask(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setTask(pendingModel)).called(1);
      final captured = verify(() => local.putTask(captureAny())).captured.single as TaskLocalModel;
      expect(captured.syncStatus, SyncStatusLocal.synced);
      expect(captured.isDeleted, isTrue);
    });

    test('remote gönderimi hata verirse kayıt pending kalır, hiçbir istisna dışarı fırlamaz', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: SyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setTask(any())).thenThrow(const NetworkException('boom'));

      await repository.syncPending();

      verifyNever(() => local.putTask(any()));
      expect(pendingModel.syncStatus, SyncStatusLocal.pendingUpdate);
    });
  });

  group('uzaktan senkronizasyon (Last-Write-Wins) — FAZ 14', () {
    // `_syncFromRemote` yalnızca constructor'da (bağlantı zaten `true`
    // stub'lanmış durumda) çalıştığından, bu testler kendi bağımsız
    // repository örneğini kurar — paylaşılan `repository` (setUp'ta
    // offline kurulan) kullanılmaz.
    test('remote kaydı localden daha yeniyse yerel güncellenir', () async {
      final localModel = _model(syncStatus: SyncStatusLocal.synced)
        ..localUpdatedAt = DateTime(2026, 1, 1);
      final remoteModel = _model(syncStatus: SyncStatusLocal.synced)
        ..title = 'Uzaktan güncellendi'
        ..updatedAt = DateTime(2026, 1, 5);

      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchAllTasks()).thenAnswer((_) async => [remoteModel]);
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => localModel);
      when(() => local.putTask(any())).thenAnswer((_) async {});

      TaskRepositoryImpl(local, remote, connectivity);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verify(() => local.putTask(remoteModel)).called(1);
    });

    test('yereldeki pending değişiklik remote eskiyse EZİLMEZ', () async {
      final localModel = _model(syncStatus: SyncStatusLocal.pendingUpdate)
        ..title = 'Henüz gönderilmemiş yerel değişiklik'
        ..localUpdatedAt = DateTime(2026, 1, 10);
      final remoteModel = _model(syncStatus: SyncStatusLocal.synced)
        ..updatedAt = DateTime(2026, 1, 1);

      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchAllTasks()).thenAnswer((_) async => [remoteModel]);
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => localModel);
      when(() => local.getPendingSync()).thenAnswer((_) async => []);

      TaskRepositoryImpl(local, remote, connectivity);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => local.putTask(remoteModel));
    });

    test('soft-delete edilmiş yerel kayıt, eski remote sürümüyle geri gelmez', () async {
      final deletedLocal = _model(syncStatus: SyncStatusLocal.pendingDelete)
        ..isDeleted = true
        ..deletedAt = DateTime(2026, 1, 10)
        ..localUpdatedAt = DateTime(2026, 1, 10);
      final staleRemote = _model(syncStatus: SyncStatusLocal.synced)
        ..isDeleted = false
        ..updatedAt = DateTime(2026, 1, 5);

      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchAllTasks()).thenAnswer((_) async => [staleRemote]);
      when(() => local.getByTaskId('t1')).thenAnswer((_) async => deletedLocal);
      when(() => local.getPendingSync()).thenAnswer((_) async => []);

      TaskRepositoryImpl(local, remote, connectivity);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => local.putTask(staleRemote));
    });
  });

  group('watchTasks filtreleme', () {
    test('includeCompleted:false iken tamamlanmış görevleri eler', () async {
      final pending = _model(taskId: 'p')..status = TaskStatusLocal.pending;
      final completed = _model(taskId: 'c')..status = TaskStatusLocal.completed;
      when(() => local.watchTasks()).thenAnswer((_) => Stream.value([pending, completed]));

      final result =
          await repository.watchTasks(filter: const TaskFilter(includeCompleted: false)).first;

      expect(result.map((t) => t.taskId), ['p']);
    });

    test('priority filtresi yalnızca eşleşen önceliği döner', () async {
      final low = _model(taskId: 'low')..priority = TaskPriorityLocal.low;
      final high = _model(taskId: 'high')..priority = TaskPriorityLocal.high;
      when(() => local.watchTasks()).thenAnswer((_) => Stream.value([low, high]));

      final result =
          await repository.watchTasks(filter: const TaskFilter(priority: TaskPriority.high)).first;

      expect(result.map((t) => t.taskId), ['high']);
    });
  });
}
