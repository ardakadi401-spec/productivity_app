import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';
import 'package:productivity_app/features/notes/domain/repositories/note_repository.dart';
import 'package:productivity_app/features/notes/presentation/pages/notes_list_page.dart';
import 'package:productivity_app/features/notes/presentation/providers/note_providers.dart';
import 'package:productivity_app/shared/components/note_card_widget.dart';

class _FakeNoteRepository implements NoteRepository {
  List<Note> notes = const [];

  @override
  String newNoteId() => 'id';

  @override
  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none}) => Stream.value(notes);

  @override
  Stream<Note?> watchNote(String noteId) => const Stream.empty();

  @override
  Future<Result<Note>> createNote(Note note) => throw UnimplementedError();
  @override
  Future<Result<Note>> updateNote(Note note) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteNote(String noteId) => throw UnimplementedError();
  @override
  Future<Result<Note>> setPinned(String noteId, {required bool isPinned}) => throw UnimplementedError();
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

Note _note({String noteId = 'n1', String title = 'Not', bool isPinned = false}) => Note(
      noteId: noteId,
      title: title,
      isPinned: isPinned,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget _wrap(_FakeNoteRepository fake) {
  return ProviderScope(
    overrides: [noteRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const NotesListPage()),
  );
}

void main() {
  testWidgets('not listesi boşken boş durum gösterir', (tester) async {
    await tester.pumpWidget(_wrap(_FakeNoteRepository()));
    await tester.pump();

    expect(find.text('Henüz not eklemedin'), findsOneWidget);
    expect(find.text('Not Ekle'), findsOneWidget);
  });

  testWidgets(
    'Task/Project repository provider\'ları override edilmemiş olsa bile liste render '
    'edilir — CleanupOrphanedNoteLinksUseCase\'in senkron fırlatması try/catch ile yutulur '
    '(cross-feature-test-safety deseni)',
    (tester) async {
      final fake = _FakeNoteRepository()..notes = [_note(noteId: 'n1', title: 'Alışveriş listesi')];

      await tester.pumpWidget(_wrap(fake));
      await tester.pump();

      expect(find.text('Alışveriş listesi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('sabitlenmiş ve normal notlar ayrı bölümlerde gösterilir', (tester) async {
    final fake = _FakeNoteRepository()
      ..notes = [
        _note(noteId: 'n1', title: 'Sabit Not', isPinned: true),
        _note(noteId: 'n2', title: 'Normal Not'),
      ];

    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    expect(find.text('Sabitlenmiş'), findsOneWidget);
    expect(find.text('Tümü'), findsOneWidget);
    expect(find.text('Sabit Not'), findsOneWidget);
    expect(find.text('Normal Not'), findsOneWidget);
    expect(find.byType(NoteCardWidget), findsNWidgets(2));
  });

  testWidgets('yalnızca sabitlenmiş notlar varsa "Tümü" bölüm başlığı gösterilmez', (tester) async {
    final fake = _FakeNoteRepository()..notes = [_note(noteId: 'n1', title: 'Sabit Not', isPinned: true)];

    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    expect(find.text('Sabitlenmiş'), findsOneWidget);
    expect(find.text('Tümü'), findsNothing);
  });
}
