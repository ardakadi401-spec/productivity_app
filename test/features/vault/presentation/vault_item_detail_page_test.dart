import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/vault/domain/entities/vault_item.dart';
import 'package:productivity_app/features/vault/domain/repositories/vault_repository.dart';
import 'package:productivity_app/features/vault/presentation/pages/vault_item_detail_page.dart';
import 'package:productivity_app/features/vault/presentation/providers/vault_providers.dart';

class _FakeVaultRepository implements VaultRepository {
  _FakeVaultRepository(this.item);

  VaultItem? item;
  VaultItem? lastUpdated;
  bool deleteCalled = false;
  final _controller = StreamController<VaultItem?>.broadcast();

  @override
  String newVaultItemId() => 'new-id';

  @override
  Stream<List<VaultItem>> watchVaultItems({String? folderId}) => Stream.value(const []);

  @override
  Stream<VaultItem?> watchVaultItem(String itemId) => Stream<VaultItem?>.multi((controller) {
        controller.add(item);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<Result<VaultItem>> createVaultItem(VaultItem item) => throw UnimplementedError();

  @override
  Future<Result<VaultItem>> updateVaultItem(VaultItem item) async {
    lastUpdated = item;
    this.item = item;
    _controller.add(item);
    return Ok(item);
  }

  @override
  Future<Result<void>> deleteVaultItem(String itemId) async {
    deleteCalled = true;
    item = null;
    _controller.add(null);
    return const Ok(null);
  }
}

VaultItem _item({
  String itemId = 'v1',
  String password = 'gizli-123',
}) =>
    VaultItem(
      itemId: itemId,
      title: 'GitHub',
      category: VaultItemCategory.app,
      username: 'ardak',
      password: password,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Future<GoRouter> _pumpWithRouter(WidgetTester tester, {required _FakeVaultRepository repository}) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/list',
    routes: [
      GoRoute(path: '/list', builder: (_, _) => const Scaffold(body: Text('Kasa Listesi'))),
      GoRoute(path: '/detail', builder: (_, _) => const VaultItemDetailPage(itemId: 'v1')),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [vaultRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.push('/detail');
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('kayıt verisi render olur (başlık, kullanıcı adı)', (tester) async {
    await _pumpWithRouter(tester, repository: _FakeVaultRepository(_item()));

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('ardak'), findsOneWidget);
  });

  testWidgets('şifre alanı varsayılan olarak gizlenir, göz ikonuyla gösterilir', (tester) async {
    await _pumpWithRouter(tester, repository: _FakeVaultRepository(_item()));

    final passwordField = tester.widget<TextField>(find.byType(TextField).at(2));
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byTooltip('Göster'));
    await tester.pump();

    final revealed = tester.widget<TextField>(find.byType(TextField).at(2));
    expect(revealed.obscureText, isFalse);
  });

  testWidgets('Sil -> Onayla: deleteVaultItem çağrılır ve bir önceki ekrana dönülür', (tester) async {
    final repository = _FakeVaultRepository(_item());
    await _pumpWithRouter(tester, repository: repository);

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('Kaydı Sil'), findsOneWidget);

    await tester.tap(find.text('Sil').last);
    await tester.pumpAndSettle();

    expect(repository.deleteCalled, isTrue);
    expect(find.text('Kasa Listesi'), findsOneWidget);
  });

  testWidgets('başlık güncellenip Güncelle basılınca updateVaultItem çağrılır', (tester) async {
    final repository = _FakeVaultRepository(_item());
    await _pumpWithRouter(tester, repository: repository);

    await tester.enterText(find.byType(TextField).first, 'GitHub (İş)');
    await tester.pump();
    await tester.tap(find.text('Güncelle'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdated?.title, 'GitHub (İş)');
  });

  testWidgets('boş başlıkla kaydetmeye çalışınca hata gösterilir, repository çağrılmaz', (tester) async {
    final repository = _FakeVaultRepository(_item());
    await _pumpWithRouter(tester, repository: repository);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    await tester.tap(find.text('Güncelle'));
    await tester.pump();

    expect(find.text('Başlık boş olamaz.'), findsOneWidget);
    expect(repository.lastUpdated, isNull);
  });
}
