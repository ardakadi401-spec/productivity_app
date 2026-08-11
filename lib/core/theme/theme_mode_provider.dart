import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme_mode.dart';

/// Gerçek, çalışan tema tercihi durumu — ROADMAP.md FAZ 4: "tema seçimi bu
/// fazda gerçek işlevle bağlanır". Şu an yalnızca oturum içi (in-memory)
/// tutulur; DATABASE.md `users/{uid}.settings.themeMode` alanına kalıcı
/// yazma, Settings feature'ının kendi Repository/UseCase katmanıyla
/// FAZ 16'da eklenecektir (bkz. ROADMAP.md FAZ 16). `autoDispose`
/// kullanılmaz — ARCHITECTURE.md Bölüm 5.3: uygulama genelinde kalıcı
/// olması gereken durumlar kök seviyede tutulur.
///
/// Henüz ayrı bir `settings` feature'ı olmadığından bu provider bilinçli
/// olarak `core/theme/` altında kalıyor; FAZ 16'da o feature kurulduğunda
/// `features/settings/presentation/providers/`e taşınması ARCHITECTURE.md
/// Bölüm 13'teki konumlandırma kuralına göre doğru adım olacaktır.
class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => AppThemeMode.system;

  void setMode(AppThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeController, AppThemeMode>(
  ThemeModeController.new,
);
