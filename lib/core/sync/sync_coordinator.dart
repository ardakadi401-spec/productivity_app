import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_service.dart';
import '../utils/app_logger.dart';
import 'sync_state.dart';
import 'syncable_repository.dart';

/// FAZ 14 — merkezi senkronizasyon tetikleyicisinin tetikleyeceği
/// `SyncableRepository` listesi. Bu dosyada BİLEREK boş bırakılmıştır
/// (`core/` hiçbir feature klasörünü import edemez — ARCHITECTURE.md §10.2
/// Kural 3); gerçek liste `app/sync_bootstrap.dart`'ta, uygulamanın
/// kompozisyon kökünde (`main.dart`) bir `Provider` override'ı olarak
/// kurulur. `SyncCoordinator`'ın kendisi bu listenin nereden geldiğinden
/// habersizdir, yalnızca `ref.read` ile okur.
final syncableRepositoriesProvider = Provider<List<SyncableRepository>>((ref) {
  return const [];
});

/// `STATE_MANAGEMENT.md` §7.3 — bağlantı offline'dan online'a geçtiğinde,
/// `pending` kaydı olan repository'lere tek bir merkezi noktadan
/// senkronizasyon tetikleyicisi ileten koordinatör.
///
/// Tasarım kararları:
/// - Kendi `Ref`'ini (yalnızca `syncCoordinatorProvider`'ın `create`
///   gövdesinden, kurucuda) saklar — bu, `SyncCoordinator`'ın public
///   metotlarının (`retry`, `syncIfOnline`) dışarıdan bir `ref` PARAMETRESİ
///   ALMAMASINI sağlar. Bilinçli bir düzeltme: Riverpod 2.x'te `Ref`
///   (provider içi) ile `WidgetRef` (widget içi, `app.dart`daki
///   `ConsumerState`'in sağladığı) BİRBİRİNE DÖNÜŞTÜRÜLEMEZ, ayrı
///   hiyerarşiler — dışarıdan `ref` parametresi istenen ilk tasarım,
///   `app.dart`'ın `WidgetRef`'i geçirememesi nedeniyle derlenmezdi.
/// - Yalnızca `false → true` KENARINDA (edge) tetiklenir. İlk gelen değer
///   (uygulama zaten online açıldığında dahil) hiçbir zaman tetiklemez,
///   çünkü `_wasOnline` başlangıçta `null`dır ve yalnızca `wasOnline ==
///   false` (açıkça false, null değil) koşulu tetikleyiciyi açar.
/// - `_isSyncing` bayrağı ile aynı anda yalnızca bir senkronizasyon turu
///   çalışır; tur sürerken gelen yeni offline→online sinyalleri yok sayılır.
/// - Bir repository'nin `syncPending()`'i hata fırlatırsa yakalanır,
///   coordinator kalıcı olarak bozulmaz (`finally` ile `_isSyncing` her
///   koşulda sıfırlanır) — bir sonraki geçerli kenarda tekrar dener; DİĞER
///   repository'lerin senkronizasyonu da (aynı turda) durmaz, döngü devam
///   eder.
/// - `syncUiStateProvider` (bkz. `sync_state.dart`) her aşamada güncellenir:
///   offline'a geçişte `pending`, tur başlarken `syncing`, tur bitince
///   hataya göre `synced`/`error`. Bu, feature-local Isar `syncStatus`
///   enum'larından ayrı, yalnızca UI'ın izlediği özet bir durumdur.
class SyncCoordinator {
  SyncCoordinator(this._ref);

  final Ref _ref;

  bool? _wasOnline;
  bool _isSyncing = false;

  /// Yalnızca test görünürlüğü için — coordinator'ın bir senkronizasyon
  /// turunu şu an çalıştırıp çalıştırmadığını dışarı açar.
  bool get isSyncing => _isSyncing;

  void _onConnectivityChanged(AsyncValue<bool>? previous, AsyncValue<bool> next) {
    final isOnline = next.valueOrNull;
    if (isOnline == null) return; // loading/error tick — durum bilgisi yok, yok say.

    if (!isOnline) {
      _ref.read(syncUiStateProvider.notifier).update(
            (s) => s.copyWith(status: SyncStatus.pending),
          );
    }

    final wasOnline = _wasOnline;
    _wasOnline = isOnline;

    if (wasOnline == false && isOnline == true) {
      unawaited(_runSync());
    }
  }

  /// FAZ 14 — app lifecycle (foreground'a dönüş) tetikleyicisi. Bağlantı
  /// zaten offline→online kenarında OTOMATİK tetiklenir (bkz. yukarı); bu
  /// metot yalnızca EK bir tetikleyici kaynağıdır — "uygulama arka planda
  /// online kaldı, kullanıcı şimdi öne getirdi" senaryosunda bekleyen
  /// kayıtların gereksiz yere sonsuza kadar beklememesi için. Bilinen son
  /// bağlantı durumu online DEĞİLSE (henüz hiç gözlemlenmediyse veya
  /// offline'sa) hiçbir şey yapmaz — her resume'da kayıtsız şartsız bir
  /// senkronizasyon turu ZORLAMAZ, yalnızca zaten online olunduğu bilinen
  /// durumda `_isSyncing` guard'ı üzerinden ucuz bir tur dener (pending
  /// yoksa yalnızca yerel sorgular çalışır, ağ isteği atılmaz).
  Future<void> syncIfOnline() async {
    if (_wasOnline == true) {
      await _runSync();
    }
  }

  /// FAZ 14 — Settings/Dashboard'daki "Tekrar Dene" eyleminin tek girişi.
  /// UI hiçbir repository'nin private metoduna dokunmaz, yalnızca bunu
  /// çağırır. `_runSync`'in kendi guard'ı sayesinde zaten bir tur
  /// çalışıyorsa ikinci bir tur başlamaz.
  Future<void> retry() => _runSync();

  Future<void> _runSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _ref.read(syncUiStateProvider.notifier).update(
          (s) => s.copyWith(status: SyncStatus.syncing),
        );

    var hadError = false;
    try {
      final repositories = _ref.read(syncableRepositoriesProvider);
      for (final repository in repositories) {
        try {
          await repository.syncPending();
        } catch (e) {
          // Tek bir repository'nin hatası diğerlerinin senkronize olmasını
          // engellemez; kayıt `pending` kalmaya devam eder (döngü devam
          // eder, `continue` gerekmez — sıradaki repository'ye geçilir).
          hadError = true;
          AppLogger.warning(
            'Senkronizasyon başarısız: ${repository.runtimeType}',
            name: 'sync',
            // NOT: kullanıcı verisi loglanmaz — yalnızca tip adı ve hata
            // mesajı (mesajın kendisi de PII taşımaz, teknik/ağ hatasıdır).
          );
        }
      }
    } finally {
      _isSyncing = false;
      if (hadError) {
        _ref.read(syncUiStateProvider.notifier).update(
              (s) => s.copyWith(status: SyncStatus.error),
            );
        AppLogger.warning('Senkronizasyon turu hatalarla tamamlandı', name: 'sync');
      } else {
        _ref.read(syncUiStateProvider.notifier).state = SyncUiState(
          status: SyncStatus.synced,
          lastSyncedAt: DateTime.now(),
        );
        AppLogger.info('Senkronizasyon turu tamamlandı', name: 'sync');
      }
    }
  }
}

/// Uygulama ömrü boyunca tek bir `SyncCoordinator` örneği. `ref.listen`
/// burada (provider'ın kendi `create` gövdesinde) çağrılır — ham bir
/// `StreamSubscription` DEĞİL — böylece bu provider dispose edildiğinde
/// Riverpod dinleyiciyi otomatik iptal eder (bkz. `app_router.dart`taki
/// `authStateProvider` dinleme deseniyle birebir aynı, kanıtlanmış yaklaşım).
///
/// FAZ 14 sonu itibarıyla `main.dart` bu provider'ı erkenden okuyarak
/// (`container.read(syncCoordinatorProvider)`) aktive eder — bkz.
/// `app/sync_bootstrap.dart`.
final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final coordinator = SyncCoordinator(ref);
  ref.listen<AsyncValue<bool>>(
    connectivityStatusProvider,
    (previous, next) => coordinator._onConnectivityChanged(previous, next),
  );
  return coordinator;
});
