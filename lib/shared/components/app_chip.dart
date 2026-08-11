import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Chip — COMPONENTS.md §6.5/§6.6, UI_GUIDELINES.md §7.8: 32dp yükseklik,
/// tam yuvarlak (pill) radius. Öncelik seçimi (Create/Edit Task) ve filtre
/// chip'leri (Tasks listesi) için ortak bileşen — 2+ feature kullanımı
/// nedeniyle `shared/components/`'te (FOLDER_STRUCTURE.md §6.3).
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.onTap,
    this.selectedColor,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  /// Verilmezse `colorScheme.primary` kullanılır (Default filtre/seçim
  /// chip'i); öncelik seçiminde `AppPriorityColors.low/medium/high` verilir.
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final accent = selectedColor ?? Theme.of(context).colorScheme.primary;

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.16) : Colors.transparent,
        border: Border.all(color: selected ? accent : tokens.border),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: selected ? accent : tokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: onTap == null || !enabled
          ? chip
          : SizedBox(
              height: 48,
              child: Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: chip,
                ),
              ),
            ),
    );
  }
}
