import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Circular Progress — COMPONENTS.md §10.2. Pomodoro'nun geri sayım
/// göstergesi VE Statistics'in yüzde göstergesi tarafından kullanıldığından
/// (ortaklık eşiği, FOLDER_STRUCTURE.md §6.3 — FAZ 11'de Pomodoro'ya
/// feature-local bırakılmıştı, FAZ 12 Statistics ikinci gerçek kullanıcı
/// olunca `shared/components/`'e taşındı) `TaskCardWidget`/`PriorityBadge`
/// ile aynı ilke: yalnızca primitive parametrelere bağımlıdır — merkez
/// metni (yüzde veya `mm:ss`) çağıran feature önceden çözüp iletir.
class CircularProgressGaugeWidget extends StatelessWidget {
  const CircularProgressGaugeWidget({
    super.key,
    required this.progress,
    required this.centerLabel,
    this.subLabel,
    this.color,
    this.diameter = 120,
  });

  /// 0–1 aralığında.
  final double progress;

  /// Merkezde büyük gösterilen metin (örn. `"%42"` veya `"24:59"`).
  final String centerLabel;

  /// Merkez metninin altında küçük gösterilen opsiyonel ikinci satır.
  final String? subLabel;

  /// Verilmezse `colorScheme.primary` kullanılır (COMPONENTS.md §10.2
  /// varsayılanı); Pomodoro'nun mola fazında olduğu gibi çağıran farklı bir
  /// vurgu rengi geçebilir.
  final Color? color;

  /// Statistic Summary Card içinde 64dp, tam ekran görünümde 120dp
  /// (COMPONENTS.md §10.2).
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final fillColor = color ?? theme.colorScheme.primary;
    final centerStyle = diameter >= 120 ? AppTypography.h2 : AppTypography.caption;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: diameter,
            height: diameter,
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: diameter >= 120 ? 8 : 5,
              backgroundColor: tokens.primaryLight,
              color: fillColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerLabel, style: centerStyle.copyWith(color: theme.colorScheme.onSurface)),
              if (subLabel != null)
                Text(subLabel!, style: AppTypography.overline.copyWith(color: tokens.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
