import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/vault/domain/entities/vault_item.dart';
import 'package:productivity_app/features/vault/domain/repositories/vault_repository.dart';
import 'package:productivity_app/features/vault/domain/usecases/create_vault_item_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/delete_vault_item_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/update_vault_item_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/watch_vault_item_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/watch_vault_items_usecase.dart';

VaultItem _item({String itemId = 'v1'}) => VaultItem(
      itemId: itemId,
      title: 'Örnek Kayıt',
      category: VaultItemCategory.app,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeVaultRepository implements VaultRepository {
  Result<VaultItem>? itemResult;
  Result<void>? deleteResult;
  List<VaultItem> watchItemsResult = const [];
  VaultItem? watchItemResult;

  VaultItem? lastCreated;
  VaultItem? lastUpdated;
  String? lastDeletedId;
  String? lastWatchedId;
  String? lastFolderFilter;

  @override
  String newVaultItemId() => 'generated-id';

  @override
  Stream<List<VaultItem>> watchVaultItems({String? folderId}) {
    lastFolderFilter = folderId;
    return Stream.value(watchItemsResult);
  }

  @override
  Stream<VaultItem?> watchVaultItem(String itemId) {
    lastWatchedId = itemId;
    return Stream.value(watchItemResult);
  }

  @override
  Future<Result<VaultItem>> createVaultItem(VaultItem item) async {
    lastCreated = item;
    return itemResult!;
  }

  @override
  Future<Result<VaultItem>> updateVaultItem(VaultItem item) async {
    lastUpdated = item;
    return itemResult!;
  }

  @override
  Future<Result<void>> deleteVaultItem(String itemId) async {
    lastDeletedId = itemId;
    return deleteResult!;
  }
}

void main() {
  late _FakeVaultRepository repo;

  setUp(() => repo = _FakeVaultRepository());

  test('WatchVaultItemsUseCase repository sonucunu iletir', () async {
    repo.watchItemsResult = [_item()];
    final result = await WatchVaultItemsUseCase(repo).call().first;
    expect(result.single.itemId, 'v1');
  });

  test('WatchVaultItemUseCase itemId\'yi iletir', () async {
    repo.watchItemResult = _item();
    await WatchVaultItemUseCase(repo).call('v1').first;
    expect(repo.lastWatchedId, 'v1');
  });

  test('CreateVaultItemUseCase kaydı repository\'ye iletir', () async {
    repo.itemResult = Ok(_item());
    final result = await CreateVaultItemUseCase(repo).call(_item());
    expect(repo.lastCreated?.itemId, 'v1');
    expect(result, isA<Ok<VaultItem>>());
  });

  test('UpdateVaultItemUseCase kaydı repository\'ye iletir', () async {
    repo.itemResult = Ok(_item());
    await UpdateVaultItemUseCase(repo).call(_item());
    expect(repo.lastUpdated?.itemId, 'v1');
  });

  test('DeleteVaultItemUseCase itemId\'yi iletir', () async {
    repo.deleteResult = const Ok(null);
    await DeleteVaultItemUseCase(repo).call('v1');
    expect(repo.lastDeletedId, 'v1');
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.itemResult = const Err(CacheFailure('boom'));
    final result = await CreateVaultItemUseCase(repo).call(_item());
    expect(result, isA<Err<VaultItem>>());
  });
}
