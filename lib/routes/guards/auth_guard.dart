import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/domain/entities/app_user.dart';
import '../route_paths/route_paths.dart';

/// ARCHITECTURE.md Bölüm 9.2 / SCREENS.md Bölüm 2.3 — saf, test edilebilir
/// yönlendirme fonksiyonu. Router, Authentication feature'ının Domain
/// sözleşmesi (`AppUser?`) dışında hiçbir şey bilmez; Firebase SDK'sına
/// doğrudan erişmez.
///
/// Üç durum:
/// - `checking` (StreamProvider henüz ilk değerini vermedi) → yönlendirme yok.
/// - `unauthenticated` (`AsyncData(null)` veya hata — güvenli varsayılan
///   olarak unauthenticated sayılır) → korumalı rotaya erişim denemesi
///   Welcome'a yönlendirilir.
/// - `authenticated` → public rotaya erişim denemesi Dashboard'a yönlendirilir.
///
/// Splash özel bir durumdur: `checking` dışında asla geçerli bir "kalınacak
/// yer" değildir, durum netleşir netleşmez her zaman Welcome veya
/// Dashboard'a yönlendirilir (SCREENS.md §4.1).
String? authGuardRedirect({
  required AsyncValue<AppUser?> authState,
  required String location,
}) {
  if (authState.isLoading) return null;

  final isAuthenticated = authState.valueOrNull != null;
  final isSplash = location == RoutePaths.splash;
  final isPublic = _publicRoutes.contains(location);

  if (isSplash) {
    return isAuthenticated ? RoutePaths.dashboard : RoutePaths.welcome;
  }
  if (!isAuthenticated && !isPublic) return RoutePaths.welcome;
  if (isAuthenticated && isPublic) return RoutePaths.dashboard;
  return null;
}

const _publicRoutes = {
  RoutePaths.splash,
  RoutePaths.welcome,
  RoutePaths.login,
  RoutePaths.register,
  RoutePaths.forgotPassword,
};
