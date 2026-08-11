import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../shared/components/project_color_badge_widget.dart';

/// Project Card — COMPONENTS.md §4.3/§7.1. Yalnızca Projects feature'ı
/// tarafından kullanıldığından (FOLDER_STRUCTURE.md §6.3 "2+ feature"
/// eşiğinin altında) `shared/` yerine bu feature'ın kendi `widgets/`
/// klasöründe kalır.
class ProjectCardWidget extends StatelessWidget {
  const ProjectCardWidget({
    super.key,
    required this.title,
    required this.colorHex,
    required this.taskCount,
    required this.completedTaskCount,
    this.isArchived = false,
    this.onTap,
  });

  final String title;
  final String colorHex;
  final int taskCount;
  final int completedTaskCount;
  final bool isArchived;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final ratio = taskCount == 0 ? 0.0 : completedTaskCount / taskCount;

    final content = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProjectColorBadge(color: hexToColor(colorHex)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
                  if (isArchived) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: tokens.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Arşivlendi',
                        style: AppTypography.overline.copyWith(color: tokens.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$completedTaskCount/$taskCount görev',
                style: AppTypography.caption.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: 4),
              // COMPONENTS.md §7.2 — kart içi 6dp, dolgu primary, track primary-light.
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: tokens.primaryLight,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return isArchived ? Opacity(opacity: 0.6, child: content) : content;
  }
}
