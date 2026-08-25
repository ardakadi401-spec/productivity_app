import 'package:local_auth/local_auth.dart';

/// `local_auth` SDK'sını sarmalar — ARCHITECTURE.md §13.4: "uygulama
/// biyometrik veriye hiçbir şekilde erişmez, yalnızca platformdan
/// doğrulandı/doğrulanmadı sonucunu alır." Her iki metot da BİLİNÇLİ olarak
/// hiçbir istisna fırlatmaz (iptal, kilitli donanım, desteklenmeyen cihaz
/// hepsi `false` olarak sessizce ele alınır) — çağıran Repository bu yüzden
/// PIN fallback'ine geçmek için özel bir hata dalına ihtiyaç duymaz.
class BiometricDatasource {
  BiometricDatasource({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Kimliğini doğrula',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
