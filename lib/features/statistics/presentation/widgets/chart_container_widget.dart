import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/period_stats.dart';

/// Chart Container — COMPONENTS.md §10.3. Yalnızca Statistics kullandığından
/// (tek feature) `shared/`'e taşınmadan feature-local tutulur. Üçüncü taraf
/// bir grafik paketi eklemeden (pubspec'te hiç yok, minimal ayak izi
/// ilkesiyle tutarlı) düz çubuk grafik olarak uygulanır — dönem seçimi
/// Statistics Screen'in üst seviyesindeki tek chip grubuyla yapıldığından
/// (COMPONENTS §10.3'ün kendi iç seçicisi burada tekrarlanmaz, aynı seçim
/// zaten hem özet kartları hem bu grafiği besler).
class ChartContainerWidget extends StatelessWidget {
  const ChartContainerWidget({
    super.key,
    required this.title,
    required this.dailyBreakdown,
    required this.valueSelector,
    required this.dayLabelBuilder,
  });

  final String title;
  final List<DailyStatPoint> dailyBreakdown;
  final int Function(DailyStatPoint point) valueSelector;
  final String Function(DateTime date) dayLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final values = dailyBreakdown.map(valueSelector).toList();
    final maxValue = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    final hasData = maxValue > 0;

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
          Text(title, style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.md),
          if (!hasData)
            const EmptyState(icon: Icons.bar_chart_outlined, message: 'Bu dönem için veri yok')
          else
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < dailyBreakdown.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _Bar(
                        ratio: values[i] / maxValue,
                        label: dayLabelBuilder(dailyBreakdown[i].date),
                        color: theme.colorScheme.primary,
                        trackColor: tokens.primaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.ratio, required this.label, required this.color, required this.trackColor});

  final double ratio;
  final String label;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: trackColor, borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.03, 1),
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: tokens.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
