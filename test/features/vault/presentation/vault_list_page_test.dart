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
import 'package:productivity_app/features/vault/presentation/pages/vault_list_page.dart';
import 'package:productivity_app/features/vault/presentation/providers/vault_providers.dart';

class _FakeVaultRepository implements VaultRepository {
  List<VaultItem> items = const [];
  VaultItem? lastCreated;
  final _controller = StreamController<List<VaultItem>>.broadcast();

  @override
  String newVaultItemId() => 'new-item-id';

  @override
  Stream<List<VaultItem>> watchVaultItems() => Stream<List<VaultItem>>.multi((controller) {
        controller.add(items);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<VaultItem?> watchVaultItem(String itemId) => Stream.value(null);

  @override
  Future<Result<VaultItem>> createVaultItem(VaultItem item) async {
    lastCreated = item;
    items = [...items, item];
    _controller.add(items);
    return Ok(item);
  }

  @override
  Future<Result<VaultItem>> updateVaultItem(VaultItem item) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteVaultItem(String itemId) => throw UnimplementedError();
}

VaultItem _item(String id, String title) => VaultItem(
      itemId: id,
      title: title,
      category: VaultItemCategory.app,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Future<GoRouter> _pumpWithRouter(WidgetTester tester, {required _FakeVaultRepository repository}) async {
  final router = GoRouter(
    initialLocation: '/list',
    routes: [
      GoRoute(path: '/list', builder: (_, _) => const Scaffold(body: VaultListPage())),
      GoRoute(path: '/vault/new', builder: (_, _) => const VaultItemDetailPage()),
      GoRoute(
        path: '/vault/:itemId',
        builder: (_, state) =>
            Scaffold(body: Text('Kasa Kaydı: ${state.pathParameters['itemId']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [vaultRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pump();
  return router;
}

void main() {
  testWidgets('kasa boşken boş durum gösterir', (tester) async {
    await _pumpWithRouter(tester, repository: _FakeVaultRepository());

    expect(find.text('Kasan henüz boş'), findsOneWidget);
  });

  testWidgets('kayıtlar alfabetik sıralı listelenir', (tester) async {
    final repository = _FakeVaultRepository()
      ..items = [_item('v1', 'Zeta Hesabı'), _item('v2', 'Alfa Hesabı')];
    await _pumpWithRouter(tester, repository: repository);

    final titles = tester
        .widgetList<Text>(find.textContaining('Hesabı'))
        .map((t) => t.data)
        .toList();
    expect(titles, ['Alfa Hesabı', 'Zeta Hesabı']);
  });

  testWidgets(
    '"Yeni Kayıt" FAB\'ı VaultItemDetailPage açar; geçerli başlıkla kaydedilince '
    'createVaultItem çağrılır ve bir önceki ekrana dönülür',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _FakeVaultRepository();
      await _pumpWithRouter(tester, repository: repository);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Netflix');
      await tester.pump();
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(repository.lastCreated?.title, 'Netflix');
      expect(find.text('Kasan henüz boş'), findsNothing);
    },
  );
}
