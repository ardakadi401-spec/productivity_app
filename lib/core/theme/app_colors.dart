import 'package:flutter/material.dart';

/// Açık tema renk token'ları — UI_GUIDELINES.md Bölüm 3.2.
class AppLightColors {
  AppLightColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEEEDFF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color secondary = Color(0xFF2FC4A0);
  static const Color accentWarning = Color(0xFFFFB020);
  static const Color accentDanger = Color(0xFFFF5A5F);
  static const Color accentInfo = Color(0xFF3AA0FF);
  static const Color background = Color(0xFFFAFAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECECF2);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B7B);
  static const Color textDisabled = Color(0xFFB0B0BC);
}

/// Koyu tema renk token'ları — UI_GUIDELINES.md Bölüm 3.5.
class AppDarkColors {
  AppDarkColors._();

  static const Color background = Color(0xFF121218);
  static const Color surface = Color(0xFF1C1C24);
  static const Color surfaceElevated = Color(0xFF24242E);
  static const Color border = Color(0xFF2E2E3A);
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFFA0A0B0);
  static const Color primary = Color(0xFF8B84FF);
  static const Color secondary = Color(0xFF4FE0BC);
  static const Color accentDanger = Color(0xFFFF7A7F);

  // UI_GUIDELINES.md Bölüm 3.5 bu token'lar için ayrı bir koyu tema değeri
  // tanımlamıyor (FAZ 2 bulgusu). Aşağıdaki değerler, dokümanın tanımladığı
  // primary/secondary/accent-danger çiftlerindeki Açık->Koyu HSL dönüşüm
  // örüntüsünden (ortalama +8.2 lightness, +2.9 saturation, aynı hue)
  // türetilmiştir - doküman tarafından doğrudan verilmemiştir.
  static const Color accentWarning = Color(0xFFFFBE4A);
  static const Color accentInfo = Color(0xFF64B5FF);
  // text-secondary'nin kendi Açık->Koyu geçişindeki (+20.8 lightness) örüntüsü
  // text-disabled'a uygulanarak türetildi.
  static const Color textDisabled = Color(0xFFE9E9ED);
  // "Koyulaştırılmış/basılı" rolü: primary'nin kendi tema içindeki
  // Açık primary->primary-dark deltası (-16.1 lightness, -42.9 saturation)
  // Koyu tema primary'sine uygulanarak türetildi.
  static const Color primaryDark = Color(0xFF655ED3);
  // "Soluk vurgu/wash" rolü: Açık temada primary, beyaz surface üzerine
  // %96.5 açık bir ton olarak karışıyor; Koyu temada aynı rolü oynaması için
  // primary, beyaz yerine Koyu surface (#1C1C24) üzerine %18 oranında
  // karıştırıldı (yaygın "tonal overlay" tekniği - saf beyaza açmak koyu
  // arkaplanla çakışırdı).
  static const Color primaryLight = Color(0xFF302F4B);
}

/// AMOLED tema renk token'ları — UI_GUIDELINES.md Bölüm 3.6.
class AppAmoledColors {
  AppAmoledColors._();

  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0D);
  static const Color surfaceElevated = Color(0xFF151519);
  static const Color border = Color(0xFF232329);
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color primary = Color(0xFF8B84FF);

  // UI_GUIDELINES.md Bölüm 3.6, AMOLED'i koyu temanın özel bir varyantı olarak
  // tanımlar; ayrıca belirtilmeyen token'lar Koyu tema değerlerinden alınır.
  static const Color secondary = AppDarkColors.secondary;
  static const Color accentDanger = AppDarkColors.accentDanger;
  static const Color accentWarning = AppDarkColors.accentWarning;
  static const Color accentInfo = AppDarkColors.accentInfo;
  static const Color textSecondary = AppDarkColors.textSecondary;
  static const Color textDisabled = AppDarkColors.textDisabled;
  static const Color primaryLight = AppDarkColors.primaryLight;
  static const Color primaryDark = AppDarkColors.primaryDark;
}

/// `ColorScheme`'in kapsamadığı özel token'lar (border, text-secondary,
/// text-disabled, primary-light/dark, accent-warning/info) için
/// `ThemeExtension`. Shared component'ler renk sabiti hiç yazmaz; her zaman
/// `Theme.of(context).colorScheme` (primary/secondary/error/surface) veya
/// `Theme.of(context).extension<AppColorsExtension>()!` (buradaki token'lar)
/// üzerinden okur — COMPONENTS.md Bölüm 16.4 token referans kuralı.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.border,
    required this.textSecondary,
    required this.textDisabled,
    required this.primaryLight,
    required this.primaryDark,
    required this.accentWarning,
    required this.accentInfo,
    required this.surfaceElevated,
  });

  final Color border;
  final Color textSecondary;
  final Color textDisabled;
  final Color primaryLight;
  final Color primaryDark;
  final Color accentWarning;
  final Color accentInfo;
  final Color surfaceElevated;

  static const light = AppColorsExtension(
    border: AppLightColors.border,
    textSecondary: AppLightColors.textSecondary,
    textDisabled: AppLightColors.textDisabled,
    primaryLight: AppLightColors.primaryLight,
    primaryDark: AppLightColors.primaryDark,
    accentWarning: AppLightColors.accentWarning,
    accentInfo: AppLightColors.accentInfo,
    // Açık temada ayrı bir "surface-elevated" tanımı yok (UI_GUIDELINES.md
    // Bölüm 3.2); kart zaten `surface` (#FFFFFF) ile zeminden ayrışıyor.
    surfaceElevated: AppLightColors.surface,
  );

  static const dark = AppColorsExtension(
    border: AppDarkColors.border,
    textSecondary: AppDarkColors.textSecondary,
    textDisabled: AppDarkColors.textDisabled,
    primaryLight: AppDarkColors.primaryLight,
    primaryDark: AppDarkColors.primaryDark,
    accentWarning: AppDarkColors.accentWarning,
    accentInfo: AppDarkColors.accentInfo,
    surfaceElevated: AppDarkColors.surfaceElevated,
  );

  static const amoled = AppColorsExtension(
    border: AppAmoledColors.border,
    textSecondary: AppAmoledColors.textSecondary,
    textDisabled: AppAmoledColors.textDisabled,
    primaryLight: AppAmoledColors.primaryLight,
    primaryDark: AppAmoledColors.primaryDark,
    accentWarning: AppAmoledColors.accentWarning,
    accentInfo: AppAmoledColors.accentInfo,
    surfaceElevated: AppAmoledColors.surfaceElevated,
  );

  @override
  AppColorsExtension copyWith({
    Color? border,
    Color? textSecondary,
    Color? textDisabled,
    Color? primaryLight,
    Color? primaryDark,
    Color? accentWarning,
    Color? accentInfo,
    Color? surfaceElevated,
  }) {
    return AppColorsExtension(
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      accentWarning: accentWarning ?? this.accentWarning,
      accentInfo: accentInfo ?? this.accentInfo,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      accentWarning: Color.lerp(accentWarning, other.accentWarning, t)!,
      accentInfo: Color.lerp(accentInfo, other.accentInfo, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
    );
  }
}

/// Öncelik / etiket pastel seti — UI_GUIDELINES.md Bölüm 3.3 (tema bağımsız, sabit 8 renk).
class AppPriorityColors {
  AppPriorityColors._();

  static const List<Color> palette = [
    Color(0xFFFF8A8A),
    Color(0xFFFFC078),
    Color(0xFFFFE066),
    Color(0xFF8CE99A),
    Color(0xFF66D9E8),
    Color(0xFF74C0FC),
    Color(0xFFB197FC),
    Color(0xFFF783AC),
  ];

  // COMPONENTS.md Bölüm 6.2 — Priority Badge sabit eşlemesi.
  static const Color low = Color(0xFF8CE99A);
  static const Color medium = Color(0xFFFFC078);
  static const Color high = Color(0xFFFF8A8A);
}
