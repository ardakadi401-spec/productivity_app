import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/authentication/presentation/pages/login_page.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';

import '../../fake_auth_repository.dart';

Widget _wrap(FakeAuthRepository fake) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const LoginPage()),
  );
}

void main() {
  testWidgets('form alanları ve butonlar render olur', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository()));

    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.text('Google ile Giriş'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.text('Şifremi Unuttum'), findsOneWidget);
  });

  testWidgets('boş alanlarla submit edilince validasyon hatası gösterir', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository()));

    await tester.tap(find.text('Giriş Yap').last);
    await tester.pump();

    expect(find.text('Geçerli bir e-posta adresi gir.'), findsOneWidget);
    expect(find.text('Şifreni gir.'), findsOneWidget);
  });

  testWidgets('geçerli bilgilerle submit + hata sonucu Snackbar gösterir', (tester) async {
    final fake = FakeAuthRepository()..emailResult = const Err(AuthFailure('E-posta veya şifre hatalı.'));
    await tester.pumpWidget(_wrap(fake));

    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.tap(find.text('Giriş Yap').last);
    await tester.pump(); // loading state
    await tester.pump(); // async result + listener

    expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
  });
}
