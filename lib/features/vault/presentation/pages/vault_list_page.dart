import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/vault_folder.dart';
import '../../domain/entities/vault_item.dart';
import '../providers/vault_providers.dart';

/// Şifre Kasası — kullanıcının kendi uygulama/proje şifrelerini ve özel
/// notlarını sakladığı, 23 resmi ekranın dışında sonradan eklenen kişisel
/// bölüm. Ayarlar sayfasından erişilir; ek bir kilit istemez, uygulamanın
/// genel PIN/Biyometri kilidi (varsa) yeterli kabul edilir.
///
/// `folderId == null` → kasanın kök seviyesi. Kullanıcı isteğiyle
/// (ör. "ELS İNŞAAT > Şifreler > Yönetim Paneli Şifresi") sınırsız
/// derinlikte iç içe klasörleme desteklenir — bu sayfa hem o an içinde
/// bulunulan klasördeki alt klasörleri HEM kayıtları listeler (gerçek bir
/// dosya yöneticisi gezinme deneyimi).
class VaultListPage extends ConsumerWidget {
  const VaultListPage({super.key, required this.folderId});

  final String? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(vaultFolderListProvider(folderId));
    final itemsAsync = ref.watch(vaultListProvider(folderId));
    final currentFolderAsync =
        folderId == null ? null : ref.watch(vaultFolderDetailProvider(folderId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(currentFolderAsync?.valueOrNull?.name ?? 'Şifre Kasası'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Yeni Klasör',
            onPressed: () => _createFolder(context, ref),
          ),
        ],
      ),
      floatingActionButton: AppFabButton(
        icon: Icons.add,
        semanticLabel: 'Yeni Kayıt',
        onPressed: () => context.push(RoutePaths.createVaultItem, extra: folderId),
      ),
      body: foldersAsync.when(
        loading: () => const _LoadingBody(),
        error: (error, _) => Center(
          child: ErrorState(
            message: error is Failure ? error.message : 'Kasa yüklenemedi.',
            onRetry: () => ref.invalidate(vaultFolderListProvider(folderId)),
          ),
        ),
        data: (folders) => itemsAsync.when(
          loading: () => const _LoadingBody(),
          error: (error, _) => Center(
            child: ErrorState(
              message: error is Failure ? error.message : 'Kasa yüklenemedi.',
              onRetry: () => ref.invalidate(vaultListProvider(folderId)),
            ),
          ),
          data: (items) {
            if (folders.isEmpty && items.isEmpty) {
              return EmptyState(
                icon: Icons.lock_outline,
                message: folderId == null ? 'Kasan henüz boş' : 'Bu klasör henüz boş',
                actionLabel: 'Kayıt Ekle',
                onAction: () => context.push(RoutePaths.createVaultItem, extra: folderId),
              );
            }
            final sortedFolders = [...folders]..sort((a, b) => a.name.compareTo(b.name));
            final sortedItems = [...items]..sort((a, b) => a.title.compareTo(b.title));
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: sortedFolders.length + sortedItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index < sortedFolders.length) {
                  return _VaultFolderListItem(folder: sortedFolders[index]);
                }
                return _VaultListItem(item: sortedItems[index - sortedFolders.length]);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final name = await _FolderNameDialog.show(context, title: 'Yeni Klasör');
    if (name == null || !context.mounted) return;

    final repository = ref.read(vaultFolderRepositoryProvider);
    final now = DateTime.now();
    final folder = VaultFolder(
      folderId: repository.newVaultFolderId(),
      name: name,
      parentFolderId: folderId,
      createdAt: now,
      updatedAt: now,
    );
    final result = await ref.read(createVaultFolderUseCaseProvider).call(folder);
    if (!context.mounted) return;
    if (result case Err(:final failure)) {
      AppSnackbar.show(context, message: failure.message);
    }
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: List.generate(
        4,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: LoadingSkeleton(height: 64, borderRadius: 16),
        ),
      ),
    );
  }
}

class _VaultFolderListItem extends ConsumerWidget {
  const _VaultFolderListItem({required this.folder});

  final VaultFolder folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePaths.vaultFolder.replaceFirst(':folderId', folder.folderId)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  folder.name,
                  style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.onSurface),
                ),
              ),
              PopupMenuButton<_FolderAction>(
                icon: Icon(Icons.more_vert, color: tokens.textSecondary),
                onSelected: (action) => switch (action) {
                  _FolderAction.rename => _rename(context, ref),
                  _FolderAction.delete => _delete(context, ref),
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: _FolderAction.rename, child: Text('Yeniden Adlandır')),
                  PopupMenuItem(value: _FolderAction.delete, child: Text('Sil')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await _FolderNameDialog.show(
      context,
      title: 'Klasörü Yeniden Adlandır',
      initialValue: folder.name,
    );
    if (name == null || !context.mounted) return;

    final result = await ref.read(renameVaultFolderUseCaseProvider).call(folder.folderId, name);
    if (!context.mounted) return;
    if (result case Err(:final failure)) {
      AppSnackbar.show(context, message: failure.message);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Klasörü Sil',
      description:
          '"${folder.name}" klasörünü silmek istediğine emin misin? İçindeki tüm alt klasörler ve '
          'kayıtlar da silinecek. Bu işlem geri alınamaz.',
      confirmLabel: 'Sil',
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref.read(deleteVaultFolderUseCaseProvider).call(folder.folderId);
    if (!context.mounted) return;
    if (result case Err(:final failure)) {
      AppSnackbar.show(context, message: failure.message);
    }
  }
}

enum _FolderAction { rename, delete }

/// Klasör oluşturma VE yeniden adlandırma için ortak isim girme dialogu.
class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog({required this.title, this.initialValue});

  final String title;
  final String? initialValue;

  static Future<String?> show(BuildContext context, {required String title, String? initialValue}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _FolderNameDialog(title: title, initialValue: initialValue),
    );
  }

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final _controller = TextEditingController(text: widget.initialValue ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Klasör adı boş olamaz.');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: AppSpacing.md),
              AppTextField(label: 'Klasör Adı', controller: _controller, errorText: _error),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Vazgeç',
                    variant: AppButtonVariant.text,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(label: 'Kaydet', onPressed: _submit),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultListItem extends StatelessWidget {
  const _VaultListItem({required this.item});

  final VaultItem item;

  IconData get _categoryIcon => switch (item.category) {
        VaultItemCategory.app => Icons.smartphone_outlined,
        VaultItemCategory.project => Icons.business_outlined,
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
