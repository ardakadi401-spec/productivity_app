import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../utils/project_color_mapping.dart';

/// Yeni Proje Bottom Sheet / düzenleme formunun ortak alan seti
/// (SCREENS.md §6.3 "ad, renk/ikon, açıklama") — Tasks'ın
/// `TaskFormFields`'ı ile aynı desen: yalnızca sunumdan sorumludur, state
/// sahipliği çağıran controller'dadır.
class ProjectFormFields extends StatelessWidget {
  const ProjectFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    this.titleError,
    required this.color,
    required this.onColorChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? titleError;
  final String color;
  final ValueChanged<String> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Proje Adı',
          controller: titleController,
          errorText: titleError,
          hintText: 'Proje adı',
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Açıklama (opsiyonel)',
          controller: descriptionController,
          hintText: 'Detayları ekle',
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Renk', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final hex in projectColorPalette)
              _ColorDot(hex: hex, selected: hex == color, onTap: () => onColorChanged(hex)),
          ],
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.hex, required this.selected, required this.onTap});

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hexToColor(hex),
          shape: BoxShape.circle,
          border: selected ? Border.all(color: theme.colorScheme.onSurface, width: 2) : null,
        ),
        child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
      ),
    );
  }
}
