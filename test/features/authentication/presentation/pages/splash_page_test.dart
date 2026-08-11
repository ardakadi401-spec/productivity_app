import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/authentication/presentation/pages/splash_page.dart';

void main() {
  testWidgets('SplashPage yalnızca statik marka içeriği gösterir', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const SplashPage()));

    expect(find.text('Productivity App'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });
}
