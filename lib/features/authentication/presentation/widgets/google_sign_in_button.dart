import 'package:flutter/material.dart';

import '../../../../shared/buttons/app_button_widget.dart';

/// Login Screen'de "Google ile Giriş" — SCREENS.md §4.3. COMPONENTS.md
/// Bölüm 3.2 kuralı ("bir ekranda en fazla 1 Primary Button") gereği Outline
/// varyantla render edilir; asıl Primary Button "Giriş Yap"tır.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Google ile Giriş',
      variant: AppButtonVariant.outline,
      isFullWidth: true,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}
