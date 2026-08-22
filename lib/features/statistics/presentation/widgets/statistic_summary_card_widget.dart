import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/circular_progress_gauge_widget.dart';

/// Statistic Summary Card — COMPONENTS.md §10.4. Statistics Screen'e özgü,
/// tek bir feature (Statistics) kullandığından `shared/`'e taşınmadan
/// feature-local tutulur (ARCHITECTURE.md erken paylaşım yasağı).
class StatisticSummaryCardWidget extends StatelessWidget {
  const StatisticSummaryCardWidget({super.key, required this.label, required this.value, this.progress});

  final String label;
  final String value;

  /// Verilirse alt bölgede 64dp Circular Progress gösterir (COMPONENTS.md
  /// §10.2 "Statistic Summary Card içinde 64dp çap" varyantı).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.overline.copyWith(color: tokens.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.h1.copyWith(color: theme.colorScheme.onSurface)),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.sm),
            CircularProgressGaugeWidget(
              progress: progress!,
              centerLabel: '%${(progress!.clamp(0, 1) * 100).round()}',
              diameter: 64,
            ),
          ],
        ],
      ),
    );
  }
}
