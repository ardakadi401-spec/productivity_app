import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';

import '../../fake_auth_repository.dart';

Widget _wrap(FakeAuthRepository fake) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const ForgotPasswordPage()),
  );
}

void main() {
  testWidgets('form alanı ve buton render olur', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository()));

    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Sıfırlama Bağlantısı Gönder'), findsOneWidget);
  });

  testWidgets('geçersiz e-posta ile submit edilince validasyon hatası gösterir', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository()));

    await tester.enterText(find.byType(TextField), 'gecersiz');
    await tester.tap(find.text('Sıfırlama Bağlantısı Gönder'));
    await tester.pump();

    expect(find.text('Geçerli bir e-posta adresi gir.'), findsOneWidget);
  });

  testWidgets('kayıtlı olmayan e-posta hatası Snackbar\'da gösterilir', (tester) async {
    final fake = FakeAuthRepository()..voidResult = const Err(AuthFailure('E-posta veya şifre hatalı.'));
    await tester.pumpWidget(_wrap(fake));

    await tester.enterText(find.byType(TextField), 'a@b.com');
    await tester.tap(find.text('Sıfırlama Bağlantısı Gönder'));
    await tester.pump();
    await tester.pump();

    expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
  });
}
