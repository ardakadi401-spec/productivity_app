import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../shared/components/project_color_badge_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';

/// Not oluşturma/düzenleme ekranının proje/görev bağlama alanı (SCREENS.md
/// §4.19: "Dropdown (proje/görev bağlama — opsiyonel)") — `TaskFormFields`'ın
/// proje seçici deseniyle aynı (Bottom Sheet tabanlı, COMPONENTS.md §5.4),
/// burada ayrıca görev seçimi de eklenir. Yalnızca sunumdan sorumludur;
/// seçenek listeleri çağıran sayfadan (Projects/Tasks'ın dışa açık
/// provider'larından okunmuş) iletilir.
class NoteLinkPickerWidget extends StatelessWidget {
  const NoteLinkPickerWidget({
    super.key,
    this.projects = const [],
    this.selectedProjectId,
    required this.onProjectChanged,
    this.tasks = const [],
    this.selectedTaskId,
    required this.onTaskChanged,
  });

  final List<Project> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onProjectChanged;

  final List<Task> tasks;
  final String? selectedTaskId;
  final ValueChanged<String?> onTaskChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Proje', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        _PickerField(
          icon: Icons.folder_outlined,
          label: _selectedProjectTitle() ?? 'Proje seç (opsiyonel)',
          onTap: () => _pickProject(context),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Görev', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        _PickerField(
          icon: Icons.checklist_outlined,
          label: _selectedTaskTitle() ?? 'Görev seç (opsiyonel)',
          onTap: () => _pickTask(context),
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

  String? _selectedTaskTitle() {
    if (selectedTaskId == null) return null;
    for (final task in tasks) {
      if (task.taskId == selectedTaskId) return task.title;
    }
    return null;
  }

  Future<void> _pickProject(BuildContext context) {
    return AppBottomSheet.show<void>(
      context,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Bağlantısız'),
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

  Future<void> _pickTask(BuildContext context) {
    return AppBottomSheet.show<void>(
      context,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Bağlantısız'),
            selected: selectedTaskId == null,
            onTap: () {
              onTaskChanged(null);
              Navigator.of(context).pop();
            },
          ),
          for (final task in tasks)
            ListTile(
              leading: const Icon(Icons.check_box_outline_blank),
              title: Text(task.title),
              selected: task.taskId == selectedTaskId,
              onTap: () {
                onTaskChanged(task.taskId);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
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
