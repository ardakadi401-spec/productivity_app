import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../domain/entities/goal.dart';

const _periodLabels = {
  GoalPeriodType.daily: 'Günlük',
  GoalPeriodType.weekly: 'Haftalık',
  GoalPeriodType.monthly: 'Aylık',
};

/// Yeni Hedef / düzenleme Bottom Sheet'inin ortak alan seti (SCREENS.md
/// §4.14, PRD §5.6) — Tasks/Projects'in form field widget'larıyla aynı
/// desen: yalnızca sunumdan sorumludur.
class GoalFormFields extends StatelessWidget {
  const GoalFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.titleError,
    required this.periodType,
    this.onPeriodTypeChanged,
    required this.progressType,
    required this.onProgressTypeChanged,
    required this.manualProgress,
    required this.onManualProgressChanged,
    required this.linkedTaskIds,
    required this.onToggleLinkedTask,
    this.availableTasks = const [],
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? titleError;

  final GoalPeriodType periodType;

  /// `null` ise zaman aralığı salt-okunur gösterilir (düzenleme modu —
  /// oluşturulduktan sonra dönem değiştirilemez).
  final ValueChanged<GoalPeriodType>? onPeriodTypeChanged;

  final GoalProgressType progressType;
  final ValueChanged<GoalProgressType> onProgressTypeChanged;

  final int manualProgress;
  final ValueChanged<int> onManualProgressChanged;

  final List<String> linkedTaskIds;
  final ValueChanged<String> onToggleLinkedTask;

  /// Bağlı görev seçici için — çağıran sayfa, Tasks'ın dışa açık
  /// `taskListProvider`/`watchTasksUseCaseProvider`'ından okuyup buraya
  /// iletir.
  final List<Task> availableTasks;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Hedef Başlığı',
          controller: titleController,
          errorText: titleError,
          hintText: 'Hedef başlığı',
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Açıklama (opsiyonel)',
          controller: descriptionController,
          hintText: 'Detayları ekle',
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Zaman Aralığı', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        if (onPeriodTypeChanged case final onChanged?)
          Row(
            children: [
              for (final type in GoalPeriodType.values) ...[
                AppChip(
                  label: _periodLabels[type]!,
                  selected: periodType == type,
                  onTap: () => onChanged(type),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          )
        else
          Text(
            _periodLabels[periodType]!,
            style: AppTypography.bodyMd.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        const SizedBox(height: AppSpacing.md),
        Text('İlerleme Tipi', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            AppChip(
              label: 'Manuel',
              selected: progressType == GoalProgressType.manual,
              onTap: () => onProgressTypeChanged(GoalProgressType.manual),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppChip(
              label: 'Bağlı Görev',
              selected: progressType == GoalProgressType.linkedTasks,
              onTap: () => onProgressTypeChanged(GoalProgressType.linkedTasks),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (progressType == GoalProgressType.manual) ...[
          Text(
            'İlerleme: %$manualProgress',
            style: AppTypography.bodyMd.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          Slider(
            value: manualProgress.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '%$manualProgress',
            onChanged: (value) => onManualProgressChanged(value.round()),
          ),
        ] else ...[
          Text(
            'Bağlı Görevler (${linkedTaskIds.length})',
            style: AppTypography.bodyMd.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton.icon(
            onPressed: () => _pickLinkedTasks(context),
            icon: const Icon(Icons.checklist_outlined, size: 18),
            label: const Text('Görev Seç'),
          ),
        ],
      ],
    );
  }

  void _pickLinkedTasks(BuildContext context) {
    AppBottomSheet.show<void>(
      context,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return ListView(
            shrinkWrap: true,
            children: [
              for (final task in availableTasks)
                CheckboxListTile(
                  value: linkedTaskIds.contains(task.taskId),
                  title: Text(task.title),
                  onChanged: (_) {
                    onToggleLinkedTask(task.taskId);
                    setSheetState(() {});
                  },
                ),
              if (availableTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text('Henüz görev yok.'),
                ),
            ],
          );
        },
      ),
    );
  }
}
