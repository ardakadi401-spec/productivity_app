import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/vault/data/datasources/local/vault_folder_local_datasource.dart';
import 'package:productivity_app/features/vault/data/datasources/local/vault_local_datasource.dart';
import 'package:productivity_app/features/vault/data/datasources/remote/vault_folder_remote_datasource.dart';
import 'package:productivity_app/features/vault/data/datasources/remote/vault_remote_datasource.dart';
import 'package:productivity_app/features/vault/data/models/vault_folder_local_model.dart';
import 'package:productivity_app/features/vault/data/models/vault_item_local_model.dart';
import 'package:productivity_app/features/vault/data/repositories/vault_folder_repository_impl.dart';
import 'package:productivity_app/features/vault/domain/entities/vault_folder.dart';

class _MockFolderLocal extends Mock implements VaultFolderLocalDatasource {}

class _MockFolderRemote extends Mock implements VaultFolderRemoteDatasource {}

class _MockItemLocal extends Mock implements VaultLocalDatasource {}

class _MockItemRemote extends Mock implements VaultRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

VaultFolderLocalModel _folderModel(
  String folderId, {
  String? parentFolderId,
  VaultFolderSyncStatusLocal syncStatus = VaultFolderSyncStatusLocal.synced,
}) {
  final now = DateTime(2026, 1, 1);
  return VaultFolderLocalModel()
    ..folderId = folderId
    ..name = 'Klasör $folderId'
    ..parentFolderId = parentFolderId
    ..createdAt = now
    ..updatedAt = now
    ..isDeleted = false
    ..syncStatus = syncStatus
    ..localUpdatedAt = now;
}

VaultItemLocalModel _itemModel(String itemId, {String? folderId}) {
  final now = DateTime(2026, 1, 1);
  return VaultItemLocalModel()
    ..itemId = itemId
    ..title = 'Kayıt $itemId'
    ..category = VaultItemCategoryLocal.other
    ..folderId = folderId
    ..createdAt = now
    ..updatedAt = now
    ..isDeleted = false
    ..syncStatus = VaultItemSyncStatusLocal.synced
    ..localUpdatedAt = now;
}

void main() {
  late _MockFolderLocal folderLocal;
  late _MockFolderRemote folderRemote;
  late _MockItemLocal itemLocal;
  late _MockItemRemote itemRemote;
  late _MockConnectivity connectivity;
  late VaultFolderRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_folderModel('fallback'));
    registerFallbackValue(_itemModel('fallback'));
  });

  setUp(() {
    folderLocal = _MockFolderLocal();
    folderRemote = _MockFolderRemote();
    itemLocal = _MockItemLocal();
    itemRemote = _MockItemRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => folderLocal.getPendingSync()).thenAnswer((_) async => []);
    repository = VaultFolderRepositoryImpl(folderLocal, folderRemote, itemLocal, itemRemote, connectivity);
  });

  group('createVaultFolder', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar', () async {
      when(() => folderLocal.putVaultFolder(any())).thenAnswer((_) async {});

      final folder = VaultFolder(
        folderId: 'f1',
        name: 'ELS İNŞAAT',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final result = await repository.createVaultFolder(folder);

      expect(result, isA<Ok<VaultFolder>>());
      final captured =
          verify(() => folderLocal.putVaultFolder(captureAny())).captured.single as VaultFolderLocalModel;
      expect(captured.syncStatus, VaultFolderSyncStatusLocal.pendingCreate);
      verifyNever(() => folderRemote.setVaultFolder(any()));
    });
  });

  group('renameVaultFolder', () {
    test('adı ve syncStatus\'u günceller', () async {
      when(() => folderLocal.getByFolderId('f1')).thenAnswer((_) async => _folderModel('f1'));
      when(() => folderLocal.putVaultFolder(any())).thenAnswer((_) async {});

      final result = await repository.renameVaultFolder('f1', 'Yeni Ad');

      expect(result, isA<Ok<VaultFolder>>());
      final captured =
          verify(() => folderLocal.putVaultFolder(captureAny())).captured.single as VaultFolderLocalModel;
      expect(captured.name, 'Yeni Ad');
      expect(captured.syncStatus, VaultFolderSyncStatusLocal.pendingUpdate);
    });

    test('klasör bulunamazsa CacheFailure döner', () async {
      when(() => folderLocal.getByFolderId('missing')).thenAnswer((_) async => null);

      final result = await repository.renameVaultFolder('missing', 'x');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('deleteVaultFolder — rekürsif (cascade) silme', () {
    test('alt klasörleri VE içindeki tüm kayıtları siler, ilişkisiz olanlara dokunmaz', () async {
      // Ağaç: f1 (kök) -> f2 -> f3 ; f4 ilişkisiz kardeş klasör.
      final f1 = _folderModel('f1');
      final f2 = _folderModel('f2', parentFolderId: 'f1');
      final f3 = _folderModel('f3', parentFolderId: 'f2');
      final f4 = _folderModel('f4');
      when(() => folderLocal.getByFolderId('f1')).thenAnswer((_) async => f1);
      when(() => folderLocal.getAll()).thenAnswer((_) async => [f1, f2, f3, f4]);
      when(() => folderLocal.putVaultFolder(any())).thenAnswer((_) async {});

      // i1 kökte (f1), i2 f2'de, i3 f3'te, i4 ilişkisiz f4'te, i5 kasanın kökünde (folderId null).
      final i1 = _itemModel('i1', folderId: 'f1');
      final i2 = _itemModel('i2', folderId: 'f2');
      final i3 = _itemModel('i3', folderId: 'f3');
      final i4 = _itemModel('i4', folderId: 'f4');
      final i5 = _itemModel('i5');
      when(() => itemLocal.getAll()).thenAnswer((_) async => [i1, i2, i3, i4, i5]);
      when(() => itemLocal.putVaultItem(any())).thenAnswer((_) async {});

      final result = await repository.deleteVaultFolder('f1');

      expect(result, isA<Ok<void>>());

      final deletedFolders = verify(() => folderLocal.putVaultFolder(captureAny()))
          .captured
          .cast<VaultFolderLocalModel>()
          .map((m) => m.folderId)
          .toSet();
      expect(deletedFolders, {'f1', 'f2', 'f3'});
      expect(f1.isDeleted, isTrue);
      expect(f2.isDeleted, isTrue);
      expect(f3.isDeleted, isTrue);
      expect(f4.isDeleted, isFalse);

      final deletedItems = verify(() => itemLocal.putVaultItem(captureAny()))
          .captured
          .cast<VaultItemLocalModel>()
          .map((m) => m.itemId)
          .toSet();
      expect(deletedItems, {'i1', 'i2', 'i3'});
      expect(i4.isDeleted, isFalse);
      expect(i5.isDeleted, isFalse);
    });

    test('klasör bulunamazsa CacheFailure döner', () async {
      when(() => folderLocal.getByFolderId('missing')).thenAnswer((_) async => null);

      final result = await repository.deleteVaultFolder('missing');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });
}
