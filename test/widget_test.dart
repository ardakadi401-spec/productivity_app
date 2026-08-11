import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:productivity_app/app/app.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';

import 'features/authentication/fake_auth_repository.dart';

void main() {
  testWidgets('app boots and Auth Guard redirects unauthenticated users to Welcome', (tester) async {
    final fake = FakeAuthRepository()..authStateValue = null;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fake)],
        child: const ProductivityApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.text('Kayıt Ol'), findsWidgets);
  });
}
