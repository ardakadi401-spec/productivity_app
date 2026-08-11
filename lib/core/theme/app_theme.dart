import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme_mode.dart';
import 'app_typography.dart';

/// UI_GUIDELINES.md Bölüm 12 — Açık/Koyu/AMOLED ThemeData fabrikaları.
///
/// Yalnızca renk + tipografi token'larını birleştirir; component-seviyesi
/// tema detayları (shape vb.) ilgili shared component implementasyonlarında
/// tamamlanır. Elevation skalası için bkz. `app_elevation.dart`.
class AppTheme {
  AppTheme._();

  /// [AppThemeMode.system] dahil, aktif platform parlaklığına göre doğru
  /// [ThemeData]'yı seçer. `system` modunda AMOLED'e otomatik geçilmez —
  /// UI_GUIDELINES.md Bölüm 12.4: AMOLED yalnızca kullanıcının ayarlardan
  /// manuel seçtiği bir varyanttır, sistem takibinin bir çıktısı değildir.
  static ThemeData resolve(AppThemeMode mode, Brightness platformBrightness) {
    switch (mode) {
      case AppThemeMode.light:
        return light;
      case AppThemeMode.dark:
        return dark;
      case AppThemeMode.amoled:
        return amoled;
      case AppThemeMode.system:
        return platformBrightness == Brightness.dark ? dark : light;
    }
  }

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: AppLightColors.background,
        surface: AppLightColors.surface,
        primary: AppLightColors.primary,
        secondary: AppLightColors.secondary,
        error: AppLightColors.accentDanger,
        textPrimary: AppLightColors.textPrimary,
        textSecondary: AppLightColors.textSecondary,
        border: AppLightColors.border,
        extension: AppColorsExtension.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: AppDarkColors.background,
        surface: AppDarkColors.surface,
        primary: AppDarkColors.primary,
        secondary: AppDarkColors.secondary,
        error: AppDarkColors.accentDanger,
        textPrimary: AppDarkColors.textPrimary,
        textSecondary: AppDarkColors.textSecondary,
        border: AppDarkColors.border,
        extension: AppColorsExtension.dark,
      );

  static ThemeData get amoled => _build(
        brightness: Brightness.dark,
        background: AppAmoledColors.background,
        surface: AppAmoledColors.surface,
        primary: AppAmoledColors.primary,
        secondary: AppAmoledColors.secondary,
        error: AppAmoledColors.accentDanger,
        textPrimary: AppAmoledColors.textPrimary,
        textSecondary: AppAmoledColors.textSecondary,
        border: AppAmoledColors.border,
        extension: AppColorsExtension.amoled,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color secondary,
    required Color error,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required AppColorsExtension extension,
  }) {
    // onPrimary/onSecondary/onError beyaz olarak sabitlendi (COMPONENTS.md
    // Bölüm 3'te "beyaz metin" tüm buton varyantları için varsayılan
    // beklenti). FAZ 2 bulgusu: bu, UI_GUIDELINES.md Bölüm 11.2'nin 4.5:1
    // metin kontrast kuralını marka renklerinin bazılarıyla tam
    // karşılamıyor (örn. Açık primary + beyaz ≈ 4.32:1, Koyu/AMOLED
    // primary + beyaz ≈ 3.07:1, Açık secondary + beyaz ≈ 2.2:1) - eşiğin
    // hemen altında/belirgin altında. Bu, UI_GUIDELINES.md'nin kendi seçtiği
    // marka renkleriyle kendi kontrast kuralı arasındaki bir gerilim; marka
    // rengini değiştirmeden koddan düzeltilemez, bu nedenle bilinçli olarak
    // olduğu gibi bırakıldı. Kesin WCAG uyumu gerekiyorsa çözüm
    // UI_GUIDELINES.md'deki primary/secondary hex değerlerinin
    // koyulaştırılmasıdır - bu karar bu fazın kapsamı dışındadır.
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      dividerColor: border,
      useMaterial3: true,
      extensions: [extension],
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: textPrimary),
        headlineLarge: AppTypography.h1.copyWith(color: textPrimary),
        headlineMedium: AppTypography.h2.copyWith(color: textPrimary),
        headlineSmall: AppTypography.h3.copyWith(color: textPrimary),
        bodyLarge: AppTypography.bodyLg.copyWith(color: textPrimary),
        bodyMedium: AppTypography.bodyMd.copyWith(color: textSecondary),
        labelSmall: AppTypography.caption.copyWith(color: textSecondary),
        labelMedium: AppTypography.overline.copyWith(color: textSecondary),
        labelLarge: AppTypography.button.copyWith(color: textPrimary),
      ),
    );
  }
}
