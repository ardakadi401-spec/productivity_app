import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/sync_coordinator.dart';
import '../../core/sync/sync_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// FAZ 14 — senkronizasyon durumu göstergesi (`PRD.md` §6.17 "senkronize /
/// bekleniyor / hata", `SCREENS.md` §6.6 görünürlük noktaları: 4.22
/// Settings, 4.6 Dashboard). 2+ feature kullanımı nedeniyle
/// `shared/components/`'te (FOLDER_STRUCTURE.md §6.3).
///
/// Salt okunur: `syncUiStateProvider`'ı izler. "Tekrar Dene" yalnızca
/// `SyncCoordinator.retry` üzerinden çalışır — hiçbir repository'nin
/// private senkronizasyon metoduna doğrudan erişmez.
class SyncStatusIndicatorWidget extends ConsumerWidget {
  const SyncStatusIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final state = ref.watch(syncUiStateProvider);

    final (IconData icon, String label, Color color) = switch (state.status) {
      SyncStatus.synced => (Icons.cloud_done_outlined, 'Senkronize', tokens.textSecondary),
      SyncStatus.syncing => (Icons.sync, 'Senkronize ediliyor', theme.colorScheme.primary),
      SyncStatus.pending => (
          Icons.cloud_off_outlined,
          'Bekleyen değişiklikler',
          tokens.textSecondary,
        ),
      SyncStatus.error => (Icons.error_outline, 'Senkronizasyon hatası', theme.colorScheme.error),
    };

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (state.status == SyncStatus.error)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => ref.read(syncCoordinatorProvider).retry(),
            child: const Text('Tekrar Dene'),
          ),
      ],
    );
  }
}
