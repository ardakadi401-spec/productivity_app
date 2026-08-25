import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/routes/guards/lock_guard.dart';
import 'package:productivity_app/routes/route_paths/route_paths.dart';

void main() {
  group('kimliği doğrulanmamış kullanıcı', () {
    test('kilitli olsa bile hiç yönlendirme yapmaz (Auth Guard\'a bırakır)', () {
      final result = lockGuardRedirect(
        isLocked: true,
        isAuthenticated: false,
        location: RoutePaths.dashboard,
      );
      expect(result, isNull);
    });
  });

  group('kimliği doğrulanmış + kilitli', () {
    test('korumalı bir rotadan /lock\'a yönlendirir', () {
      final result = lockGuardRedirect(
        isLocked: true,
        isAuthenticated: true,
        location: RoutePaths.dashboard,
      );
      expect(result, RoutePaths.lock);
    });

    test('zaten /lock\'taysa yönlendirme yapmaz', () {
      final result = lockGuardRedirect(
        isLocked: true,
        isAuthenticated: true,
        location: RoutePaths.lock,
      );
      expect(result, isNull);
    });
  });

  group('kimliği doğrulanmış + kilitli DEĞİL', () {
    test('/lock ekranındaysa Dashboard\'a yönlendirir (doğrulama tamamlandı)', () {
      final result = lockGuardRedirect(
        isLocked: false,
        isAuthenticated: true,
        location: RoutePaths.lock,
      );
      expect(result, RoutePaths.dashboard);
    });

    test('normal bir rotadaysa yönlendirme yapmaz', () {
      final result = lockGuardRedirect(
        isLocked: false,
        isAuthenticated: true,
        location: RoutePaths.tasks,
      );
      expect(result, isNull);
    });
  });

  group('sonsuz döngü riski — yönlendirilen hedef bir daha yönlendirme istemez', () {
    const allRoutes = [
      RoutePaths.dashboard,
      RoutePaths.tasks,
      RoutePaths.settings,
      RoutePaths.lock,
    ];
    const combinations = [
      (true, true), // locked, authenticated
      (false, true),
      (true, false),
      (false, false),
    ];

    test('her (kilit, auth, rota) kombinasyonunda yönlendirme zinciri en fazla 1 adımda sabitlenir', () {
      for (final (isLocked, isAuthenticated) in combinations) {
        for (final location in allRoutes) {
          final firstHop = lockGuardRedirect(
            isLocked: isLocked,
            isAuthenticated: isAuthenticated,
            location: location,
          );
          if (firstHop == null) continue;
          final secondHop = lockGuardRedirect(
            isLocked: isLocked,
            isAuthenticated: isAuthenticated,
            location: firstHop,
          );
          expect(
            secondHop,
            isNull,
            reason: 'isLocked=$isLocked isAuthenticated=$isAuthenticated '
                'location=$location -> $firstHop -> $secondHop (döngü riski!)',
          );
        }
      }
    });
  });
}
