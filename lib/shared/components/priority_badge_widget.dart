import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// `Task` domain entity'sine bağımlı olmadan (shared/ kuralı,
/// FOLDER_STRUCTURE.md §6.5) öncelik göstermek için feature-agnostik enum.
/// Task feature'ı kendi `TaskPriority`'sini bu enuma eşler.
enum PriorityLevel { low, medium, high }

/// Priority Badge — COMPONENTS.md §6.2: 18dp yükseklik, sabit pastel renk
/// eşlemesi + erişilebilirlik için renkle birlikte kısa metin.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.level});

  final PriorityLevel level;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (level) {
      PriorityLevel.low => (AppPriorityColors.low, 'Düşük'),
      PriorityLevel.medium => (AppPriorityColors.medium, 'Orta'),
      PriorityLevel.high => (AppPriorityColors.high, 'Yüksek'),
    };

    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
      alignment: Alignment.center,
      child: Text(
        label,
        // Pastel rozet zemini tema bağımsız her zaman açık tonda olduğundan
        // (UI_GUIDELINES.md §3.3), metin sabit koyu renkte kalır.
        style: AppTypography.overline.copyWith(color: AppLightColors.textPrimary),
      ),
    );
  }
}
