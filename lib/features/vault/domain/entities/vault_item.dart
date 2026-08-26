enum VaultItemCategory { app, project, other }

/// Kullanıcının kendi uygulama/proje şifrelerini ve özel notlarını sakladığı
/// kişisel kasa kaydı — DATABASE.md'nin özgün şemasında yer almayan, kullanıcı
/// isteğiyle sonradan eklenen yeni bir koleksiyon.
///
/// `password`/`notes` alanları Data katmanında (bkz. `VaultEncryptionService`)
/// şifrelenmiş olarak saklanır; Domain'e HER ZAMAN çözülmüş düz metin olarak
/// gelir/gider — Domain, şifreleme detayından bağımsız kalır.
///
/// `folderId == null` → köke (kasanın en üst seviyesine) ait kayıt; aksi
/// halde kaydın içinde yaşadığı [VaultFolder]. Kullanıcının isteğiyle
/// (ör. "ELS İNŞAAT > Şifreler > Yönetim Paneli Şifresi") gelen, sınırsız
/// derinlikte iç içe klasörleme desteği (bkz. `VaultFolder.parentFolderId`).
class VaultItem {
  const VaultItem({
    required this.itemId,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.username,
    this.password,
    this.url,
    this.notes,
  });

  final String itemId;
  final String title;
  final VaultItemCategory category;
  final String? folderId;
  final String? username;
  final String? password;
  final String? url;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultItem copyWith({
    String? title,
    VaultItemCategory? category,
    String? folderId,
    bool clearFolderId = false,
    String? username,
    bool clearUsername = false,
    String? password,
    bool clearPassword = false,
    String? url,
    bool clearUrl = false,
    String? notes,
    bool clearNotes = false,
    DateTime? updatedAt,
  }) {
    return VaultItem(
      itemId: itemId,
      title: title ?? this.title,
      category: category ?? this.category,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      username: clearUsername ? null : (username ?? this.username),
      password: clearPassword ? null : (password ?? this.password),
      url: clearUrl ? null : (url ?? this.url),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
