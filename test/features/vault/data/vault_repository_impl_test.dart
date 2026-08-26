import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/vault/data/datasources/local/vault_local_datasource.dart';
import 'package:productivity_app/features/vault/data/datasources/remote/vault_remote_datasource.dart';
import 'package:productivity_app/features/vault/data/mappers/vault_item_mapper.dart';
import 'package:productivity_app/features/vault/data/models/vault_item_local_model.dart';
import 'package:productivity_app/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:productivity_app/features/vault/data/services/vault_encryption_service.dart';
import 'package:productivity_app/features/vault/domain/entities/vault_item.dart';

class _MockLocal extends Mock implements VaultLocalDatasource {}

class _MockRemote extends Mock implements VaultRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

VaultItem _item({String itemId = 'v1'}) => VaultItem(
      itemId: itemId,
      title: 'GitHub',
      category: VaultItemCategory.app,
      username: 'ardak',
      password: 'sifre-123',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

VaultItemLocalModel _model({
  String itemId = 'v1',
  VaultItemSyncStatusLocal syncStatus = VaultItemSyncStatusLocal.pendingCreate,
}) {
  final now = DateTime(2026, 1, 1);
  return VaultItemLocalModel()
    ..itemId = itemId
    ..title = 'GitHub'
    ..category = VaultItemCategoryLocal.app
    ..username = 'ardak'
    ..encryptedPassword = 'iv:cipher'
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
  late VaultItemMapper mapper;
  late VaultRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    final auth = _MockAuth();
    final user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('user-1');
    mapper = VaultItemMapper(VaultEncryptionService(auth: auth));
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = VaultRepositoryImpl(local, remote, connectivity, mapper);
  });

  group('createVaultItem', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putVaultItem(any())).thenAnswer((_) async {});

      final result = await repository.createVaultItem(_item());

      expect(result, isA<Ok<VaultItem>>());
      final captured =
          verify(() => local.putVaultItem(captureAny())).captured.single as VaultItemLocalModel;
      expect(captured.syncStatus, VaultItemSyncStatusLocal.pendingCreate);
      expect(captured.encryptedPassword, isNot('sifre-123'));
      verifyNever(() => remote.setVaultItem(any()));
    });

    test('yerele yazılan şifre alanı şifrelidir, döndürülen entity çözülmüş düz metindir', () async {
      when(() => local.putVaultItem(any())).thenAnswer((_) async {});

      final result = await repository.createVaultItem(_item());

      final captured =
          verify(() => local.putVaultItem(captureAny())).captured.single as VaultItemLocalModel;
      expect(captured.encryptedPassword, contains(':'));
      expect((result as Ok<VaultItem>).value.password, 'sifre-123');
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putVaultItem(any())).thenAnswer((_) async {});
      when(() => remote.setVaultItem(any())).thenAnswer((_) async {});

      await repository.createVaultItem(_item());

      verify(() => remote.setVaultItem(any())).called(1);
      final calls =
          verify(() => local.putVaultItem(captureAny())).captured.cast<VaultItemLocalModel>();
      expect(calls.last.syncStatus, VaultItemSyncStatusLocal.synced);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putVaultItem(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createVaultItem(_item());

      expect(result, isA<Err<VaultItem>>());
      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('deleteVaultItem', () {
    test('isDeleted true ve syncStatus pendingDelete olarak işaretlenir', () async {
      when(() => local.getByItemId('v1')).thenAnswer((_) async => _model());
      when(() => local.putVaultItem(any())).thenAnswer((_) async {});

      final result = await repository.deleteVaultItem('v1');

      expect(result, isA<Ok<void>>());
      final captured =
          verify(() => local.putVaultItem(captureAny())).captured.single as VaultItemLocalModel;
      expect(captured.isDeleted, isTrue);
      expect(captured.syncStatus, VaultItemSyncStatusLocal.pendingDelete);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getByItemId('missing')).thenAnswer((_) async => null);

      final result = await repository.deleteVaultItem('missing');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('watchVaultItems', () {
    test('yerel modelleri çözülmüş entity listesine eşler', () async {
      final encryptedModel =
          mapper.fromEntity(_item(), syncStatus: VaultItemSyncStatusLocal.synced);
      when(() => local.watchVaultItems()).thenAnswer((_) => Stream.value([encryptedModel]));

      final result = await repository.watchVaultItems().first;

      expect(result.single.password, 'sifre-123');
    });
  });
}
