import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/domain/usecases/archive_project_usecase.dart';
import 'package:productivity_app/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:productivity_app/features/projects/domain/usecases/recalculate_project_progress_usecase.dart';
import 'package:productivity_app/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:productivity_app/features/projects/domain/usecases/watch_project_usecase.dart';
import 'package:productivity_app/features/projects/domain/usecases/watch_projects_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

Project _project({String projectId = 'p1'}) => Project(
      projectId: projectId,
      title: 'Örnek proje',
      color: '#FF8A8A',
      status: ProjectStatus.active,
      taskCount: 0,
      completedTaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeProjectRepository implements ProjectRepository {
  Result<Project>? projectResult;
  List<Project> watchProjectsResult = const [];
  Project? watchProjectResult;

  ProjectStatus? lastStatusFilter;
  String? lastWatchedProjectId;
  Project? lastCreatedProject;
  Project? lastUpdatedProject;
  ({String projectId, bool isArchived})? lastArchiveArgs;
  ({String projectId, int taskCount, int completedTaskCount})? lastProgressArgs;

  @override
  String newProjectId() => 'generated-project-id';

  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) {
    lastStatusFilter = status;
    return Stream.value(watchProjectsResult);
  }

  @override
  Stream<Project?> watchProject(String projectId) {
    lastWatchedProjectId = projectId;
    return Stream.value(watchProjectResult);
  }

  @override
  Future<Result<Project>> createProject(Project project) async {
    lastCreatedProject = project;
    return projectResult!;
  }

  @override
  Future<Result<Project>> updateProject(Project project) async {
    lastUpdatedProject = project;
    return projectResult!;
  }

  @override
  Future<Result<Project>> setProjectArchived(String projectId, {required bool isArchived}) async {
    lastArchiveArgs = (projectId: projectId, isArchived: isArchived);
    return projectResult!;
  }

  @override
  Future<Result<Project>> updateProjectProgress(
    String projectId, {
    required int taskCount,
    required int completedTaskCount,
  }) async {
    lastProgressArgs =
        (projectId: projectId, taskCount: taskCount, completedTaskCount: completedTaskCount);
    return projectResult!;
  }
}

Task _task({required bool isCompleted}) => Task(
      taskId: 't1',
      title: 'Görev',
      priority: TaskPriority.medium,
      status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeTaskRepository implements TaskRepository {
  List<Task> tasksResult = const [];
  TaskFilter? lastFilter;

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) {
    lastFilter = filter;
    return Stream.value(tasksResult);
  }

  @override
  Stream<Task?> watchTask(String taskId) => const Stream.empty();
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => const Stream.empty();
  @override
  Stream<List<Task>> watchTodayTasks() => const Stream.empty();
  @override
  Future<Result<Task>> createTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteTask(String taskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) => throw UnimplementedError();
  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

void main() {
  late _FakeProjectRepository repo;

  setUp(() => repo = _FakeProjectRepository());

  test('CreateProjectUseCase projeyi repository\'ye iletir', () async {
    repo.projectResult = Ok(_project());
    final result = await CreateProjectUseCase(repo).call(_project());
    expect(repo.lastCreatedProject?.projectId, 'p1');
    expect(result, isA<Ok<Project>>());
  });

  test('UpdateProjectUseCase projeyi repository\'ye iletir', () async {
    repo.projectResult = Ok(_project());
    await UpdateProjectUseCase(repo).call(_project());
    expect(repo.lastUpdatedProject?.projectId, 'p1');
  });

  test('ArchiveProjectUseCase isArchived argümanını iletir', () async {
    repo.projectResult = Ok(_project());
    await ArchiveProjectUseCase(repo).call('p1', isArchived: true);
    expect(repo.lastArchiveArgs, (projectId: 'p1', isArchived: true));
  });

  test('WatchProjectsUseCase status filtresini iletir', () async {
    repo.watchProjectsResult = [_project()];
    await WatchProjectsUseCase(repo).call(status: ProjectStatus.archived).first;
    expect(repo.lastStatusFilter, ProjectStatus.archived);
  });

  test('WatchProjectUseCase projectId\'yi iletir', () async {
    repo.watchProjectResult = _project();
    await WatchProjectUseCase(repo).call('p1').first;
    expect(repo.lastWatchedProjectId, 'p1');
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.projectResult = const Err(CacheFailure('boom'));
    final result = await CreateProjectUseCase(repo).call(_project());
    expect(result, isA<Err<Project>>());
  });

  group('RecalculateProjectProgressUseCase', () {
    test('0 görevli projede bölme hatası olmadan 0/0 hesaplar', () async {
      repo.projectResult = Ok(_project());
      final taskRepo = _FakeTaskRepository();
      final useCase = RecalculateProjectProgressUseCase(repo, WatchTasksUseCase(taskRepo));

      await useCase.call('p1');

      expect(taskRepo.lastFilter?.projectId, 'p1');
      expect(repo.lastProgressArgs, (projectId: 'p1', taskCount: 0, completedTaskCount: 0));
    });

    test('kısmi tamamlanma -> taskCount/completedTaskCount doğru hesaplanır', () async {
      repo.projectResult = Ok(_project());
      final taskRepo = _FakeTaskRepository()
        ..tasksResult = [_task(isCompleted: true), _task(isCompleted: false)];
      final useCase = RecalculateProjectProgressUseCase(repo, WatchTasksUseCase(taskRepo));

      final result = await useCase.call('p1');

      expect(result, isA<Ok<Project>>());
      expect(repo.lastProgressArgs, (projectId: 'p1', taskCount: 2, completedTaskCount: 1));
    });

    test('tüm görevler tamamlandığında completedTaskCount == taskCount', () async {
      repo.projectResult = Ok(_project());
      final taskRepo = _FakeTaskRepository()
        ..tasksResult = [_task(isCompleted: true), _task(isCompleted: true)];
      final useCase = RecalculateProjectProgressUseCase(repo, WatchTasksUseCase(taskRepo));

      await useCase.call('p1');

      expect(repo.lastProgressArgs, (projectId: 'p1', taskCount: 2, completedTaskCount: 2));
    });
  });
}
