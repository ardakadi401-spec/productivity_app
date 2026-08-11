import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// `Goal` domain entity'sine bağımlı olmadan (shared/ kuralı,
/// FOLDER_STRUCTURE.md §6.5 — `PriorityBadge`'in `PriorityLevel`'ı ile aynı
/// desen) hedef durumunu göstermek için feature-agnostik enum. Goals
/// feature'ı kendi `GoalStatus`'unu bu enuma eşler.
enum GoalCardState { inProgress, achieved, missed }

/// Goal Card — COMPONENTS.md §4.4/§7.1. Dashboard VE Goals feature'ı
/// tarafından kullanıldığından (ortaklık eşiği, FOLDER_STRUCTURE.md §6.3)
/// `shared/components/`'te; `TaskCardWidget` ile aynı ilke — yalnızca
/// primitive parametrelere bağımlıdır.
class GoalCardWidget extends StatelessWidget {
  const GoalCardWidget({
    super.key,
    required this.title,
    required this.periodLabel,
    required this.state,
    required this.progressRatio,
    this.onTap,
  });

  final String title;

  /// Önceden çözümlenmiş görüntü metni ("GÜNLÜK"/"HAFTALIK"/"AYLIK").
  final String periodLabel;
  final GoalCardState state;

  /// 0–1 aralığında.
  final double progressRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final isMissed = state == GoalCardState.missed;

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
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
                  if (state == GoalCardState.achieved)
                    Icon(Icons.check_circle, size: 18, color: theme.colorScheme.secondary)
                  else if (isMissed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: tokens.border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Kaçırıldı',
                        style: AppTypography.overline.copyWith(color: tokens.textSecondary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(periodLabel, style: AppTypography.overline.copyWith(color: tokens.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressRatio.clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: tokens.primaryLight,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '%${(progressRatio.clamp(0, 1) * 100).round()}',
                    style: AppTypography.caption.copyWith(color: tokens.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return isMissed ? Opacity(opacity: 0.7, child: content) : content;
  }
}
