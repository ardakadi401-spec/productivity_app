import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Son aramalar geçmişi (SCREENS.md §4.21) — kullanıcı kararı gereği
/// **cihaza özel, senkronize edilmeyen, basit bir bellek içi liste**dir:
/// Firestore/Isar'a yeni bir kullanıcı-verisi koleksiyonu eklenmedi (Search'ün
/// zaten kendi repository'si yok, STATE_MANAGEMENT.md §2 satır 11). Bu
/// listenin bir bedeli var: uygulama yeniden başlatıldığında sıfırlanır —
/// bu, "kalıcı olmayan basit yerel liste" kararının doğal bir sonucu.
class RecentSearchesController extends Notifier<List<String>> {
  static const _maxEntries = 10;

  @override
  List<String> build() => const [];

  void addQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final withoutDuplicate = state.where((q) => q.toLowerCase() != trimmed.toLowerCase()).toList();
    state = [trimmed, ...withoutDuplicate].take(_maxEntries).toList();
  }

  void removeQuery(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clear() => state = const [];
}

final recentSearchesControllerProvider =
    NotifierProvider<RecentSearchesController, List<String>>(RecentSearchesController.new);
