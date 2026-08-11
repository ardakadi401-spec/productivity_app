import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../dialogs/app_bottom_sheet.dart';
import 'due_date_label_widget.dart';
import 'priority_badge_widget.dart';

/// Task Card — COMPONENTS.md §4.2/§6.1. Dashboard VE Tasks feature'ı
/// tarafından kullanıldığından (ortaklık eşiği, FOLDER_STRUCTURE.md §6.3)
/// `shared/components/`'te; `Task` domain entity'sine değil yalnızca
/// primitive parametrelere bağımlıdır (`shared/` katman kuralı).
class TaskCardWidget extends StatelessWidget {
  const TaskCardWidget({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.priority,
    this.dueDate,
    this.dueTime,
    this.subtaskCount = 0,
    this.completedSubtaskCount = 0,
    this.onTap,
    this.onCompletedChanged,
    this.onDelete,
  });

  final String title;
  final bool isCompleted;
  final PriorityLevel priority;
  final DateTime? dueDate;
  final String? dueTime;
  final int subtaskCount;
  final int completedSubtaskCount;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompletedChanged;

  /// Verilirse, uzun basmada "Sil" seçeneği içeren bir hızlı eylem menüsü
  /// açılır (COMPONENTS.md §4.2 "uzun basma → hızlı eylemler").
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
        onLongPress: onDelete == null ? null : () => _showQuickActions(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompletionCheckbox(
                value: isCompleted,
                onChanged: onCompletedChanged,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: AppTypography.bodyLg.copyWith(
                        color: isCompleted ? tokens.textDisabled : theme.colorScheme.onSurface,
                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                      child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    if (dueDate != null || subtaskCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          DueDateLabel(
                            dueDate: dueDate,
                            dueTime: dueTime,
                            isCompleted: isCompleted,
                          ),
                          if (dueDate != null && subtaskCount > 0) const SizedBox(width: AppSpacing.sm),
                          if (subtaskCount > 0)
                            Text(
                              '$completedSubtaskCount/$subtaskCount alt görev',
                              style: AppTypography.caption.copyWith(color: tokens.textSecondary),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PriorityBadge(level: priority),
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
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Görevi Sil'),
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

/// Completion Checkbox — COMPONENTS.md §6.3: 22dp görsel, 44dp dokunma
/// alanı, işaretlenince `primary` dolgu + beyaz check + 150ms scale-in.
class _CompletionCheckbox extends StatelessWidget {
  const _CompletionCheckbox({required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: value ? theme.colorScheme.primary : tokens.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                scale: value ? 1 : 0,
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
