import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/tags/data/datasources/local/tag_local_datasource.dart';
import 'package:productivity_app/features/tags/data/datasources/remote/tag_remote_datasource.dart';
import 'package:productivity_app/features/tags/data/models/tag_local_model.dart';
import 'package:productivity_app/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:productivity_app/features/tags/domain/entities/tag.dart';

class _MockLocal extends Mock implements TagLocalDatasource {}

class _MockRemote extends Mock implements TagRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

Tag _tag({String tagId = 'tg1'}) => Tag(
      tagId: tagId,
      name: 'Etiket',
      color: '#FF8A8A',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

TagLocalModel _model({String tagId = 'tg1'}) {
  final now = DateTime(2026, 1, 1);
  return TagLocalModel()
    ..tagId = tagId
    ..name = 'Etiket'
    ..color = '#FF8A8A'
    ..createdAt = now
    ..updatedAt = now
    ..syncStatus = TagSyncStatusLocal.pendingCreate
    ..localUpdatedAt = now;
}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late _MockConnectivity connectivity;
  late TagRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = TagRepositoryImpl(local, remote, connectivity);
  });

  group('createTag', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putTag(any())).thenAnswer((_) async {});

      final result = await repository.createTag(_tag());

      expect(result, isA<Ok<Tag>>());
      final captured = verify(() => local.putTag(captureAny())).captured.single as TagLocalModel;
      expect(captured.syncStatus, TagSyncStatusLocal.pendingCreate);
      verifyNever(() => remote.setTag(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putTag(any())).thenAnswer((_) async {});
      when(() => remote.setTag(any())).thenAnswer((_) async {});

      await repository.createTag(_tag());

      verify(() => remote.setTag(any())).called(1);
      final calls = verify(() => local.putTag(captureAny())).captured.cast<TagLocalModel>();
      expect(calls.last.syncStatus, TagSyncStatusLocal.synced);
    });

    test('remote gönderimi başarısız olursa kayıt pending kalır ama Ok döner', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putTag(any())).thenAnswer((_) async {});
      when(() => remote.setTag(any())).thenThrow(const NetworkException('boom'));

      final result = await repository.createTag(_tag());

      expect(result, isA<Ok<Tag>>());
      final calls = verify(() => local.putTag(captureAny())).captured.cast<TagLocalModel>();
      expect(calls.last.syncStatus, TagSyncStatusLocal.pendingCreate);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putTag(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createTag(_tag());

      expect(result, isA<Err<Tag>>());
      final failure = (result as Err).failure;
      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'disk dolu');
    });
  });

  group('syncPending — FAZ 14 (SyncCoordinator giriş noktası)', () {
    test('offline durumda hiçbir şey yapmaz', () async {
      await Future<void>.delayed(Duration.zero);

      await repository.syncPending();

      verifyNever(() => remote.setTag(any()));
    });

    test('pendingCreate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model();
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setTag(any())).thenAnswer((_) async {});
      when(() => local.putTag(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setTag(pendingModel)).called(1);
      final captured = verify(() => local.putTag(captureAny())).captured.single as TagLocalModel;
      expect(captured.syncStatus, TagSyncStatusLocal.synced);
    });

    test('remote gönderimi hata verirse kayıt pending kalır', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model();
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setTag(any())).thenThrow(const NetworkException('boom'));

      await repository.syncPending();

      verifyNever(() => local.putTag(any()));
      expect(pendingModel.syncStatus, TagSyncStatusLocal.pendingCreate);
    });
  });

  test('watchTags local datasource\'u entity\'ye eşleyerek döner', () async {
    when(() => local.watchTags()).thenAnswer((_) => Stream.value([_model(), _model(tagId: 'tg2')]));

    final result = await repository.watchTags().first;

    expect(result.map((t) => t.tagId), ['tg1', 'tg2']);
  });
}
