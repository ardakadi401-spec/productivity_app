import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Text Input — COMPONENTS.md Bölüm 5.1. Etiket her zaman alanın üzerinde
/// sabittir (floating label kullanılmaz); hata mesajı her zaman çözüm
/// odaklıdır ve alanın altında gösterilir.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.hintText,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController? controller;

  /// Non-null ise alan Error durumunda render edilir.
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final Widget? suffixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final bool hasError = widget.errorText != null;

    Color borderColor = tokens.border;
    double borderWidth = 1;
    if (hasError) {
      borderColor = colorScheme.error;
    } else if (_isFocused) {
      borderColor = colorScheme.primary;
      borderWidth = 1.5;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.caption.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    style: AppTypography.bodyLg.copyWith(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTypography.bodyLg.copyWith(color: tokens.textDisabled),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) widget.suffixIcon!,
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(color: colorScheme.error),
          ),
        ],
      ],
    );
  }
}
