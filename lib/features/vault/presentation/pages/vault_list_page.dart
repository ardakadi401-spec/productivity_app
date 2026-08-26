import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/vault_item.dart';
import '../providers/vault_providers.dart';

/// Şifre Kasası — kullanıcının kendi uygulama/proje şifrelerini ve özel
/// notlarını sakladığı, 23 resmi ekranın dışında sonradan eklenen kişisel
/// bölüm. Ayarlar sayfasından erişilir; ek bir kilit istemez, uygulamanın
/// genel PIN/Biyometri kilidi (varsa) yeterli kabul edilir.
class VaultListPage extends ConsumerWidget {
  const VaultListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(vaultListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Kasası')),
      floatingActionButton: AppFabButton(
        icon: Icons.add,
        semanticLabel: 'Yeni Kayıt',
        onPressed: () => context.push(RoutePaths.createVaultItem),
      ),
      body: itemsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: LoadingSkeleton(height: 64, borderRadius: 16),
            ),
          ),
        ),
        error: (error, _) {
          final message = error is Failure ? error.message : 'Kasa yüklenemedi.';
          return Center(
            child: ErrorState(message: message, onRetry: () => ref.invalidate(vaultListProvider)),
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.lock_outline,
              message: 'Kasan henüz boş',
              actionLabel: 'Kayıt Ekle',
              onAction: () => context.push(RoutePaths.createVaultItem),
            );
          }
          final sorted = [...items]..sort((a, b) => a.title.compareTo(b.title));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _VaultListItem(item: sorted[index]),
          );
        },
      ),
    );
  }
}

class _VaultListItem extends StatelessWidget {
  const _VaultListItem({required this.item});

  final VaultItem item;

  IconData get _categoryIcon => switch (item.category) {
        VaultItemCategory.app => Icons.smartphone_outlined,
        VaultItemCategory.project => Icons.folder_outlined,
        VaultItemCategory.other => Icons.key_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePaths.vaultItemDetail.replaceFirst(':itemId', item.itemId)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Icon(_categoryIcon, color: tokens.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    if (item.username != null && item.username!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.username!,
                        style: AppTypography.caption.copyWith(color: tokens.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
