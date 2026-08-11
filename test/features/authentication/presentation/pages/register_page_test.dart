import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/authentication/presentation/pages/register_page.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';

import '../../fake_auth_repository.dart';

Widget _wrap(FakeAuthRepository fake) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const RegisterPage()),
  );
}

void main() {
  testWidgets('form alanları render olur', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository()));

    expect(find.text('Ad'), findsOneWidget);
    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.text('Şifre Tekrar'), findsOneWidget);
    expect(find.text('Kayıt Ol'), findsWidgets);
  });

  testWidgets('şifreler eşleşmezse validasyon hatası gösterir', (tester) async {
    await tester.pumpWidget(_wrap(FakeAuthRepository()));

    await tester.enterText(find.byType(TextField).at(0), 'Ada Lovelace');
    await tester.enterText(find.byType(TextField).at(1), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret1');
    await tester.enterText(find.byType(TextField).at(3), 'farkli1');
    await tester.tap(find.text('Kayıt Ol').last);
    await tester.pump();

    expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
  });

  testWidgets('geçerli bilgilerle submit + email-already-in-use Snackbar gösterir', (tester) async {
    final fake = FakeAuthRepository()
      ..registerResult = const Err(AuthFailure('Bu e-posta adresi zaten kayıtlı.'));
    await tester.pumpWidget(_wrap(fake));

    await tester.enterText(find.byType(TextField).at(0), 'Ada Lovelace');
    await tester.enterText(find.byType(TextField).at(1), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret1');
    await tester.enterText(find.byType(TextField).at(3), 'secret1');
    await tester.tap(find.text('Kayıt Ol').last);
    await tester.pump();
    await tester.pump();

    expect(find.text('Bu e-posta adresi zaten kayıtlı.'), findsOneWidget);
  });
}
