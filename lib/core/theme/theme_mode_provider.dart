import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme_mode.dart';

/// Gerçek, çalışan tema tercihi durumu — ROADMAP.md FAZ 4: "tema seçimi bu
/// fazda gerçek işlevle bağlanır". Bu provider yalnızca oturum-içi
/// (in-memory) state'i tutar; DATABASE.md `users/{uid}.settings.themeMode`
/// alanına kalıcı okuma/yazma, `features/settings/presentation/providers/
/// settings_providers.dart`'taki `themeModeSyncProvider` tarafından
/// (Settings feature'ının Repository/UseCase katmanı üzerinden) dışarıdan
/// kurulur. `autoDispose` kullanılmaz — ARCHITECTURE.md Bölüm 5.3:
/// uygulama genelinde kalıcı olması gereken durumlar kök seviyede tutulur.
///
/// Bu provider'ın kendisi bilinçli olarak `core/theme/` altında kalır (Core,
/// birden çok feature'ın okuduğu cross-cutting UI durumunu barındırabilir)
/// — kalıcılık bağlantısını KURAN taraf Settings'tir, çünkü Core'un
/// Feature'lara bağımlı olmaması gerekir (ARCHITECTURE.md Bölüm 15),
/// tersi değil.
class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => AppThemeMode.system;

  void setMode(AppThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeController, AppThemeMode>(
  ThemeModeController.new,
);
