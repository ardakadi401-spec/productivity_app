import 'package:flutter/material.dart';

import '../../core/constants/app_animation_durations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// COMPONENTS.md Bölüm 3 — Primary/Secondary/Outline/Text varyantları.
/// Icon Button ve FAB, farklı boyut/şekil kuralları taşıdığı için ayrı
/// widget'lardır: [AppIconButton], [AppFabButton].
enum AppButtonVariant { primary, secondary, outline, text }

/// Basılı (pressed) durumda 3.2'deki 100ms ease-out scale animasyonunu
/// uygulayan, tüm buton ailesinin paylaştığı ortak sarmalayıcı.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.enabled, required this.onTap, required this.child});

  final bool enabled;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppAnimationDurations.buttonPress,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Primary/Secondary/Outline/Text buton — COMPONENTS.md Bölüm 3, 3.1, 3.2.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDestructive = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// 3.2 — spinner metni değiştirir, buton boyutu sabit kalır (layout shift yok).
  final bool isLoading;

  /// 3.1 — Destructive; Primary/Secondary'nin `color/accent-danger` ile
  /// render edilen hali, ayrı bir bileşen değildir.
  final bool isDestructive;
  final bool isFullWidth;

  bool get _filled => variant == AppButtonVariant.primary || variant == AppButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    // Etkileşim (tap) hem disabled hem loading'de kapalıdır, ama görsel
    // soluklaştırma (%50 opaklık) yalnızca gerçekten disabled durumunda
    // uygulanır — loading, 3.2'ye göre yalnızca metni spinner'a çevirir,
    // butonu "kapalı" gibi göstermez.
    final bool canInteract = onPressed != null && !isLoading;
    final bool isVisuallyDisabled = onPressed == null;

    final double height = _filled ? 52 : 44;
    final double radius = variant == AppButtonVariant.outline
        ? 10
        : (_filled ? 12 : 0);
    final Color accentColor = isDestructive ? colorScheme.error : colorScheme.primary;

    Color background;
    Color foreground;
    Border? border;
    switch (variant) {
      case AppButtonVariant.primary:
        background = accentColor;
        foreground = Colors.white;
      case AppButtonVariant.secondary:
        background = Colors.transparent;
        foreground = accentColor;
        border = Border.all(color: accentColor, width: 1.5);
      case AppButtonVariant.outline:
        background = Colors.transparent;
        foreground = colorScheme.onSurface;
        border = Border.all(color: tokens.border, width: 1);
      case AppButtonVariant.text:
        background = Colors.transparent;
        foreground = accentColor;
    }

    if (isVisuallyDisabled) {
      foreground = foreground.withValues(alpha: foreground.a * 0.5);
      if (_filled) background = background.withValues(alpha: background.a * 0.5);
    }

    final EdgeInsets padding = switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.secondary =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      AppButtonVariant.outline =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      AppButtonVariant.text => const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    };

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Text(label, style: AppTypography.button.copyWith(color: foreground));

    return Semantics(
      button: true,
      enabled: canInteract,
      label: label,
      child: _Pressable(
        enabled: canInteract,
        onTap: onPressed,
        child: Container(
          height: height,
          width: isFullWidth ? double.infinity : null,
          padding: padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Icon Button — COMPONENTS.md Bölüm 3: 24dp ikon, 48x48dp tam yuvarlak
/// dokunma alanı, `color/text-secondary` (aktifken `color/primary`).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final bool isEnabled = onPressed != null;
    Color color = isActive ? colorScheme.primary : tokens.textSecondary;
    if (!isEnabled) color = color.withValues(alpha: color.a * 0.5);

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: _Pressable(
        enabled: isEnabled,
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }
}

/// FAB — COMPONENTS.md Bölüm 3: 56dp standart / 40dp mini (ikincil ekranlar),
/// tam yuvarlak, `color/primary` dolgu, beyaz ikon.
class AppFabButton extends StatelessWidget {
  const AppFabButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.mini = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool mini;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = onPressed != null;
    final double size = mini ? 40 : 56;
    Color background = colorScheme.primary;
    if (!isEnabled) background = background.withValues(alpha: background.a * 0.5);

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: _Pressable(
        enabled: isEnabled,
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: mini ? 20 : 24, color: Colors.white),
        ),
      ),
    );
  }
}
