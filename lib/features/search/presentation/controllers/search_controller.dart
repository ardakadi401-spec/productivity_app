import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/search_result.dart';
import '../providers/search_providers.dart';
import '../states/search_state.dart';
import 'recent_searches_controller.dart';

/// Search Screen'in denetleyicisi (SCREENS.md §4.21) — sorgu değiştikçe
/// debounce ile `SearchUseCase`'i tetikler (STATE_MANAGEMENT.md §10.3).
class SearchController extends AutoDisposeNotifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void setQuery(String value) {
    state = state.copyWith(query: value, visibleCount: 20);
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      state = state.copyWith(resultsAsync: const AsyncValue.data(<SearchResult>[]));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), _runSearch);
  }

  void setTypeFilter(SearchResultType? type) {
    state = state.copyWith(typeFilter: type, clearTypeFilter: type == null, visibleCount: 20);
    if (state.query.trim().isNotEmpty) unawaited(_runSearch());
  }

  void setTodayOnly(bool value) {
    state = state.copyWith(todayOnly: value, visibleCount: 20);
    if (state.query.trim().isNotEmpty) unawaited(_runSearch());
  }

  void loadMore() {
    state = state.copyWith(visibleCount: state.visibleCount + 20);
  }

  Future<void> _runSearch() async {
    final query = state.query;
    state = state.copyWith(resultsAsync: const AsyncValue.loading());
    try {
      final results = await ref.read(searchUseCaseProvider).call(
            query: query,
            type: state.typeFilter,
            todayOnly: state.todayOnly,
          );
      // Debounce sırasında sorgu değiştiyse (kullanıcı yazmaya devam etti),
      // bu artık geçersiz sonucu uygulamaz — en son tetiklenen arama kazanır.
      if (state.query != query) return;
      state = state.copyWith(resultsAsync: AsyncValue.data(results));
      ref.read(recentSearchesControllerProvider.notifier).addQuery(query);
    } catch (e, stackTrace) {
      if (state.query != query) return;
      state = state.copyWith(resultsAsync: AsyncValue.error(e, stackTrace));
    }
  }
}

final searchControllerProvider =
    NotifierProvider.autoDispose<SearchController, SearchState>(SearchController.new);
