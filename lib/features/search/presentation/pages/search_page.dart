import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/search_result.dart';
import '../controllers/recent_searches_controller.dart';
import '../controllers/search_controller.dart';
import '../states/search_state.dart';

/// Search Screen — SCREENS.md §4.21.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);
    final recentSearches = ref.watch(recentSearchesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ara')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Ara',
                controller: _queryController,
                hintText: 'Görev, proje, not, alışkanlık ara',
                onChanged: controller.setQuery,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Yalnızca `typeFilter`/`todayOnly` izlenir (`.select`) —
              // ARCHITECTURE.md §12.1: her tuş vuruşunda değişen `query`,
              // bu filtre çubuğunu gereksiz yere yeniden inşa etmez.
              Consumer(
                builder: (context, ref, _) {
                  final (typeFilter, todayOnly) = ref.watch(
                    searchControllerProvider.select((s) => (s.typeFilter, s.todayOnly)),
                  );
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AppChip(
                          label: 'Tümü',
                          selected: typeFilter == null,
                          onTap: () => controller.setTypeFilter(null),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppChip(
                          label: 'Görev',
                          selected: typeFilter == SearchResultType.task,
                          onTap: () => controller.setTypeFilter(SearchResultType.task),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppChip(
                          label: 'Proje',
                          selected: typeFilter == SearchResultType.project,
                          onTap: () => controller.setTypeFilter(SearchResultType.project),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppChip(
                          label: 'Not',
                          selected: typeFilter == SearchResultType.note,
                          onTap: () => controller.setTypeFilter(SearchResultType.note),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppChip(
                          label: 'Alışkanlık',
                          selected: typeFilter == SearchResultType.habit,
                          onTap: () => controller.setTypeFilter(SearchResultType.habit),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppChip(
                          label: 'Bugün',
                          selected: todayOnly,
                          onTap: () => controller.setTodayOnly(!todayOnly),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.resultsAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(),
                  ),
                ),
              Expanded(
                child: state.query.trim().isEmpty
                    ? _RecentSearchesBody(
                        recentSearches: recentSearches,
                        onTapQuery: (q) {
                          _queryController.text = q;
                          controller.setQuery(q);
                        },
                        onClear: () => ref.read(recentSearchesControllerProvider.notifier).clear(),
                      )
                    : state.resultsAsync.when(
                        loading: () => state.resultsAsync.hasValue
                            ? _ResultsList(state: state, onLoadMore: controller.loadMore)
                            : const SizedBox.shrink(),
                        error: (error, _) {
                          final message = error is Failure ? error.message : 'Arama başarısız oldu.';
                          return Center(
                            child: ErrorState(message: message, onRetry: () => controller.setQuery(state.query)),
                          );
                        },
                        data: (_) {
                          if (state.visibleResults.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: AppSpacing.xxl),
                              child: EmptyState(icon: Icons.search_off, message: 'Sonuç bulunamadı'),
                            );
                          }
                          return _ResultsList(state: state, onLoadMore: controller.loadMore);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesBody extends StatelessWidget {
  const _RecentSearchesBody({required this.recentSearches, required this.onTapQuery, required this.onClear});

  final List<String> recentSearches;
  final ValueChanged<String> onTapQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    if (recentSearches.isEmpty) {
      return const EmptyState(icon: Icons.search, message: 'Aramaya başlamak için yaz');
    }
    return ListView(
      children: [
        Row(
          children: [
            Text(
              'Son Aramalar',
              style: AppTypography.overline.copyWith(color: tokens.textSecondary),
            ),
            const Spacer(),
            TextButton(onPressed: onClear, child: const Text('Temizle')),
          ],
        ),
        for (final query in recentSearches)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(query),
            onTap: () => onTapQuery(query),
          ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.state, required this.onLoadMore});

  final SearchState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final results = state.visibleResults;
    final hasMore = state.hasMore;
    return ListView.separated(
      itemCount: results.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        if (index >= results.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(
              child: TextButton(onPressed: onLoadMore, child: const Text('Daha Fazla Göster')),
            ),
          );
        }
        final result = results[index];
        return _SearchResultTile(key: ValueKey('${result.type}:${result.id}'), result: result);
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({super.key, required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final (icon, route) = switch (result.type) {
      SearchResultType.task => (
          Icons.checklist_outlined,
          RoutePaths.taskDetail.replaceFirst(':taskId', result.id),
        ),
      SearchResultType.project => (
          Icons.folder_outlined,
          RoutePaths.projectDetail.replaceFirst(':projectId', result.id),
        ),
      SearchResultType.note => (
          Icons.sticky_note_2_outlined,
          RoutePaths.noteDetail.replaceFirst(':noteId', result.id),
        ),
      SearchResultType.habit => (
          Icons.repeat_rounded,
          RoutePaths.habitDetail.replaceFirst(':habitId', result.id),
        ),
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      // `ListTile` kendi ink efektlerini en yakın `Material` üzerinde
      // boyar — dekore edilmiş `Container` araya girdiğinde bunlar görünmez
      // kalır, bu yüzden şeffaf bir `Material` ile sarmalanır.
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: tokens.textSecondary),
          title: Text(result.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: result.subtitle == null || result.subtitle!.isEmpty
              ? null
              : Text(result.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => context.push(route),
        ),
      ),
    );
  }
}
