import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/core/sync/sync_coordinator.dart';
import 'package:productivity_app/core/sync/sync_state.dart';
import 'package:productivity_app/core/sync/syncable_repository.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/shared/components/sync_status_indicator_widget.dart';

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _CountingRepository implements SyncableRepository {
  int callCount = 0;

  @override
  Future<void> syncPending() async {
    callCount++;
  }
}

Future<void> pumpIndicator(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: SyncStatusIndicatorWidget()),
      ),
    ),
  );
}

void main() {
  testWidgets('synced durumunda "Senkronize" gösterir, Tekrar Dene YOK', (tester) async {
    await pumpIndicator(
      tester,
      overrides: [
        syncUiStateProvider.overrideWith(
          (ref) => const SyncUiState(status: SyncStatus.synced),
        ),
      ],
    );

    expect(find.text('Senkronize'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsNothing);
  });

  testWidgets('syncing durumunda "Senkronize ediliyor" gösterir', (tester) async {
    await pumpIndicator(
      tester,
      overrides: [
        syncUiStateProvider.overrideWith(
          (ref) => const SyncUiState(status: SyncStatus.syncing),
        ),
      ],
    );

    expect(find.text('Senkronize ediliyor'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsNothing);
  });

  testWidgets('pending durumunda "Bekleyen değişiklikler" gösterir', (tester) async {
    await pumpIndicator(
      tester,
      overrides: [
        syncUiStateProvider.overrideWith(
          (ref) => const SyncUiState(status: SyncStatus.pending),
        ),
      ],
    );

    expect(find.text('Bekleyen değişiklikler'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsNothing);
  });

  testWidgets('error durumunda "Senkronizasyon hatası" ve Tekrar Dene gösterir', (tester) async {
    await pumpIndicator(
      tester,
      overrides: [
        syncUiStateProvider.overrideWith(
          (ref) => const SyncUiState(status: SyncStatus.error),
        ),
      ],
    );

    expect(find.text('Senkronizasyon hatası'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsOneWidget);
  });

  testWidgets('Tekrar Dene, SyncCoordinator.retry() üzerinden çalışır (repository private metoduna dokunmaz)', (
    tester,
  ) async {
    final repository = _CountingRepository();
    // "Tekrar Dene", syncCoordinatorProvider'ı okur — bu da connectivityStatus
    // Provider'ı (dolayısıyla connectivityServiceProvider'ı) tetikler; gerçek
    // `connectivity_plus` platform kanalı widget testinde yok, bu yüzden
    // sahte bir ConnectivityService override edilir (bkz. proje hafızası:
    // "widget testte root plugin çağrılarını guard'la").
    final connectivity = _MockConnectivityService();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => connectivity.onStatusChange).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncUiStateProvider.overrideWith(
            (ref) => const SyncUiState(status: SyncStatus.error),
          ),
          syncableRepositoriesProvider.overrideWithValue([repository]),
          connectivityServiceProvider.overrideWithValue(connectivity),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SyncStatusIndicatorWidget()),
        ),
      ),
    );

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();
    await tester.pump();

    expect(repository.callCount, 1);
  });
}
