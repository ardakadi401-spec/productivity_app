import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

/// FOLDER_STRUCTURE.md Bölüm 2 — "Isar kutu/koleksiyon erişim
/// sarmalayıcılarının organizasyonu (yalnızca altyapı, feature'a özel şema
/// değil)". Tüm feature'ların local datasource'ları bu tek paylaşılan
/// örnek üzerinden çalışır.
///
/// `Isar.open(...)` asenkron olduğundan, gerçek örnek `main()`'de açılır ve
/// bu provider `ProviderScope(overrides: [isarProvider.overrideWithValue(isar)])`
/// ile doldurulur — burada tanımsız bir varsayılan (`UnimplementedError`)
/// bırakılır, böylece yanlışlıkla override edilmeden kullanılırsa hemen
/// fark edilir.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider main.dart\'ta IsarService.open() sonucu ile override edilmeli.',
  );
});
