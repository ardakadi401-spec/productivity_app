import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../domain/entities/habit.dart';
import '../utils/habit_color_options.dart';
import '../utils/habit_frequency_label.dart';
import '../utils/habit_icon_options.dart';

/// Yeni Alışkanlık / düzenleme Bottom Sheet'inin ortak alan seti
/// (SCREENS.md §4.15, PRD §6.9) — Tasks/Projects/Goals'ın form field
/// widget'larıyla aynı desen.
class HabitFormFields extends StatelessWidget {
  const HabitFormFields({
    super.key,
    required this.nameController,
    this.nameError,
    required this.icon,
    required this.onIconChanged,
    required this.color,
    required this.onColorChanged,
    required this.targetFrequency,
    required this.onTargetFrequencyChanged,
    required this.targetDays,
    required this.onToggleTargetDay,
  });

  final TextEditingController nameController;
  final String? nameError;

  final String? icon;
  final ValueChanged<String> onIconChanged;

  final String color;
  final ValueChanged<String> onColorChanged;

  final HabitTargetFrequency targetFrequency;
  final ValueChanged<HabitTargetFrequency> onTargetFrequencyChanged;

  final List<int> targetDays;
  final ValueChanged<int> onToggleTargetDay;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Alışkanlık Adı',
          controller: nameController,
          errorText: nameError,
          hintText: 'Alışkanlık adı',
        ),
        const SizedBox(height: AppSpacing.md),
        Text('İkon', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final key in habitIconOptions) _IconDot(iconKey: key, selected: key == icon, onTap: () => onIconChanged(key)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Renk', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final hex in habitColorPalette)
              _ColorDot(hex: hex, selected: hex == color, onTap: () => onColorChanged(hex)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Tekrar Sıklığı', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            AppChip(
              label: 'Her Gün',
              selected: targetFrequency == HabitTargetFrequency.daily,
              onTap: () => onTargetFrequencyChanged(HabitTargetFrequency.daily),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppChip(
              label: 'Belirli Günler',
              selected: targetFrequency == HabitTargetFrequency.specificDays,
              onTap: () => onTargetFrequencyChanged(HabitTargetFrequency.specificDays),
            ),
          ],
        ),
        if (targetFrequency == HabitTargetFrequency.specificDays) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var day = 1; day <= 7; day++)
                AppChip(
                  label: weekdayShortLabels[day - 1],
                  selected: targetDays.contains(day),
                  onTap: () => onToggleTargetDay(day),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _IconDot extends StatelessWidget {
  const _IconDot({required this.iconKey, required this.selected, required this.onTap});

  final String iconKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? theme.colorScheme.primary.withValues(alpha: 0.16) : Colors.transparent,
          border: Border.all(color: selected ? theme.colorScheme.primary : tokens.border),
        ),
        child: Icon(
          habitIconFor(iconKey),
          size: 20,
          color: selected ? theme.colorScheme.primary : tokens.textSecondary,
        ),
      ),
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
