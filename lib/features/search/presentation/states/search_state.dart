import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/search_result.dart';

/// Search Screen'in durumu (SCREENS.md §4.21) — sorgu metni, tür/tarih
/// filtreleri ve sayfalanmış sonuç listesi tek bir `Notifier` state'inde
/// (`AsyncValue` alanıyla) toplanır: filtre değişiklikleri senkron, arama
/// sonucu asenkrondur (`STATE_MANAGEMENT.md §2 satır 11 "AsyncNotifierProvider"`
/// ruhu — burada tek bir `Notifier` içine gömülü `AsyncValue` ile aynı etki
/// daha basit şekilde elde edilir, ayrı bir ikinci provider gerekmez).
class SearchState {
  const SearchState({
    this.query = '',
    this.typeFilter,
    this.todayOnly = false,
    this.visibleCount = _pageSize,
    this.resultsAsync = const AsyncValue.data(<SearchResult>[]),
  });

  static const _pageSize = 20;

  final String query;
  final SearchResultType? typeFilter;
  final bool todayOnly;
  final int visibleCount;
  final AsyncValue<List<SearchResult>> resultsAsync;

  /// DATABASE.md §15.3 "liste ekranlarında 20" — Search sonuçları zaten
  /// tamamı yerel Isar'dan gelen bellek içi bir liste olduğundan (Firestore
  /// cursor-based pagination'a gerek yok, ARCHITECTURE §12.4'ün ruhu burada
  /// "görünür sayıyı kademeli artırma" ile uygulanır) yalnızca ilk
  /// [visibleCount] kadarı gösterilir.
  List<SearchResult> get visibleResults {
    final all = resultsAsync.valueOrNull ?? const [];
    return all.take(visibleCount).toList();
  }

  bool get hasMore => (resultsAsync.valueOrNull?.length ?? 0) > visibleCount;

  SearchState copyWith({
    String? query,
    SearchResultType? typeFilter,
    bool clearTypeFilter = false,
    bool? todayOnly,
    int? visibleCount,
    AsyncValue<List<SearchResult>>? resultsAsync,
  }) {
    return SearchState(
      query: query ?? this.query,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      todayOnly: todayOnly ?? this.todayOnly,
      visibleCount: visibleCount ?? this.visibleCount,
      resultsAsync: resultsAsync ?? this.resultsAsync,
    );
  }
}
