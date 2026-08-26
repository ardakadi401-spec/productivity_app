import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/authentication/domain/entities/app_user.dart';
import 'package:productivity_app/features/authentication/presentation/pages/profile_page.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';

import '../../fake_auth_repository.dart';

Widget _wrap(FakeAuthRepository fake) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const ProfilePage()),
  );
}

void main() {
  testWidgets('profil bilgileri (ad, e-posta, giriş yöntemi) render olur', (tester) async {
    final fake = FakeAuthRepository()..authStateValue = testUser;
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('a@b.com'), findsOneWidget);
    expect(find.text('E-posta'), findsOneWidget);
  });

  testWidgets('Google ile giriş yapan kullanıcı için "Google" gösterilir', (tester) async {
    const googleUser = AppUser(
      uid: 'u2',
      email: 'g@b.com',
      name: 'Gül',
      authProvider: AuthProviderType.google,
    );
    final fake = FakeAuthRepository()..authStateValue = googleUser;
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('kalem ikonuna dokunup yeni ad girilince updateProfile çağrılır', (tester) async {
    final fake = FakeAuthRepository()
      ..authStateValue = testUser
      ..updateProfileResult = const Ok(
        AppUser(uid: 'u1', email: 'a@b.com', name: 'Yeni Ad', authProvider: AuthProviderType.email),
      );
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Yeni Ad');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(fake.lastUpdatedName, 'Yeni Ad');
    expect(find.text('Profil güncellendi'), findsOneWidget);
  });

  testWidgets('boş adla kaydetmeye çalışınca hata gösterilir, updateProfile çağrılmaz', (tester) async {
    final fake = FakeAuthRepository()..authStateValue = testUser;
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    expect(find.text('Ad boş olamaz.'), findsOneWidget);
    expect(fake.lastUpdatedName, isNull);
  });

  testWidgets('updateProfile hata dönerse Snackbar\'da gösterilir', (tester) async {
    final fake = FakeAuthRepository()
      ..authStateValue = testUser
      ..updateProfileResult = const Err(UnknownFailure('Bir şeyler ters gitti.'));
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Yeni Ad');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.text('Bir şeyler ters gitti.'), findsOneWidget);
  });
}
