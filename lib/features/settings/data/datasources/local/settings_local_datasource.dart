import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/settings_local_model.dart';

/// Isar üzerinden Settings okuma/yazma — ARCHITECTURE.md §6.4 offline-first
/// akışının "önce yerele yaz/oku" katmanı. Tekil satır (`id: 0`) olduğundan
/// diğer feature'ların aksine filtre/sorgu yerine doğrudan nesne bazlı
/// `watchObject`/`get` kullanılır.
class SettingsLocalDatasource {
  SettingsLocalDatasource(this._isar);

  final Isar _isar;

  Stream<SettingsLocalModel?> watch() {
    try {
      return _isar.settingsLocalModels.watchObject(0, fireImmediately: true);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<SettingsLocalModel?> get() async {
    try {
      return await _isar.settingsLocalModels.get(0);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> put(SettingsLocalModel model) async {
    try {
      model.id = 0;
      await _isar.writeTxn(() => _isar.settingsLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
