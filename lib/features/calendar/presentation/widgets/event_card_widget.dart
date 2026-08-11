import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/calendar_event.dart';

/// Event Card — COMPONENTS.md §8.3: günlük ajandada bir görev/hedef öğesi.
/// Sol: saat etiketi → Orta: başlık + kaynak ikonu. Calendar'ın kendi detay
/// ekranı yoktur; dokunma ilgili görev/hedef detayına gider (çağıran
/// sayfada yönlendirilir).
class EventCardWidget extends StatelessWidget {
  const EventCardWidget({
    super.key,
    required this.title,
    required this.source,
    this.time,
    this.isCompleted = false,
    this.onTap,
  });

  final String title;
  final CalendarEventSource source;

  /// `HH:mm`, opsiyonel.
  final String? time;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  time ?? '--:--',
                  style: AppTypography.caption.copyWith(color: tokens.textSecondary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                source == CalendarEventSource.task ? Icons.check_circle_outline : Icons.flag_outlined,
                size: 16,
                color: tokens.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd.copyWith(
                    color: isCompleted ? tokens.textDisabled : theme.colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
