import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

const _weekdayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Aylık takvim grid'i — SCREENS.md §4.13, COMPONENTS.md §8.2 Day Cell.
/// Hafta Pazartesi'den başlar (`DateTime.weekday`: 1=Pazartesi..7=Pazar).
class MonthGridWidget extends StatelessWidget {
  const MonthGridWidget({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.eventDates,
    required this.onDaySelected,
  });

  /// Yalnızca yıl/ay anlamlıdır.
  final DateTime month;
  final DateTime selectedDate;

  /// Etkinliği olan günler (gün başına normalize edilmiş — saat bilgisi yok).
  final Set<DateTime> eventDates;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final firstOfMonth = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingCount = firstOfMonth.weekday - 1;
    final leadingDates = [
      for (var i = leadingCount; i >= 1; i--) firstOfMonth.subtract(Duration(days: i)),
    ];
    final monthDates = [
      for (var d = 1; d <= daysInMonth; d++) DateTime(month.year, month.month, d),
    ];
    final lastOfMonth = DateTime(month.year, month.month, daysInMonth);
    final soFar = leadingDates.length + monthDates.length;
    final trailingCount = (7 - soFar % 7) % 7;
    final trailingDates = [
      for (var i = 1; i <= trailingCount; i++) lastOfMonth.add(Duration(days: i)),
    ];
    final allDates = [...leadingDates, ...monthDates, ...trailingDates];

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.overline.copyWith(color: tokens.textSecondary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final date in allDates)
              _DayCell(
                date: date,
                isCurrentMonth: date.month == month.month && date.year == month.year,
                isToday: _isSameDay(date, DateTime.now()),
                isSelected: _isSameDay(date, selectedDate),
                hasEvents: eventDates.any((d) => _isSameDay(d, date)),
                onTap: date.month == month.month && date.year == month.year
                    ? () => onDaySelected(date)
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasEvents,
    this.onTap,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasEvents;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    Color textColor = theme.colorScheme.onSurface;
    if (!isCurrentMonth) {
      textColor = tokens.textDisabled;
    } else if (isToday) {
      textColor = Colors.white;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday ? theme.colorScheme.primary : Colors.transparent,
              border: isSelected && !isToday
                  ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: AppTypography.bodyMd.copyWith(color: textColor),
                ),
                if (hasEvents) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday ? Colors.white : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
