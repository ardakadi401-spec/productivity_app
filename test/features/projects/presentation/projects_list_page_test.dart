import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/presentation/pages/projects_list_page.dart';
import 'package:productivity_app/features/projects/presentation/providers/project_providers.dart';

/// Projects Screen liste sayfası (SCREENS.md §4.7) — ROADMAP.md FAZ 16.
/// Önceden hiç test edilmemişti; özellikle "Yeni Proje" oluşturma akışı
/// (`CreateProjectController`/`CreateProjectSheet`, coverage denetiminde
/// %0 bulundu) burada kapsanır.
class _FakeProjectRepository implements ProjectRepository {
  List<Project> projects = const [];
  Project? lastCreated;
  final _controller = StreamController<List<Project>>.broadcast();

  @override
  String newProjectId() => 'new-project-id';

  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) =>
      Stream<List<Project>>.multi((controller) {
        controller.add(
          status == null ? projects : projects.where((p) => p.status == status).toList(),
        );
        final sub = _controller.stream.listen((all) {
          controller.add(status == null ? all : all.where((p) => p.status == status).toList());
        });
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<Project?> watchProject(String projectId) => Stream.value(null);

  @override
  Future<Result<Project>> createProject(Project project) async {
    lastCreated = project;
    projects = [...projects, project];
    _controller.add(projects);
    return Ok(project);
  }

  @override
  Future<Result<Project>> updateProject(Project project) => throw UnimplementedError();
  @override
  Future<Result<Project>> setProjectArchived(String projectId, {required bool isArchived}) =>
      throw UnimplementedError();
  @override
  Future<Result<Project>> updateProjectProgress(
    String projectId, {
    required int taskCount,
    required int completedTaskCount,
  }) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteProject(String projectId) => throw UnimplementedError();
}

Project _project(String id, String title, {ProjectStatus status = ProjectStatus.active}) => Project(
      projectId: id,
      title: title,
      color: '#FF8A8A',
      status: status,
      taskCount: 0,
      completedTaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

/// "Yeni Proje" oluşturulunca `onCreated` bir Project Detail rotasına
/// `context.push` eder — gerçek bir `GoRouter` gerekir
/// (`task_detail_page_test.dart`'taki aynı gerekçe).
Future<GoRouter> _pumpWithRouter(WidgetTester tester, {required _FakeProjectRepository repository}) async {
  final router = GoRouter(
    initialLocation: '/list',
    routes: [
      GoRoute(path: '/list', builder: (_, _) => const Scaffold(body: ProjectsListPage())),
      GoRoute(
        path: '/projects/:projectId',
        builder: (_, state) => Scaffold(body: Text('Proje Detayı: ${state.pathParameters['projectId']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [projectRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pump();
  return router;
}

void main() {
  testWidgets('proje listesi boşken boş durum gösterir', (tester) async {
    await _pumpWithRouter(tester, repository: _FakeProjectRepository());

    expect(find.text('Henüz proje eklemedin'), findsOneWidget);
  });

  testWidgets('aktif projeler listelenir, Arşivlenmiş sekmesinde gösterilmez', (tester) async {
    final repository = _FakeProjectRepository()
      ..projects = [
        _project('p1', 'Web Sitesi'),
        _project('p2', 'Arşiv Projesi', status: ProjectStatus.archived),
      ];
    await _pumpWithRouter(tester, repository: repository);

    expect(find.text('Web Sitesi'), findsOneWidget);
    expect(find.text('Arşiv Projesi'), findsNothing);

    await tester.tap(find.text('Arşivlenmiş'));
    await tester.pumpAndSettle();

    expect(find.text('Web Sitesi'), findsNothing);
    expect(find.text('Arşiv Projesi'), findsOneWidget);
  });

  testWidgets(
    '"Yeni Proje" boş durum eylemi CreateProjectSheet açar; geçerli adla oluşturulunca '
    'createProject çağrılır ve Project Detail\'e geçilir',
    (tester) async {
      // Bottom Sheet içeriği varsayılan 800x600 test görünümünde taşıyor
      // (project_detail_page_test.dart'taki EditProjectSheet ile aynı
      // gerekçe).
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _FakeProjectRepository();
      await _pumpWithRouter(tester, repository: repository);

      await tester.tap(find.text('Yeni Proje'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Mutfak Yenileme');
      await tester.pump();
      await tester.tap(find.text('Oluştur'));
      await tester.pumpAndSettle();

      expect(repository.lastCreated?.title, 'Mutfak Yenileme');
      expect(find.text('Proje Detayı: new-project-id'), findsOneWidget);
    },
  );
}
