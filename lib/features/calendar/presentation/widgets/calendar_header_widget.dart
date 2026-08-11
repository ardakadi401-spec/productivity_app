import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

const _monthNames = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

/// Calendar Header — COMPONENTS.md §8.1: ay/yıl başlığı + önceki/sonraki ay
/// eylemleri; başlığa dokunma hızlı yıl/ay seçiciyi açar. "Bugün" eylemi,
/// ROADMAP.md FAZ 7 "Tarih filtreleri (bugün...)" kriterinin hızlı erişim
/// karşılığıdır.
class CalendarHeaderWidget extends StatelessWidget {
  const CalendarHeaderWidget({
    super.key,
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onMonthYearTap,
  });

  /// Yalnızca yıl/ay anlamlıdır.
  final DateTime month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final VoidCallback onMonthYearTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Önceki ay',
          onPressed: onPreviousMonth,
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onMonthYearTap,
            child: Center(
              child: Text(
                '${_monthNames[month.month - 1]} ${month.year}',
                style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Sonraki ay',
          onPressed: onNextMonth,
        ),
        TextButton(
          onPressed: onToday,
          child: Text('Bugün', style: AppTypography.button.copyWith(color: tokens.textSecondary)),
        ),
      ],
    );
  }
}
