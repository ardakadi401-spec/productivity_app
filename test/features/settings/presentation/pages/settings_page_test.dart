import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/core/theme/app_theme_mode.dart';
import 'package:productivity_app/core/theme/theme_mode_provider.dart';
import 'package:productivity_app/features/settings/presentation/pages/settings_page.dart';

void main() {
  testWidgets('SettingsPage tema seçeneklerini gösterir ve gerçekten state\'i değiştirir', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const SettingsPage()),
      ),
    );

    expect(find.text('Sistem'), findsOneWidget);
    expect(find.text('Açık'), findsOneWidget);
    expect(find.text('Koyu'), findsOneWidget);
    expect(find.text('AMOLED'), findsOneWidget);
    expect(container.read(themeModeProvider), AppThemeMode.system);

    await tester.tap(find.text('AMOLED'));
    await tester.pump();

    expect(container.read(themeModeProvider), AppThemeMode.amoled);
  });
}
