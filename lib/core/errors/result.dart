import 'failure.dart';

/// UseCase dönüş sözleşmesi — ARCHITECTURE.md Bölüm 7.3.
///
/// UseCase'ler başarı/hata durumunu exception fırlatarak değil, bu açık
/// sarmalayıcı tip üzerinden ifade eder; Presentation katmanı hata
/// yönetimini try-catch yerine deterministik, tip-güvenli pattern matching
/// ile yapar (Dart 3 sealed class + switch). Riverpod'un `AsyncValue`
/// (data/loading/error) yapısıyla doğal olarak uyumludur.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
