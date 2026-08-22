import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/core/sync/sync_coordinator.dart';
import 'package:productivity_app/core/sync/sync_state.dart';
import 'package:productivity_app/core/sync/syncable_repository.dart';

class _MockConnectivityService extends Mock implements ConnectivityService {}

/// `syncPending()` çağrılarını sayan, isteğe bağlı olarak bir `Completer`
/// ile bloklanabilen veya belirli bir çağrıda hata fırlatabilen test çifti.
class _RecordingRepository implements SyncableRepository {
  Completer<void>? gate;
  int? throwOnCall;
  int callCount = 0;

  @override
  Future<void> syncPending() async {
    callCount++;
    if (throwOnCall != null && callCount == throwOnCall) {
      throw Exception('senkronizasyon hatası');
    }
    final currentGate = gate;
    if (currentGate != null) {
      await currentGate.future;
    }
  }
}

/// Bekleyen mikrotask zincirlerinin (stream → StreamProvider async* →
/// ref.listen → coordinator) tamamen yerleşmesi için tek bir event-loop
/// turu bekler; `Duration.zero` bir timer olduğundan, ateşlenmeden önce
/// birikmiş tüm mikrotaskları Dart runtime'ı otomatik olarak boşaltır.
Future<void> pump([int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _MockConnectivityService service;
  late StreamController<bool> statusController;
  late _RecordingRepository repository;
  late ProviderContainer container;

  ProviderContainer buildContainer({required bool initiallyConnected}) {
    service = _MockConnectivityService();
    statusController = StreamController<bool>.broadcast();
    repository = _RecordingRepository();
    when(() => service.isConnected).thenAnswer((_) async => initiallyConnected);
    when(() => service.onStatusChange).thenAnswer((_) => statusController.stream);

    return ProviderContainer(
      overrides: [
        connectivityServiceProvider.overrideWithValue(service),
        syncableRepositoriesProvider.overrideWithValue([repository]),
      ],
    );
  }

  tearDown(() async {
    await statusController.close();
    // Dispose testi container'ı kendi içinde zaten dispose ediyor —
    // ikinci kez dispose etmeyi güvenle yok sayar (Riverpod, dispose
    // edilmiş bir container üzerinde tekrar `dispose()` çağrılmasına
    // izin vermez).
    try {
      container.dispose();
    } catch (_) {}
  });

  test('offline → online geçişinde sync tetikleniyor', () async {
    container = buildContainer(initiallyConnected: false);
    container.read(syncCoordinatorProvider);
    await pump(2);

    statusController.add(true);
    await pump(3);

    expect(repository.callCount, 1);
  });

  test('online → online geçişinde tetiklenmiyor (uygulama zaten online açıldı)', () async {
    container = buildContainer(initiallyConnected: true);
    container.read(syncCoordinatorProvider);
    await pump(2);

    statusController.add(true);
    await pump(3);

    expect(repository.callCount, 0);
  });

  test('offline → offline geçişinde tetiklenmiyor', () async {
    container = buildContainer(initiallyConnected: false);
    container.read(syncCoordinatorProvider);
    await pump(2);

    statusController.add(false);
    await pump(3);

    expect(repository.callCount, 0);
  });

  test('sync sırasında tekrar online sinyali gelirse ikinci sync başlamıyor', () async {
    container = buildContainer(initiallyConnected: false);
    final coordinator = container.read(syncCoordinatorProvider);
    await pump(2);

    repository.gate = Completer<void>();
    statusController.add(true);
    await pump(3);

    expect(repository.callCount, 1, reason: 'ilk offline→online kenarı sync başlatmalı');
    expect(coordinator.isSyncing, isTrue);

    // İlk sync hâlâ `gate` üzerinde bekliyorken yeni bir offline→online
    // kenarı simüle edilir.
    statusController.add(false);
    await pump(2);
    statusController.add(true);
    await pump(3);

    expect(
      repository.callCount,
      1,
      reason: 'ilk sync sürerken gelen yeni kenar ikinci bir syncPending() çağrısı başlatmamalı',
    );

    repository.gate!.complete();
    await pump(3);

    expect(coordinator.isSyncing, isFalse);
  });

  test('sync hatası coordinator\'ı kalıcı olarak bozmuyor', () async {
    container = buildContainer(initiallyConnected: false);
    final coordinator = container.read(syncCoordinatorProvider);
    await pump(2);

    repository.throwOnCall = 1;
    statusController.add(true);
    await pump(3);

    expect(repository.callCount, 1);
    expect(coordinator.isSyncing, isFalse, reason: 'hata sonrası guard sıfırlanmalı');

    // Yeni bir offline→online kenarı — coordinator hâlâ çalışır durumda mı?
    statusController.add(false);
    await pump(2);
    statusController.add(true);
    await pump(3);

    expect(repository.callCount, 2, reason: 'önceki hata sonraki geçerli kenarı engellememeli');
  });

  test('provider dispose edildiğinde alttaki stream aboneliği otomatik iptal ediliyor', () async {
    container = buildContainer(initiallyConnected: false);
    container.read(syncCoordinatorProvider);
    await pump(2);

    expect(statusController.hasListener, isTrue);

    container.dispose();
    await pump(2);

    expect(statusController.hasListener, isFalse);
  });

  test('boş repository listesinde çökmeden tamamlanır', () async {
    service = _MockConnectivityService();
    statusController = StreamController<bool>.broadcast();
    when(() => service.isConnected).thenAnswer((_) async => false);
    when(() => service.onStatusChange).thenAnswer((_) => statusController.stream);
    container = ProviderContainer(
      overrides: [
        connectivityServiceProvider.overrideWithValue(service),
        // syncableRepositoriesProvider override EDİLMEDİ — varsayılan
        // (core/sync/sync_coordinator.dart'taki) boş liste kullanılır.
      ],
    );

    container.read(syncCoordinatorProvider);
    await pump(2);

    statusController.add(true);
    await pump(3);

    expect(container.read(syncUiStateProvider).status, SyncStatus.synced);
  });

  test('bir repository hata verse bile diğer repository AYNI turda senkronize edilir', () async {
    service = _MockConnectivityService();
    statusController = StreamController<bool>.broadcast();
    final failing = _RecordingRepository()..throwOnCall = 1;
    final healthy = _RecordingRepository();
    when(() => service.isConnected).thenAnswer((_) async => false);
    when(() => service.onStatusChange).thenAnswer((_) => statusController.stream);
    container = ProviderContainer(
      overrides: [
        connectivityServiceProvider.overrideWithValue(service),
        syncableRepositoriesProvider.overrideWithValue([failing, healthy]),
      ],
    );

    container.read(syncCoordinatorProvider);
    await pump(2);

    statusController.add(true);
    await pump(3);

    expect(failing.callCount, 1, reason: 'hatalı repository yine de çağrılmış olmalı');
    expect(healthy.callCount, 1, reason: 'ondan sonraki repository engellenmemeli');
    expect(container.read(syncUiStateProvider).status, SyncStatus.error);
  });

  group('syncIfOnline — app resume tetikleyicisi', () {
    test('daha önce hiç online gözlemlenmediyse hiçbir şey yapmaz', () async {
      container = buildContainer(initiallyConnected: false);
      final coordinator = container.read(syncCoordinatorProvider);
      await pump(2);

      await coordinator.syncIfOnline();

      expect(repository.callCount, 0);
    });

    test('bilinen son durum online ise resume\'da senkronizasyon dener', () async {
      container = buildContainer(initiallyConnected: false);
      final coordinator = container.read(syncCoordinatorProvider);
      await pump(2);

      statusController.add(true);
      await pump(3);
      expect(repository.callCount, 1, reason: 'offline→online kenarı zaten bir tur çalıştırdı');

      // Uygulama arka planda ONLINE kaldı, kullanıcı öne getirdi (resume) —
      // yeni bir connectivity event'i YOK, yalnızca resume tetikleyicisi.
      await coordinator.syncIfOnline();

      expect(repository.callCount, 2, reason: 'resume, bilinen online durumda ek bir tur denemeli');
    });

    test('offline iken resume hiçbir şey yapmaz', () async {
      container = buildContainer(initiallyConnected: false);
      final coordinator = container.read(syncCoordinatorProvider);
      await pump(2);

      await coordinator.syncIfOnline();

      expect(repository.callCount, 0);
    });
  });

  group('syncUiStateProvider — FAZ 14 UI durum modeli', () {
    test('offline\'a geçişte pending, tur sonunda hatasız ise synced olur', () async {
      container = buildContainer(initiallyConnected: true);
      container.read(syncCoordinatorProvider);
      await pump(2);
      expect(container.read(syncUiStateProvider).status, SyncStatus.synced);

      statusController.add(false);
      await pump(2);
      expect(container.read(syncUiStateProvider).status, SyncStatus.pending);

      statusController.add(true);
      await pump(3);
      expect(container.read(syncUiStateProvider).status, SyncStatus.synced);
    });

    test('tur sürerken syncing, hata sonrası error olur', () async {
      container = buildContainer(initiallyConnected: false);
      container.read(syncCoordinatorProvider);
      await pump(2);

      repository.gate = Completer<void>();
      statusController.add(true);
      await pump(2);
      expect(container.read(syncUiStateProvider).status, SyncStatus.syncing);

      repository.gate!.complete();
      await pump(3);
      expect(container.read(syncUiStateProvider).status, SyncStatus.synced);
    });
  });
}
