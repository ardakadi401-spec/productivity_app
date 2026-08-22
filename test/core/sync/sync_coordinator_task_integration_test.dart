import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/core/sync/sync_coordinator.dart';
import 'package:productivity_app/features/tasks/data/datasources/local/task_local_datasource.dart';
import 'package:productivity_app/features/tasks/data/datasources/remote/task_remote_datasource.dart';
import 'package:productivity_app/features/tasks/data/models/task_local_model.dart';
import 'package:productivity_app/features/tasks/data/repositories/task_repository_impl.dart';

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _MockLocal extends Mock implements TaskLocalDatasource {}

class _MockRemote extends Mock implements TaskRemoteDatasource {}

TaskLocalModel _pendingTask() {
  final now = DateTime(2026, 1, 1);
  return TaskLocalModel()
    ..taskId = 't1'
    ..title = 'Görev'
    ..priority = TaskPriorityLocal.medium
    ..status = TaskStatusLocal.pending
    ..subtaskCount = 0
    ..completedSubtaskCount = 0
    ..createdAt = now
    ..updatedAt = now
    ..isDeleted = false
    ..syncStatus = SyncStatusLocal.pendingCreate
    ..localUpdatedAt = now;
}

Future<void> pump([int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(_pendingTask());
  });

  test(
    'SyncCoordinator, offline→online geçişinde gerçek '
    'TaskRepositoryImpl.syncPending() metodunu tetikler',
    () async {
      final connectivity = _MockConnectivityService();
      final statusController = StreamController<bool>.broadcast();
      final local = _MockLocal();
      final remote = _MockRemote();
      final pendingTask = _pendingTask();

      when(() => connectivity.isConnected).thenAnswer((_) async => false);
      when(() => connectivity.onStatusChange).thenAnswer((_) => statusController.stream);
      when(() => local.getPendingSync()).thenAnswer((_) async => []);
      when(() => local.putTask(any())).thenAnswer((_) async {});
      when(() => remote.setTask(any())).thenAnswer((_) async {});

      // Bağımsız bir TaskRepositoryImpl — kurucusu offline olduğu için arka
      // plan `_syncFromRemote()` no-op kalır (deterministik test).
      final taskRepository = TaskRepositoryImpl(local, remote, connectivity);
      await pump(2);

      final container = ProviderContainer(
        overrides: [
          connectivityServiceProvider.overrideWithValue(connectivity),
          syncableRepositoriesProvider.overrideWithValue([taskRepository]),
        ],
      );
      addTearDown(container.dispose);

      // Coordinator, offline temel durumu gözlemler (henüz tetiklemez).
      container.read(syncCoordinatorProvider);
      await pump(2);

      // Bağlantı gerçekten geri geldi ve bir pending görev var.
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingTask]);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      statusController.add(true);
      await pump(3);

      verify(() => remote.setTask(pendingTask)).called(1);
      expect(pendingTask.syncStatus, SyncStatusLocal.synced);

      await statusController.close();
    },
  );
}
