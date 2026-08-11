import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/authentication/presentation/pages/welcome_page.dart';

void main() {
  testWidgets('WelcomePage Giriş Yap ve Kayıt Ol butonlarını gösterir', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const WelcomePage()));

    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.text('Kayıt Ol'), findsOneWidget);
  });
}
