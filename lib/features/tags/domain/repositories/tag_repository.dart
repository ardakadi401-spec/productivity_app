import '../../../../core/errors/result.dart';
import '../entities/tag.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
///
/// Bilinçli olarak minimal: yalnızca Notes'un "tag oluşturma/seçme/
/// filtreleme" ihtiyacını karşılar (kullanıcı talimatı) — güncelleme/silme
/// akışı bu fazın kapsamında değildir.
abstract interface class TagRepository {
  /// Ağ çağrısı yapmadan yeni bir etiket ID'si tahsis eder (Firestore
  /// client-side doküman ID — offline de çalışır).
  String newTagId();

  Stream<List<Tag>> watchTags();

  Future<Result<Tag>> createTag(Tag tag);
}
