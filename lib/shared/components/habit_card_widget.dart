import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'completion_button_widget.dart';
import 'streak_indicator_widget.dart';

/// Habit Card — COMPONENTS.md §9.1. Dashboard VE Habits feature'ı
/// tarafından kullanıldığından (ortaklık eşiği, FOLDER_STRUCTURE.md §6.3)
/// `shared/components/`'te; `TaskCardWidget`/`GoalCardWidget` ile aynı
/// ilke — yalnızca primitive parametrelere bağımlıdır (`Habit` domain
/// entity'sini bilmez).
class HabitCardWidget extends StatelessWidget {
  const HabitCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.frequencySummary,
    required this.currentStreak,
    required this.isCompletedToday,
    required this.isScheduledToday,
    this.onTap,
    this.onCompletionChanged,
  });

  final String title;
  final IconData icon;
  final String frequencySummary;
  final int currentStreak;
  final bool isCompletedToday;

  /// `false` ise (COMPONENTS.md §9.1 "Bugün Atlandı") kart soluklaştırılır,
  /// Completion Button etkileşimsiz olur.
  final bool isScheduledToday;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompletionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      frequencySummary,
                      style: AppTypography.caption.copyWith(color: tokens.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreakIndicator(streak: currentStreak),
                  const SizedBox(height: 4),
                  CompletionButton(
                    isCompleted: isCompletedToday,
                    enabled: isScheduledToday,
                    onChanged: onCompletionChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return isScheduledToday ? content : Opacity(opacity: 0.6, child: content);
  }
}
