import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';

/// Due Date Label — COMPONENTS.md §6.4: durum renkleri (Bugün/Yaklaşan/
/// Gecikmiş) + erişilebilirlik için Gecikmiş durumda renk + ikon + metin.
/// `dueDate == null` ise hiçbir şey render etmez.
class DueDateLabel extends StatelessWidget {
  const DueDateLabel({
    super.key,
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
  });

  final DateTime? dueDate;

  /// `HH:mm` formatında, opsiyonel.
  final String? dueTime;

  /// Tamamlanmış görevler asla "Gecikti" olarak işaretlenmez.
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final date = dueDate;
    if (date == null) return const SizedBox.shrink();

    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final effective = _effectiveDateTime(date, dueTime);

    final isOverdue = !isCompleted && effective.isBefore(now);
    final isToday = DateFormatter.isSameDay(date, now);
    final isUpcoming =
        !isOverdue && !isCompleted && effective.difference(now) <= const Duration(hours: 24);

    final Color color = isOverdue
        ? theme.colorScheme.error
        : isToday
            ? tokens.accentInfo
            : isUpcoming
                ? tokens.accentWarning
                : tokens.textSecondary;

    final dayLabel = DateFormatter.relativeDay(date);
    final timeLabel = dueTime == null ? '' : ' $dueTime';
    final text = isOverdue ? 'Gecikti · $dayLabel$timeLabel' : '$dayLabel$timeLabel';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isOverdue ? Icons.schedule : Icons.calendar_today_outlined, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  DateTime _effectiveDateTime(DateTime date, String? time) {
    if (time == null) return DateTime(date.year, date.month, date.day, 23, 59, 59);
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 23 : 23;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 59 : 59;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
