import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';
import 'package:productivity_app/features/notes/domain/repositories/note_repository.dart';
import 'package:productivity_app/features/notes/presentation/pages/note_detail_page.dart';
import 'package:productivity_app/features/notes/presentation/providers/note_providers.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/presentation/providers/project_providers.dart';
import 'package:productivity_app/features/tags/domain/entities/tag.dart';
import 'package:productivity_app/features/tags/domain/repositories/tag_repository.dart';
import 'package:productivity_app/features/tags/presentation/providers/tag_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

/// Note Detail Screen (SCREENS.md §4.19), ROADMAP.md FAZ 16 — coverage
/// denetiminde %0 bulunan bir ekran. Oluşturma (`noteId == null`) ve
/// düzenleme aynı ekranda ele alındığından her iki mod da kapsanır.
class _FakeNoteRepository implements NoteRepository {
  _FakeNoteRepository(Note? initial) : note = initial;

  Note? note;
  Note? lastCreated;
  Note? lastUpdated;
  bool deleteCalled = false;
  final _controller = StreamController<Note?>.broadcast();

  @override
  String newNoteId() => 'new-note-id';

  @override
  Stream<Note?> watchNote(String noteId) => Stream<Note?>.multi((controller) {
        controller.add(note);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none}) => Stream.value(const []);

  @override
  Future<Result<Note>> createNote(Note n) async {
    lastCreated = n;
    return Ok(n);
  }

  @override
  Future<Result<Note>> updateNote(Note n) async {
    lastUpdated = n;
    note = n;
    _controller.add(n);
    return Ok(n);
  }

  @override
  Future<Result<void>> deleteNote(String noteId) async {
    deleteCalled = true;
    return const Ok(null);
  }

  @override
  Future<Result<Note>> setPinned(String noteId, {required bool isPinned}) =>
      throw UnimplementedError();

  @override
  Future<Result<Note>> setLink(
    String noteId, {
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
  }) =>
      throw UnimplementedError();
}

class _EmptyProjectRepository implements ProjectRepository {
  @override
  String newProjectId() => 'pr1';
  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) => Stream.value(const []);
  @override
  Stream<Project?> watchProject(String projectId) => Stream.value(null);
  @override
  Future<Result<Project>> createProject(Project project) => throw UnimplementedError();
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
}

class _EmptyTaskRepository implements TaskRepository {
  @override
  String newTaskId() => 't1';
  @override
  String newSubTaskId(String taskId) => 's1';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(const []);
  @override
  Stream<Task?> watchTask(String taskId) => Stream.value(null);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task t) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task t) => throw UnimplementedError();
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
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

class _EmptyTagRepository implements TagRepository {
  @override
  String newTagId() => 'tag1';
  @override
  Stream<List<Tag>> watchTags() => Stream.value(const []);
  @override
  Future<Result<Tag>> createTag(Tag tag) => throw UnimplementedError();
}

Note _note({
  String noteId = 'n1',
  String title = 'Alışveriş Listesi',
  bool isPinned = false,
}) =>
    Note(
      noteId: noteId,
      title: title,
      isPinned: isPinned,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

/// Hem oluşturma (kaydet -> `context.pop()`) hem silme akışı gerçek bir
/// `GoRouter` gerektirir (`task_detail_page_test.dart`'taki aynı gerekçe).
Future<GoRouter> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeNoteRepository noteRepository,
  String? noteId,
}) async {
  // Form içeriği (başlık + biçimlendirme araç çubuğu + içerik + önizleme +
  // renk seçici + proje/görev seçici + etiketler + kaydet butonu) varsayılan
  // 800x600 test görünümünde taşıyor (project_detail_page_test.dart'taki
  // EditProjectSheet ile aynı gerekçe).
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/list',
    routes: [
      GoRoute(path: '/list', builder: (_, _) => const Scaffold(body: Text('Not Listesi'))),
      GoRoute(
        path: '/detail',
        builder: (_, _) => NoteDetailPage(noteId: noteId),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(noteRepository),
        projectRepositoryProvider.overrideWithValue(_EmptyProjectRepository()),
        taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
        tagRepositoryProvider.overrideWithValue(_EmptyTagRepository()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.push('/detail');
  await tester.pumpAndSettle();
  return router;
}

void main() {
  group('Oluşturma modu (noteId == null)', () {
    testWidgets('boş form render olur', (tester) async {
      await _pumpWithRouter(tester, noteRepository: _FakeNoteRepository(null));

      expect(find.text('Yeni Not'), findsOneWidget);
      expect(find.text('Notu Kaydet'), findsOneWidget);
    });

    testWidgets('boş başlıkla kaydetmeye çalışınca doğrulama hatası gösterir, repository çağrılmaz', (
      tester,
    ) async {
      final repository = _FakeNoteRepository(null);
      await _pumpWithRouter(tester, noteRepository: repository);

      await tester.tap(find.text('Notu Kaydet'));
      await tester.pumpAndSettle();

      expect(find.text('Not başlığı boş olamaz.'), findsOneWidget);
      expect(repository.lastCreated, isNull);
    });

    testWidgets('geçerli başlıkla kaydedince createNote çağrılır ve bir önceki ekrana dönülür', (
      tester,
    ) async {
      final repository = _FakeNoteRepository(null);
      await _pumpWithRouter(tester, noteRepository: repository);

      await tester.enterText(find.byType(TextField).first, 'Yeni not başlığı');
      await tester.pump();
      await tester.tap(find.text('Notu Kaydet'));
      await tester.pumpAndSettle();

      expect(repository.lastCreated?.title, 'Yeni not başlığı');
      expect(find.text('Not Listesi'), findsOneWidget);
    });
  });

  group('Düzenleme modu (noteId dolu)', () {
    testWidgets('not bulunamazsa "Bu not artık mevcut değil." gösterir', (tester) async {
      await _pumpWithRouter(tester, noteRepository: _FakeNoteRepository(null), noteId: 'n1');

      expect(find.text('Bu not artık mevcut değil.'), findsOneWidget);
    });

    testWidgets('not verisi render olur (başlık alanı önceden doldurulmuş)', (tester) async {
      await _pumpWithRouter(
        tester,
        noteRepository: _FakeNoteRepository(_note()),
        noteId: 'n1',
      );

      expect(find.text('Notu Düzenle'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Alışveriş Listesi'), findsOneWidget);
    });

    testWidgets('Sil -> Vazgeç: repository çağrılmaz, ekranda kalınır', (tester) async {
      final repository = _FakeNoteRepository(_note());
      await _pumpWithRouter(tester, noteRepository: repository, noteId: 'n1');

      await tester.tap(find.byTooltip('Sil'));
      await tester.pumpAndSettle();
      expect(find.text('Notu Sil'), findsOneWidget);

      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();

      expect(repository.deleteCalled, isFalse);
      expect(find.text('Notu Düzenle'), findsOneWidget);
    });

    testWidgets('Sil -> Onayla: repository.deleteNote çağrılır ve bir önceki ekrana dönülür', (
      tester,
    ) async {
      final repository = _FakeNoteRepository(_note());
      await _pumpWithRouter(tester, noteRepository: repository, noteId: 'n1');

      await tester.tap(find.byTooltip('Sil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sil').last);
      await tester.pumpAndSettle();

      expect(repository.deleteCalled, isTrue);
      expect(find.text('Not Listesi'), findsOneWidget);
    });

    testWidgets('sabitleme ikonuna dokununca togglePinned tetiklenir', (tester) async {
      final repository = _FakeNoteRepository(_note());
      await _pumpWithRouter(tester, noteRepository: repository, noteId: 'n1');

      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.push_pin_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('başlık güncellenip kaydedince updateNote çağrılır', (tester) async {
      final repository = _FakeNoteRepository(_note());
      await _pumpWithRouter(tester, noteRepository: repository, noteId: 'n1');

      await tester.enterText(find.byType(TextField).first, 'Güncellenmiş başlık');
      await tester.pump();
      await tester.tap(find.text('Notu Güncelle'));
      await tester.pumpAndSettle();

      expect(repository.lastUpdated?.title, 'Güncellenmiş başlık');
      expect(find.text('Not Listesi'), findsOneWidget);
    });
  });
}
