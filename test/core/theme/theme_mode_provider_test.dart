import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme_mode.dart';
import 'package:productivity_app/core/theme/theme_mode_provider.dart';

void main() {
  test('varsayılan tema tercihi system', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), AppThemeMode.system);
  });

  test('setMode state\'i günceller ve dinleyicileri bilgilendirir', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final values = <AppThemeMode>[];
    container.listen(themeModeProvider, (previous, next) => values.add(next), fireImmediately: true);

    container.read(themeModeProvider.notifier).setMode(AppThemeMode.amoled);

    expect(container.read(themeModeProvider), AppThemeMode.amoled);
    expect(values, [AppThemeMode.system, AppThemeMode.amoled]);
  });
}
