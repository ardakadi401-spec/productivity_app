import 'package:flutter/material.dart';

/// Elevation (gölge) skalası — UI_GUIDELINES.md Bölüm 7.4.1.
///
/// Bölüm 12.3/12.4: Koyu temada gölgeler zayıf algılandığından derinlik
/// esas olarak `surface`/`surface-elevated` ton farkıyla sağlanır; AMOLED'de
/// gölge tamamen kaldırılır (yalnızca 1dp border ile derinlik). Bu nedenle
/// [level1]/[level2]/[level3] yalnızca Açık ve Koyu temada kullanılmalı,
/// AMOLED'de her zaman [none] tercih edilmelidir (çağıran kod, aktif temaya
/// göre bu seçimi kendisi yapar — bu sınıf yalnızca token'ları sağlar).
class AppElevation {
  AppElevation._();

  static const List<BoxShadow> none = [];

  static List<BoxShadow> level1({Color color = Colors.black}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.04),
          offset: const Offset(0, 1),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> level2({Color color = Colors.black}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> level3({Color color = Colors.black}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.12),
          offset: const Offset(0, 4),
          blurRadius: 16,
        ),
      ];
}
