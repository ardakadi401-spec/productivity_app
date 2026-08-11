/// Component animasyon süreleri — COMPONENTS.md Bölüm 15 (Animation Rules).
class AppAnimationDurations {
  AppAnimationDurations._();

  /// Buton basılı (pressed) durumu — 100ms ease-out scale.
  static const buttonPress = Duration(milliseconds: 100);

  /// Dialog açılışı — 180ms ease-out (scale 0.95→1 + fade).
  static const dialogOpen = Duration(milliseconds: 180);

  /// Bottom sheet açılışı — 220ms ease-out (slide-up).
  static const bottomSheetOpen = Duration(milliseconds: 220);

  /// Snackbar kapanışı — 200ms slide-up + fade.
  static const snackbarDismiss = Duration(milliseconds: 200);

  /// Snackbar otomatik kapanma süresi (11.5).
  static const snackbarVisible = Duration(seconds: 4);
}
