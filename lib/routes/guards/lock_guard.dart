import '../route_paths/route_paths.dart';

/// ARCHITECTURE.md §13.5 / PRD §5.7 — "uygulama arka plana alınıp geri
/// dönüldüğünde kilit ekranı zorunlu kılınır." Auth Guard ile birebir aynı
/// desen: saf, test edilebilir yönlendirme fonksiyonu.
///
/// `isLocked`, `app.dart`'taki `appLockStateProvider`'ın anlık değeridir —
/// bu fonksiyonun kendisi HİÇBİR zamanlama/lifecycle kararı vermez, yalnızca
/// "şu an kilitliyken kilit ekranından başka bir yerde miyim" sorusuna
/// yanıt verir. Kimliği doğrulanmamış kullanıcılar için kilit anlamsızdır
/// (Auth Guard zaten onları Welcome'a yönlendirir) — bu yüzden `false`
/// döner, kararı Auth Guard'a bırakır.
String? lockGuardRedirect({
  required bool isLocked,
  required bool isAuthenticated,
  required String location,
}) {
  if (!isAuthenticated) return null;

  final isLockScreen = location == RoutePaths.lock;
  if (isLocked && !isLockScreen) return RoutePaths.lock;
  if (!isLocked && isLockScreen) return RoutePaths.dashboard;
  return null;
}
