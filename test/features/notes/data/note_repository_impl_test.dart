import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/notes/data/datasources/local/note_local_datasource.dart';
import 'package:productivity_app/features/notes/data/datasources/remote/note_remote_datasource.dart';
import 'package:productivity_app/features/notes/data/models/note_local_model.dart';
import 'package:productivity_app/features/notes/data/repositories/note_repository_impl.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';

class _MockLocal extends Mock implements NoteLocalDatasource {}

class _MockRemote extends Mock implements NoteRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

Note _note({String noteId = 'n1'}) => Note(
      noteId: noteId,
      title: 'Not',
      isPinned: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

NoteLocalModel _model({
  String noteId = 'n1',
  String? projectId,
  String? taskId,
  List<String> tagIds = const [],
  NoteSyncStatusLocal syncStatus = NoteSyncStatusLocal.pendingCreate,
}) {
  final now = DateTime(2026, 1, 1);
  return NoteLocalModel()
    ..noteId = noteId
    ..title = 'Not'
    ..projectId = projectId
    ..taskId = taskId
    ..tagIds = tagIds
    ..isPinned = false
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
  late NoteRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = NoteRepositoryImpl(local, remote, connectivity);
  });

  group('createNote', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putNote(any())).thenAnswer((_) async {});

      final result = await repository.createNote(_note());

      expect(result, isA<Ok<Note>>());
      final captured = verify(() => local.putNote(captureAny())).captured.single as NoteLocalModel;
      expect(captured.syncStatus, NoteSyncStatusLocal.pendingCreate);
      verifyNever(() => remote.setNote(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putNote(any())).thenAnswer((_) async {});
      when(() => remote.setNote(any())).thenAnswer((_) async {});

      await repository.createNote(_note());

      verify(() => remote.setNote(any())).called(1);
      final calls = verify(() => local.putNote(captureAny())).captured.cast<NoteLocalModel>();
      expect(calls.last.syncStatus, NoteSyncStatusLocal.synced);
    });

    test('remote gönderimi başarısız olursa kayıt pending kalır ama Ok döner', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putNote(any())).thenAnswer((_) async {});
      when(() => remote.setNote(any())).thenThrow(const NetworkException('boom'));

      final result = await repository.createNote(_note());

      expect(result, isA<Ok<Note>>());
      final calls = verify(() => local.putNote(captureAny())).captured.cast<NoteLocalModel>();
      expect(calls.last.syncStatus, NoteSyncStatusLocal.pendingCreate);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putNote(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createNote(_note());

      expect(result, isA<Err<Note>>());
      final failure = (result as Err).failure;
      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'disk dolu');
    });
  });

  group('syncPending — FAZ 14 (SyncCoordinator giriş noktası)', () {
    test('offline durumda hiçbir şey yapmaz', () async {
      await Future<void>.delayed(Duration.zero);

      await repository.syncPending();

      verifyNever(() => remote.setNote(any()));
    });

    test('pendingCreate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: NoteSyncStatusLocal.pendingCreate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setNote(any())).thenAnswer((_) async {});
      when(() => local.putNote(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setNote(pendingModel)).called(1);
      final captured = verify(() => local.putNote(captureAny())).captured.single as NoteLocalModel;
      expect(captured.syncStatus, NoteSyncStatusLocal.synced);
    });

    test('pendingDelete kaydını online olduğunda gönderir ve synced yapar (ADIM 2 düzeltmesi korunuyor)', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: NoteSyncStatusLocal.pendingDelete)
        ..isDeleted = true
        ..deletedAt = DateTime(2026, 1, 2);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setNote(any())).thenAnswer((_) async {});
      when(() => local.putNote(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setNote(pendingModel)).called(1);
      final captured = verify(() => local.putNote(captureAny())).captured.single as NoteLocalModel;
      expect(captured.syncStatus, NoteSyncStatusLocal.synced);
      expect(captured.isDeleted, isTrue);
    });

    test('remote gönderimi hata verirse kayıt pending kalır', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: NoteSyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setNote(any())).thenThrow(const NetworkException('boom'));

      await repository.syncPending();

      verifyNever(() => local.putNote(any()));
      expect(pendingModel.syncStatus, NoteSyncStatusLocal.pendingUpdate);
    });
  });

  group('deleteNote', () {
    test('mevcut kaydı soft-delete olarak işaretler ve syncStatus\'u pendingDelete yapar', () async {
      when(() => local.getByNoteId('n1')).thenAnswer((_) async => _model());
      when(() => local.putNote(any())).thenAnswer((_) async {});

      final result = await repository.deleteNote('n1');

      expect(result, isA<Ok<void>>());
      final captured = verify(() => local.putNote(captureAny())).captured.single as NoteLocalModel;
      expect(captured.isDeleted, isTrue);
      expect(captured.deletedAt, isNotNull);
      expect(captured.syncStatus, NoteSyncStatusLocal.pendingDelete);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getByNoteId('missing')).thenAnswer((_) async => null);

      final result = await repository.deleteNote('missing');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('setLink', () {
    test('projectId set eder, taskId dokunmaz', () async {
      when(() => local.getByNoteId('n1')).thenAnswer((_) async => _model(taskId: 't1'));
      when(() => local.putNote(any())).thenAnswer((_) async {});

      final result = await repository.setLink('n1', projectId: 'p1');

      expect(result, isA<Ok<Note>>());
      final captured = verify(() => local.putNote(captureAny())).captured.single as NoteLocalModel;
      expect(captured.projectId, 'p1');
      expect(captured.taskId, 't1');
    });

    test('clearProjectId ile bağlantı temizlenir', () async {
      when(() => local.getByNoteId('n1')).thenAnswer((_) async => _model(projectId: 'p1'));
      when(() => local.putNote(any())).thenAnswer((_) async {});

      await repository.setLink('n1', clearProjectId: true);

      final captured = verify(() => local.putNote(captureAny())).captured.single as NoteLocalModel;
      expect(captured.projectId, isNull);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getByNoteId('missing')).thenAnswer((_) async => null);

      final result = await repository.setLink('missing', projectId: 'p1');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('uzaktan senkronizasyon (Last-Write-Wins) — FAZ 14', () {
    // `_syncFromRemote` yalnızca constructor'da (bağlantı zaten `true`
    // stub'lanmış durumda) çalıştığından, bu testler kendi bağımsız
    // repository örneğini kurar — paylaşılan `repository` (setUp'ta
    // offline kurulan) kullanılmaz.
    test('remote kaydı localden daha yeniyse yerel güncellenir', () async {
      final localModel = _model(syncStatus: NoteSyncStatusLocal.synced)
        ..localUpdatedAt = DateTime(2026, 1, 1);
      final remoteModel = _model(syncStatus: NoteSyncStatusLocal.synced)
        ..title = 'Uzaktan güncellendi'
        ..updatedAt = DateTime(2026, 1, 5);

      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchAllNotes()).thenAnswer((_) async => [remoteModel]);
      when(() => local.getByNoteId('n1')).thenAnswer((_) async => localModel);
      when(() => local.putNote(any())).thenAnswer((_) async {});

      NoteRepositoryImpl(local, remote, connectivity);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verify(() => local.putNote(remoteModel)).called(1);
    });

    test('yereldeki pending değişiklik remote eskiyse EZİLMEZ', () async {
      final localModel = _model(syncStatus: NoteSyncStatusLocal.pendingUpdate)
        ..title = 'Henüz gönderilmemiş yerel değişiklik'
        ..localUpdatedAt = DateTime(2026, 1, 10);
      final remoteModel = _model(syncStatus: NoteSyncStatusLocal.synced)
        ..updatedAt = DateTime(2026, 1, 1);

      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchAllNotes()).thenAnswer((_) async => [remoteModel]);
      when(() => local.getByNoteId('n1')).thenAnswer((_) async => localModel);
      when(() => local.getPendingSync()).thenAnswer((_) async => []);

      NoteRepositoryImpl(local, remote, connectivity);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Eski remote sürümüyle yerel ASLA üzerine yazılmaz.
      verifyNever(() => local.putNote(remoteModel));
    });

    test('soft-delete edilmiş yerel kayıt, eski remote sürümüyle geri gelmez', () async {
      final deletedLocal = _model(syncStatus: NoteSyncStatusLocal.pendingDelete)
        ..isDeleted = true
        ..deletedAt = DateTime(2026, 1, 10)
        ..localUpdatedAt = DateTime(2026, 1, 10);
      // Remote, silme henüz senkronize olmadığı için hâlâ eski/silinmemiş
      // sürümü gösteriyor (daha eski `updatedAt` ile).
      final staleRemote = _model(syncStatus: NoteSyncStatusLocal.synced)
        ..isDeleted = false
        ..updatedAt = DateTime(2026, 1, 5);

      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchAllNotes()).thenAnswer((_) async => [staleRemote]);
      when(() => local.getByNoteId('n1')).thenAnswer((_) async => deletedLocal);
      when(() => local.getPendingSync()).thenAnswer((_) async => []);

      NoteRepositoryImpl(local, remote, connectivity);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Silinmiş kayıt, eski/silinmemiş remote sürümüyle geri gelmez.
      verifyNever(() => local.putNote(staleRemote));
    });
  });

  group('watchNotes filtreleme', () {
    test('filtre verilmezse tüm notları döner', () async {
      final a = _model(noteId: 'a');
      final b = _model(noteId: 'b', projectId: 'p1');
      when(() => local.watchNotes()).thenAnswer((_) => Stream.value([a, b]));

      final result = await repository.watchNotes().first;

      expect(result.map((n) => n.noteId), ['a', 'b']);
    });

    test('projectId filtresi yalnızca eşleşen notları döner', () async {
      final a = _model(noteId: 'a', projectId: 'p1');
      final b = _model(noteId: 'b', projectId: 'p2');
      when(() => local.watchNotes()).thenAnswer((_) => Stream.value([a, b]));

      final result = await repository.watchNotes(filter: const NoteFilter(projectId: 'p1')).first;

      expect(result.map((n) => n.noteId), ['a']);
    });

    test('taskId filtresi yalnızca eşleşen notları döner', () async {
      final a = _model(noteId: 'a', taskId: 't1');
      final b = _model(noteId: 'b', taskId: 't2');
      when(() => local.watchNotes()).thenAnswer((_) => Stream.value([a, b]));

      final result = await repository.watchNotes(filter: const NoteFilter(taskId: 't1')).first;

      expect(result.map((n) => n.noteId), ['a']);
    });

    test(
      'tagIds filtresi BİRLEŞİM (OR) mantığıyla çalışır — seçili etiketlerden en az birine '
      'sahip notlar listelenir (ROADMAP FAZ 10 test noktası)',
      () async {
        final matchesFirst = _model(noteId: 'a', tagIds: const ['work']);
        final matchesSecond = _model(noteId: 'b', tagIds: const ['personal']);
        final matchesBoth = _model(noteId: 'c', tagIds: const ['work', 'personal']);
        final matchesNeither = _model(noteId: 'd', tagIds: const ['other']);
        when(() => local.watchNotes())
            .thenAnswer((_) => Stream.value([matchesFirst, matchesSecond, matchesBoth, matchesNeither]));

        final result =
            await repository.watchNotes(filter: const NoteFilter(tagIds: ['work', 'personal'])).first;

        expect(result.map((n) => n.noteId), ['a', 'b', 'c']);
      },
    );

    test('birden fazla filtre birlikte AND olarak uygulanır (proje + etiket)', () async {
      final match = _model(noteId: 'a', projectId: 'p1', tagIds: const ['work']);
      final wrongProject = _model(noteId: 'b', projectId: 'p2', tagIds: const ['work']);
      final wrongTag = _model(noteId: 'c', projectId: 'p1', tagIds: const ['other']);
      when(() => local.watchNotes()).thenAnswer((_) => Stream.value([match, wrongProject, wrongTag]));

      final result = await repository
          .watchNotes(filter: const NoteFilter(projectId: 'p1', tagIds: ['work']))
          .first;

      expect(result.map((n) => n.noteId), ['a']);
    });
  });
}
