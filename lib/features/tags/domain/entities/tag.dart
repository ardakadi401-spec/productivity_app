/// DATABASE.md §1.5 — "Categories ve Tags... ortak sözlük (lookup)
/// koleksiyonları". Notes'un etiketleme ihtiyacı için gereken minimum
/// alan seti; diğer belgeler (örn. Task.tagIds) yalnızca ID referansı
/// tutar, isim/renk burada tek bir yerde yaşar (veri tekrarını önler).
class Tag {
  const Tag({
    required this.tagId,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  final String tagId;
  final String name;

  /// Hex kod — UI_GUIDELINES.md §3.3 pastel setinden seçilir.
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
}
