import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/features/vault/data/services/vault_encryption_service.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockAuth auth;
  late _MockUser user;

  setUp(() {
    auth = _MockAuth();
    user = _MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('user-1');
  });

  test('şifrelenen metin çözüldüğünde orijinaliyle eşleşir', () {
    final service = VaultEncryptionService(auth: auth);

    final cipherText = service.encrypt('gizli-şifre-123');
    final plainText = service.decrypt(cipherText);

    expect(plainText, 'gizli-şifre-123');
  });

  test('aynı düz metin her şifrelemede farklı şifreli metin üretir (rastgele IV)', () {
    final service = VaultEncryptionService(auth: auth);

    final first = service.encrypt('aynı-metin');
    final second = service.encrypt('aynı-metin');

    expect(first, isNot(second));
    expect(service.decrypt(first), 'aynı-metin');
    expect(service.decrypt(second), 'aynı-metin');
  });

  test('farklı kullanıcının anahtarıyla şifrelenen metin bu kullanıcıyla çözülemez', () {
    final serviceA = VaultEncryptionService(auth: auth);
    final cipherText = serviceA.encrypt('gizli-şifre');

    final otherUser = _MockUser();
    when(() => otherUser.uid).thenReturn('user-2');
    when(() => auth.currentUser).thenReturn(otherUser);
    final serviceB = VaultEncryptionService(auth: auth);

    expect(() => serviceB.decrypt(cipherText), throwsA(anything));
  });

  test('oturum açık değilken encrypt/decrypt AuthException fırlatır', () {
    when(() => auth.currentUser).thenReturn(null);
    final service = VaultEncryptionService(auth: auth);

    expect(() => service.encrypt('x'), throwsA(anything));
  });
}
