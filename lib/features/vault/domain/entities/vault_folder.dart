/// Şifre Kasası'nda kullanıcının isteğiyle eklenen, sınırsız derinlikte iç içe
/// klasörleme desteği (ör. "ELS İNŞAAT > Şifreler", "ELS İNŞAAT > Önemli Not >
/// Alt Klasör"). `parentFolderId == null` → kök seviyesinde bir klasör;
/// aksi halde başka bir [VaultFolder]'ın içinde yaşar.
class VaultFolder {
  const VaultFolder({
    required this.folderId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.parentFolderId,
  });

  final String folderId;
  final String name;
  final String? parentFolderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultFolder copyWith({String? name, DateTime? updatedAt}) {
    return VaultFolder(
      folderId: folderId,
      name: name ?? this.name,
      parentFolderId: parentFolderId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
