import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../dialogs/app_bottom_sheet.dart';

/// Note Card — COMPONENTS.md §4.7. Notes Screen VE Project/Task Detail'in
/// "bağlı notlar" bölümü tarafından kullanıldığından `shared/components/`'te
/// (FOLDER_STRUCTURE.md §6.3); `TaskCardWidget`/`GoalCardWidget` ile aynı
/// ilke — yalnızca primitive parametrelere bağımlıdır, `Note` domain
/// entity'sini almaz.
class NoteCardWidget extends StatelessWidget {
  const NoteCardWidget({
    super.key,
    required this.title,
    this.contentPreview,
    this.color,
    this.linkedLabel,
    this.isPinned = false,
    this.onTap,
    this.onTogglePinned,
    this.onDelete,
  });

  final String title;

  /// Önceden biçimlendirme işaretçilerinden arındırılmış, en fazla 2 satırlık
  /// önizleme metni (bkz. Notes'un kendi `notePreviewText()` yardımcı
  /// fonksiyonu).
  final String? contentPreview;

  /// Hex kod (opsiyonel) — sol kenar renk şeridi.
  final Color? color;

  /// Önceden çözümlenmiş bağlı proje/görev etiketi (örn. "Proje: Kişisel
  /// Site"); `null` ise alt bölge hiç gösterilmez (SCREENS.md §4.7
  /// "Bağlantısız" durumu).
  final String? linkedLabel;

  final bool isPinned;
  final VoidCallback? onTap;

  /// Verilirse, uzun basmada sabitleme/sabit kaldırma + sil seçeneklerini
  /// içeren hızlı eylem menüsü açılır (SCREENS.md §4.18 "kaydırma hızlı
  /// eylemi" — `TaskCardWidget` ile aynı uzun-basma deseni).
  final VoidCallback? onTogglePinned;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: (onTogglePinned == null && onDelete == null) ? null : () => _showQuickActions(context),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color ?? Colors.transparent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      if (contentPreview != null && contentPreview!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          contentPreview!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
                        ),
                      ],
                      if (linkedLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: tokens.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            linkedLabel!,
                            style: AppTypography.overline.copyWith(color: tokens.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    AppBottomSheet.show<void>(
      context,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onTogglePinned != null)
              ListTile(
                leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                title: Text(isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle'),
                onTap: () {
                  Navigator.of(context).pop();
                  onTogglePinned?.call();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Notu Sil'),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}
