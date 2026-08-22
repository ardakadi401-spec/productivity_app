import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:productivity_app/features/projects/data/datasources/remote/project_remote_datasource.dart';
import 'package:productivity_app/features/projects/data/models/project_local_model.dart';
import 'package:productivity_app/features/projects/data/repositories/project_repository_impl.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';

class _MockLocal extends Mock implements ProjectLocalDatasource {}

class _MockRemote extends Mock implements ProjectRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

Project _project({String projectId = 'p1'}) => Project(
      projectId: projectId,
      title: 'Proje',
      color: '#FF8A8A',
      status: ProjectStatus.active,
      taskCount: 0,
      completedTaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

ProjectLocalModel _model({
  String projectId = 'p1',
  ProjectSyncStatusLocal syncStatus = ProjectSyncStatusLocal.pendingCreate,
  ProjectStatusLocal status = ProjectStatusLocal.active,
}) {
  final now = DateTime(2026, 1, 1);
  return ProjectLocalModel()
    ..projectId = projectId
    ..title = 'Proje'
    ..color = '#FF8A8A'
    ..status = status
    ..taskCount = 0
    ..completedTaskCount = 0
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
  late ProjectRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = ProjectRepositoryImpl(local, remote, connectivity);
  });

  group('createProject', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putProject(any())).thenAnswer((_) async {});

      final result = await repository.createProject(_project());

      expect(result, isA<Ok<Project>>());
      final captured =
          verify(() => local.putProject(captureAny())).captured.single as ProjectLocalModel;
      expect(captured.syncStatus, ProjectSyncStatusLocal.pendingCreate);
      verifyNever(() => remote.setProject(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putProject(any())).thenAnswer((_) async {});
      when(() => remote.setProject(any())).thenAnswer((_) async {});

      await repository.createProject(_project());

      verify(() => remote.setProject(any())).called(1);
      final calls = verify(() => local.putProject(captureAny())).captured.cast<ProjectLocalModel>();
      expect(calls.last.syncStatus, ProjectSyncStatusLocal.synced);
    });

    test('remote gönderimi başarısız olursa kayıt pending kalır ama Ok döner', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putProject(any())).thenAnswer((_) async {});
      when(() => remote.setProject(any())).thenThrow(const NetworkException('boom'));

      final result = await repository.createProject(_project());

      expect(result, isA<Ok<Project>>());
      final calls = verify(() => local.putProject(captureAny())).captured.cast<ProjectLocalModel>();
      expect(calls.last.syncStatus, ProjectSyncStatusLocal.pendingCreate);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putProject(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createProject(_project());

      expect(result, isA<Err<Project>>());
      final failure = (result as Err).failure;
      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'disk dolu');
    });
  });

  group('setProjectArchived', () {
    test('arşivlerken status archived olarak işaretlenir', () async {
      when(() => local.getByProjectId('p1')).thenAnswer((_) async => _model());
      when(() => local.putProject(any())).thenAnswer((_) async {});

      final result = await repository.setProjectArchived('p1', isArchived: true);

      expect(result, isA<Ok<Project>>());
      final captured =
          verify(() => local.putProject(captureAny())).captured.single as ProjectLocalModel;
      expect(captured.status, ProjectStatusLocal.archived);
    });

    test('arşivden çıkarırken status active olarak işaretlenir', () async {
      when(() => local.getByProjectId('p1'))
          .thenAnswer((_) async => _model(status: ProjectStatusLocal.archived));
      when(() => local.putProject(any())).thenAnswer((_) async {});

      final result = await repository.setProjectArchived('p1', isArchived: false);

      expect(result, isA<Ok<Project>>());
      final captured =
          verify(() => local.putProject(captureAny())).captured.single as ProjectLocalModel;
      expect(captured.status, ProjectStatusLocal.active);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getByProjectId('missing')).thenAnswer((_) async => null);

      final result = await repository.setProjectArchived('missing', isArchived: true);

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('updateProjectProgress', () {
    test('0 görevli bir projede bölme hatası olmadan 0/0 yazar', () async {
      when(() => local.getByProjectId('p1')).thenAnswer((_) async => _model());
      when(() => local.putProject(any())).thenAnswer((_) async {});

      final result =
          await repository.updateProjectProgress('p1', taskCount: 0, completedTaskCount: 0);

      expect(result, isA<Ok<Project>>());
      final captured =
          verify(() => local.putProject(captureAny())).captured.single as ProjectLocalModel;
      expect(captured.taskCount, 0);
      expect(captured.completedTaskCount, 0);
    });

    test('taskCount/completedTaskCount doğru güncellenir', () async {
      when(() => local.getByProjectId('p1')).thenAnswer((_) async => _model());
      when(() => local.putProject(any())).thenAnswer((_) async {});

      await repository.updateProjectProgress('p1', taskCount: 4, completedTaskCount: 2);

      final captured =
          verify(() => local.putProject(captureAny())).captured.single as ProjectLocalModel;
      expect(captured.taskCount, 4);
      expect(captured.completedTaskCount, 2);
    });
  });

  group('syncPending — FAZ 14 (SyncCoordinator giriş noktası)', () {
    test('offline durumda hiçbir şey yapmaz', () async {
      await Future<void>.delayed(Duration.zero);

      await repository.syncPending();

      verifyNever(() => remote.setProject(any()));
    });

    test('pendingUpdate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: ProjectSyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setProject(any())).thenAnswer((_) async {});
      when(() => local.putProject(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setProject(pendingModel)).called(1);
      final captured =
          verify(() => local.putProject(captureAny())).captured.single as ProjectLocalModel;
      expect(captured.syncStatus, ProjectSyncStatusLocal.synced);
    });

    test('remote gönderimi hata verirse kayıt pending kalır', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: ProjectSyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setProject(any())).thenThrow(const NetworkException('boom'));

      await repository.syncPending();

      verifyNever(() => local.putProject(any()));
      expect(pendingModel.syncStatus, ProjectSyncStatusLocal.pendingUpdate);
    });
  });

  group('watchProjects filtreleme', () {
    test('status verilmezse tüm projeleri döner', () async {
      final active = _model(projectId: 'a');
      final archived = _model(projectId: 'b', status: ProjectStatusLocal.archived);
      when(() => local.watchProjects()).thenAnswer((_) => Stream.value([active, archived]));

      final result = await repository.watchProjects().first;

      expect(result.map((p) => p.projectId), ['a', 'b']);
    });

    test('status verilirse yalnızca eşleşenleri döner', () async {
      final active = _model(projectId: 'a');
      final archived = _model(projectId: 'b', status: ProjectStatusLocal.archived);
      when(() => local.watchProjects()).thenAnswer((_) => Stream.value([active, archived]));

      final result = await repository.watchProjects(status: ProjectStatus.archived).first;

      expect(result.map((p) => p.projectId), ['b']);
    });
  });
}
