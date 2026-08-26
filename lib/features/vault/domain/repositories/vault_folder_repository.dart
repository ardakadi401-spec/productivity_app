import '../../../../core/errors/result.dart';
import '../entities/vault_folder.dart';

abstract class VaultFolderRepository {
  String newVaultFolderId();

  /// `parentFolderId == null` → yalnızca köke ait klasörler.
  Stream<List<VaultFolder>> watchVaultFolders({String? parentFolderId});
  Stream<VaultFolder?> watchVaultFolder(String folderId);
  Future<Result<VaultFolder>> createVaultFolder(VaultFolder folder);
  Future<Result<VaultFolder>> renameVaultFolder(String folderId, String name);

  /// Klasörü VE içindeki tüm alt klasörleri/kayıtları (rekürsif) siler —
  /// gerçek bir dosya sistemi klasörünün davranışıyla aynı; kullanıcı
  /// arayüzü silmeden önce bunu açıkça uyarır.
  Future<Result<void>> deleteVaultFolder(String folderId);
}
