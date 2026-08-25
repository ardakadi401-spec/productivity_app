import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/settings/domain/entities/lock_settings.dart';
import 'package:productivity_app/features/settings/domain/repositories/lock_repository.dart';
import 'package:productivity_app/features/settings/presentation/pages/lock_page.dart';
import 'package:productivity_app/features/settings/presentation/providers/lock_providers.dart';

class _FakeLockRepository implements LockRepository {
  _FakeLockRepository({
    LockSettings initial = const LockSettings(method: LockMethod.pin, hasPinSet: true),
    this.biometricSucceeds = false,
  })  : current = initial,
        _controller = StreamController<LockSettings>.broadcast();

  static const correctPin = '1234';

  LockSettings current;
  bool biometricSucceeds;
  final StreamController<LockSettings> _controller;
  int biometricAttempts = 0;

  @override
  Stream<LockSettings> watchLockSettings() => Stream<LockSettings>.multi((controller) {
        controller.add(current);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<Result<bool>> verifyPin(String pin) async => Ok(pin == correctPin);

  @override
  Future<Result<bool>> authenticateWithBiometric() async {
    biometricAttempts++;
    return Ok(biometricSucceeds);
  }

  @override
  Future<bool> isBiometricAvailable() async => true;

  @override
  Future<Result<void>> setPin(String pin) async => const Ok(null);

  @override
  Future<Result<void>> setLockMethod(LockMethod method) async => const Ok(null);

  @override
  Future<Result<void>> disableLock() async => const Ok(null);
}

Widget _wrap(_FakeLockRepository repository, {required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: AppTheme.light, home: const LockPage()),
  );
}

void main() {
  testWidgets('yanlış PIN girilince hata gösterir, kilit açılmaz', (tester) async {
    final repository = _FakeLockRepository();
    final container = ProviderContainer(
      overrides: [lockRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(repository, container: container));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '0000');
    await tester.pump();
    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();

    expect(find.text('Yanlış PIN, tekrar dene.'), findsOneWidget);
    expect(container.read(appLockStateProvider), isFalse); // test ortamı zaten false başlar
  });

  testWidgets('doğru PIN girilince appLockStateProvider false yapılır (kilit açılır)', (tester) async {
    final repository = _FakeLockRepository();
    final container = ProviderContainer(
      overrides: [lockRepositoryProvider.overrideWithValue(repository)],
    );
    container.read(appLockStateProvider.notifier).state = true; // önce kilitli varsay
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(repository, container: container));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '1234');
    await tester.pump();
    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();

    expect(container.read(appLockStateProvider), isFalse);
  });

  testWidgets('method=biometric ise girişte otomatik biyometrik dener, başarısız olana kadar PIN '
      'alanı gösterilmez', (tester) async {
    final repository = _FakeLockRepository(
      initial: const LockSettings(method: LockMethod.biometric, hasPinSet: true),
      biometricSucceeds: false,
    );
    final container = ProviderContainer(
      overrides: [lockRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(repository, container: container));
    await tester.pumpAndSettle();

    expect(repository.biometricAttempts, 1);
    expect(find.text('Biyometrik ile Aç'), findsOneWidget);
  });

  testWidgets(
    'method=biometric ve biyometrik başarısız olunca PIN alanına düşülür (ARCHITECTURE.md §13.4 '
    'fallback — bu olmadan kullanıcı PopScope(canPop:false) nedeniyle ekranda sıkışırdı), doğru '
    'PIN ile kilit açılır',
    (tester) async {
      final repository = _FakeLockRepository(
        initial: const LockSettings(method: LockMethod.biometric, hasPinSet: true),
        biometricSucceeds: false,
      );
      final container = ProviderContainer(
        overrides: [lockRepositoryProvider.overrideWithValue(repository)],
      );
      container.read(appLockStateProvider.notifier).state = true;
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(repository, container: container));
      await tester.pumpAndSettle();

      expect(repository.biometricAttempts, 1);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();
      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      expect(container.read(appLockStateProvider), isFalse);
    },
  );

  testWidgets('method=biometric ve doğrulama başarılıysa kilit açılır', (tester) async {
    final repository = _FakeLockRepository(
      initial: const LockSettings(method: LockMethod.biometric, hasPinSet: false),
      biometricSucceeds: true,
    );
    final container = ProviderContainer(
      overrides: [lockRepositoryProvider.overrideWithValue(repository)],
    );
    container.read(appLockStateProvider.notifier).state = true;
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(repository, container: container));
    await tester.pumpAndSettle();

    expect(container.read(appLockStateProvider), isFalse);
  });

  testWidgets('method=both ise hem PIN alanı hem Biyometrik butonu gösterilir', (tester) async {
    final repository = _FakeLockRepository(
      initial: const LockSettings(method: LockMethod.both, hasPinSet: true),
      biometricSucceeds: false,
    );
    final container = ProviderContainer(
      overrides: [lockRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(repository, container: container));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Biyometrik ile Aç'), findsOneWidget);
  });
}
