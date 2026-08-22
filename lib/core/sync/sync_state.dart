import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FAZ 14 — kullanıcıya görünür senkronizasyon durumu (`ARCHITECTURE.md`
/// §8.5, `PRD.md` §6.17 "senkronize / bekleniyor / hata"). Bu, feature-local
/// Isar `syncStatus` enum'larından (her modelin kendi `pendingCreate/
/// pendingUpdate/pendingDelete/synced/error` seti) BİLEREK AYRIDIR: buradaki
/// dört durum, `SyncCoordinator`'ın (`core/sync/sync_coordinator.dart`)
/// gözlemlediği UYGULAMA GENELİ özet durumdur, herhangi bir kaydın kendi
/// alanı değil.
enum SyncStatus {
  /// Bilinen bir sorun yok; en son senkronizasyon turu hatasız tamamlandı
  /// (veya henüz hiç tetiklenmedi — iyimser varsayılan).
  synced,

  /// Bağlantı şu an yok — yapılan değişiklikler yerelde `pending` olarak
  /// birikiyor, bağlantı gelince otomatik gönderilecek.
  pending,

  /// `SyncCoordinator._runSync` şu anda aktif çalışıyor.
  syncing,

  /// En son senkronizasyon turunda en az bir repository hata verdi.
  error,
}

class SyncUiState {
  const SyncUiState({required this.status, this.lastError, this.lastSyncedAt});

  static const initial = SyncUiState(status: SyncStatus.synced);

  final SyncStatus status;
  final String? lastError;
  final DateTime? lastSyncedAt;

  SyncUiState copyWith({SyncStatus? status, String? lastError, DateTime? lastSyncedAt}) {
    return SyncUiState(
      status: status ?? this.status,
      lastError: lastError,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

/// UI/Presentation katmanının izlediği tek kaynak — yalnızca `SyncCoordinator`
/// yazar (`ref.read(syncUiStateProvider.notifier).state = ...`); hiçbir
/// widget veya repository doğrudan bu state'i değiştirmez.
final syncUiStateProvider = StateProvider<SyncUiState>((ref) => SyncUiState.initial);
