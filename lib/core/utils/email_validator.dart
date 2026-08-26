/// Basit e-posta biçim doğrulaması — Login, Register ve Şifremi Unuttum
/// ekranlarının üçünde de aynı denetim gerektiğinden `core/utils/`'te
/// (bkz. `DateFormatter` ile aynı gerekçe/desen).
class EmailValidator {
  EmailValidator._();

  static final _regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValid(String email) => _regex.hasMatch(email);
}
