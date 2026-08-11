import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Bağlantı durumu servisi — ARCHITECTURE.md Bölüm 8.3 senkronizasyon
/// tetikleyicilerinden birinin Core seviyesindeki temel altyapısı.
///
/// Bu fazda yalnızca bağlantı durumunu yayınlar; senkronizasyon mantığına
/// bağlama FAZ 14'ün kapsamındadır (bkz. ROADMAP.md FAZ 2 notu).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Bağlantı durumu değişikliklerini yayınlayan stream. `false` = tüm
  /// bağlantı türleri kesik (uçak modu dahil); `true` = en az bir arayüz
  /// (wifi/mobil/ethernet vb.) aktif.
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((results) => _hasConnection(results));

  Future<bool> get isConnected async =>
      _hasConnection(await _connectivity.checkConnectivity());

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
