import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/project_color_badge_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/task.dart';

/// Create Task ve Edit Task ekranlarının ortak alan seti — SCREENS.md §4.12
/// "Create Task Screen ile birebir aynı alan seti". Yalnızca sunumdan
/// sorumludur; state sahipliği çağıran controller'dadır (Create/Edit farklı
/// controller'lara sahip olduğundan bu widget hiçbirine bağımlı değildir).
class TaskFormFields extends StatelessWidget {
  const TaskFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.titleError,
    required this.priority,
    required this.onPriorityChanged,
    required this.dueDate,
    required this.onDueDateChanged,
    required this.dueTime,
    required this.onDueTimeChanged,
    this.projects = const [],
    this.selectedProjectId,
    required this.onProjectChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? titleError;
  final TaskPriority priority;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final DateTime? dueDate;
  final ValueChanged<DateTime?> onDueDateChanged;

  /// `HH:mm`.
  final String? dueTime;
  final ValueChanged<String?> onDueTimeChanged;

  /// Proje Dropdown'ının seçenek listesi (COMPONENTS.md §5.4) — çağıran
  /// sayfa, Projects'in dışa açık `projectListProvider`'ından okuyup buraya
  /// iletir (bu widget saf sunumdan sorumludur, provider'a bağımlı değildir).
  final List<Project> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onProjectChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Başlık',
          controller: titleController,
          errorText: titleError,
          hintText: 'Görev başlığı',
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Açıklama (opsiyonel)',
          controller: descriptionController,
          hintText: 'Detayları ekle',
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Proje', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        _PickerField(
          icon: Icons.folder_outlined,
          label: _selectedProjectTitle() ?? 'Proje seç (opsiyonel)',
          onTap: () => _pickProject(context),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Öncelik', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            AppChip(
              label: 'Düşük',
              selected: priority == TaskPriority.low,
              selectedColor: AppPriorityColors.low,
              onTap: () => onPriorityChanged(TaskPriority.low),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppChip(
              label: 'Orta',
              selected: priority == TaskPriority.medium,
              selectedColor: AppPriorityColors.medium,
              onTap: () => onPriorityChanged(TaskPriority.medium),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppChip(
              label: 'Yüksek',
              selected: priority == TaskPriority.high,
              selectedColor: AppPriorityColors.high,
              onTap: () => onPriorityChanged(TaskPriority.high),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Son Tarih', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        // UI_GUIDELINES.md §7.15 — "Bugün"/"Yarın"/"Gelecek Hafta" hızlı seçim.
        Row(
          children: [
            AppChip(label: 'Bugün', onTap: () => onDueDateChanged(_daysFromNow(0))),
            const SizedBox(width: AppSpacing.sm),
            AppChip(label: 'Yarın', onTap: () => onDueDateChanged(_daysFromNow(1))),
            const SizedBox(width: AppSpacing.sm),
            AppChip(label: 'Gelecek Hafta', onTap: () => onDueDateChanged(_daysFromNow(7))),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _PickerField(
                icon: Icons.calendar_today_outlined,
                label: dueDate == null
                    ? 'Tarih seç'
                    : '${dueDate!.day}.${dueDate!.month}.${dueDate!.year}',
                onTap: () => _pickDate(context),
              ),
            ),
            if (dueDate != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PickerField(
                  icon: Icons.access_time_outlined,
                  label: dueTime ?? 'Saat seç',
                  onTap: () => _pickTime(context),
                ),
              ),
            ],
            if (dueDate != null)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Son tarihi kaldır',
                onPressed: () => onDueDateChanged(null),
              ),
          ],
        ),
      ],
    );
  }

  String? _selectedProjectTitle() {
    if (selectedProjectId == null) return null;
    for (final project in projects) {
      if (project.projectId == selectedProjectId) return project.title;
    }
    return null;
  }

  /// COMPONENTS.md §5.4 — Dropdown, native menü yerine Bottom Sheet içinde
  /// seçenek listesi açar.
  Future<void> _pickProject(BuildContext context) {
    return AppBottomSheet.show<void>(
      context,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Projesiz'),
            selected: selectedProjectId == null,
            onTap: () {
              onProjectChanged(null);
              Navigator.of(context).pop();
            },
          ),
          for (final project in projects)
            ListTile(
              leading: ProjectColorBadge(color: hexToColor(project.color)),
              title: Text(project.title),
              selected: project.projectId == selectedProjectId,
              onTap: () {
                onProjectChanged(project.projectId);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  DateTime _daysFromNow(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: days));
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) onDueDateChanged(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      onDueTimeChanged('$hour:$minute');
    }
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: tokens.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMd.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
