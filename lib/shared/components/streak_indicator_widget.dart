import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Streak Indicator — COMPONENTS.md §9.2: sabit alev ikonu
/// (`color/accent-warning`) + sayı; seri arttığında 300ms "pop" animasyonu.
/// `Habit` domain entity'sine bağımlı değildir (shared/ kuralı) — yalnızca
/// [streak] sayısını alır.
class StreakIndicator extends StatefulWidget {
  const StreakIndicator({super.key, required this.streak});

  final int streak;

  @override
  State<StreakIndicator> createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    lowerBound: 0.9,
    upperBound: 1.15,
    value: 1,
  );

  @override
  void didUpdateWidget(covariant StreakIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streak > oldWidget.streak) {
      _controller.forward(from: 0.9).then((_) => _controller.animateTo(1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return ScaleTransition(
      scale: _controller,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: tokens.accentWarning),
          const SizedBox(width: 2),
          Text(
            '${widget.streak}',
            style: AppTypography.caption.copyWith(
              color: tokens.accentWarning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
