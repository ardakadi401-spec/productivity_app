import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/authentication/domain/entities/app_user.dart';
import 'package:productivity_app/routes/guards/auth_guard.dart';
import 'package:productivity_app/routes/route_paths/route_paths.dart';

const _user = AppUser(
  uid: 'u1',
  email: 'a@b.com',
  name: 'Ada',
  authProvider: AuthProviderType.email,
);

void main() {
  group('checking (AsyncLoading)', () {
    test('hiçbir rotada yönlendirme yapılmaz', () {
      const state = AsyncValue<AppUser?>.loading();
      for (final path in [RoutePaths.splash, RoutePaths.dashboard, RoutePaths.login]) {
        expect(authGuardRedirect(authState: state, location: path), isNull);
      }
    });
  });

  group('unauthenticated (AsyncData(null))', () {
    const state = AsyncValue<AppUser?>.data(null);

    test('Splash -> Welcome', () {
      expect(authGuardRedirect(authState: state, location: RoutePaths.splash), RoutePaths.welcome);
    });

    test('korumalı rota (Dashboard) -> Welcome', () {
      expect(authGuardRedirect(authState: state, location: RoutePaths.dashboard), RoutePaths.welcome);
    });

    for (final publicPath in [
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
    ]) {
      test('public rota ($publicPath) -> yönlendirme yok', () {
        expect(authGuardRedirect(authState: state, location: publicPath), isNull);
      });
    }
  });

  group('authenticated (AsyncData(user))', () {
    final state = AsyncValue<AppUser?>.data(_user);

    test('Splash -> Dashboard', () {
      expect(authGuardRedirect(authState: state, location: RoutePaths.splash), RoutePaths.dashboard);
    });

    for (final publicPath in [
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
    ]) {
      test('public rota ($publicPath) -> Dashboard', () {
        expect(authGuardRedirect(authState: state, location: publicPath), RoutePaths.dashboard);
      });
    }

    test('korumalı rota (Dashboard) -> yönlendirme yok', () {
      expect(authGuardRedirect(authState: state, location: RoutePaths.dashboard), isNull);
    });
  });

  group('hata (AsyncError) — güvenli varsayılan: unauthenticated gibi davranır', () {
    final state = AsyncValue<AppUser?>.error('boom', StackTrace.empty);

    test('korumalı rota -> Welcome', () {
      expect(authGuardRedirect(authState: state, location: RoutePaths.dashboard), RoutePaths.welcome);
    });

    test('Login -> yönlendirme yok', () {
      expect(authGuardRedirect(authState: state, location: RoutePaths.login), isNull);
    });
  });

  group('sonsuz döngü riski — yönlendirilen hedef bir daha yönlendirme istemez', () {
    test('unauthenticated: Welcome\'a yönlendirdikten sonra Welcome kararlıdır', () {
      const state = AsyncValue<AppUser?>.data(null);
      final redirected = authGuardRedirect(authState: state, location: RoutePaths.dashboard);
      expect(redirected, RoutePaths.welcome);
      expect(authGuardRedirect(authState: state, location: redirected!), isNull);
    });

    test('authenticated: Dashboard\'a yönlendirdikten sonra Dashboard kararlıdır', () {
      final state = AsyncValue<AppUser?>.data(_user);
      final redirected = authGuardRedirect(authState: state, location: RoutePaths.login);
      expect(redirected, RoutePaths.dashboard);
      expect(authGuardRedirect(authState: state, location: redirected!), isNull);
    });
  });

  group('hızlı ardışık navigasyon — ROADMAP.md FAZ 3 "race condition testi"', () {
    const allRoutes = [
      RoutePaths.splash,
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
      RoutePaths.dashboard,
      RoutePaths.tasks,
      RoutePaths.settings,
    ];
    final allStates = <AsyncValue<AppUser?>>[
      const AsyncValue.loading(),
      const AsyncValue.data(null),
      AsyncValue.data(_user),
      AsyncValue.error('boom', StackTrace.empty),
    ];

    test('her (durum, rota) kombinasyonunda yönlendirme zinciri en fazla 1 adımda sabitlenir', () {
      // `authGuardRedirect` saf/stateless bir fonksiyondur — GoRouter'ın
      // `redirect`'i art arda, hızlı çağırdığında her çağrı yalnızca kendi
      // argümanlarına bağlıdır. Bu, her (durum, rota) kombinasyonu için
      // birinci yönlendirmenin ürettiği hedefin ikinci kez asla
      // yönlendirilmediğini (yani sonsuz döngüye asla girilmediğini)
      // ispatlayarak "hızlı ardışık navigasyonda kararlılık" gereksinimini
      // kapsamlı şekilde doğrular.
      for (final state in allStates) {
        for (final location in allRoutes) {
          final firstHop = authGuardRedirect(authState: state, location: location);
          if (firstHop == null) continue;
          final secondHop = authGuardRedirect(authState: state, location: firstHop);
          expect(
            secondHop,
            isNull,
            reason: 'state=$state location=$location -> $firstHop -> $secondHop '
                '(2. adımda hâlâ yönlendirme istiyor, döngü riski!)',
          );
        }
      }
    });

    test('art arda farklı durumlarla çağrılan sonuçlar birbirini kirletmez (stateless)', () {
      // Durumun (checking/unauthenticated/authenticated/error) hızlı hızlı
      // değiştiği bir senaryoyu simüle eder (ör. refreshListenable'ın art
      // arda tetiklenmesi) — her çağrının yalnızca o anki argümanlara göre
      // sonuç verdiğini, önceki çağrılardan etkilenmediğini doğrular.
      final sequence = [
        (const AsyncValue<AppUser?>.loading(), RoutePaths.dashboard, null),
        (AsyncValue<AppUser?>.data(_user), RoutePaths.login, RoutePaths.dashboard),
        (const AsyncValue<AppUser?>.data(null), RoutePaths.dashboard, RoutePaths.welcome),
        (AsyncValue<AppUser?>.data(_user), RoutePaths.dashboard, null),
        (const AsyncValue<AppUser?>.loading(), RoutePaths.login, null),
      ];

      for (final (state, location, expected) in sequence) {
        expect(authGuardRedirect(authState: state, location: location), expected);
      }
    });
  });
}
