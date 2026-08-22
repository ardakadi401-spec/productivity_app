import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Completion Button — COMPONENTS.md §9.3: 44dp çap, tam yuvarlak. Boş
/// (border'lı, dolgusuz) / Tamamlandı (`color/secondary` dolgu + beyaz
/// check), dokunma → 150ms scale+fade. Task Card'ın Completion
/// Checkbox'ından (kare, 22dp) ayrı bir bileşendir (COMPONENTS.md §9.3
/// notu) — günlük alışkanlık check-in'i için durum taşıyan bağımsız kontrol.
class CompletionButton extends StatelessWidget {
  const CompletionButton({
    super.key,
    required this.isCompleted,
    this.onChanged,
    this.enabled = true,
  });

  final bool isCompleted;
  final ValueChanged<bool>? onChanged;

  /// `false` ise (COMPONENTS.md §9.1 "Bugün Atlandı" — o gün hedef değil)
  /// buton soluklaştırılır ve etkileşimsizdir.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final canInteract = enabled && onChanged != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: canInteract ? () => onChanged!(!isCompleted) : null,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? theme.colorScheme.secondary : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? theme.colorScheme.secondary : tokens.border,
                    width: 1.5,
                  ),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  scale: isCompleted ? 1 : 0,
                  child: const Icon(Icons.check, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
