/// FAZ 14 — merkezi senkronizasyon tetikleyicisinin (`SyncCoordinator`) bir
/// repository'yi "bekleyen kayıtları göndermeye zorlayabilmesi" için uyması
/// gereken minimal sözleşme. Domain repository arayüzleri (`TaskRepository`
/// vb.) DEĞİŞTİRİLMEZ — yalnızca Data katmanındaki `*RepositoryImpl`
/// sınıflarının bu arayüzü de implemente etmesi yeterlidir.
abstract interface class SyncableRepository {
  /// Yerelde `pending*` durumda kalan kayıtları Firestore'a göndermeyi
  /// dener. Bağlantı yoksa veya gönderim başarısız olursa sessizce döner
  /// (mevcut `_trySyncX` deseniyle birebir tutarlı — hata çağırana
  /// fırlatılmaz, kayıt `pending` kalmaya devam eder).
  Future<void> syncPending();
}
