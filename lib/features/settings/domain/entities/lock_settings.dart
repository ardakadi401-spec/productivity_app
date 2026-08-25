/// ARCHITECTURE.md §13.3-13.4, SCREENS.md §4.22 "kilit türünü (PIN/Biyometri/
/// İkisi/Yok) ayarlama". PIN'in kendisi (düz metin veya hash'i) bu entity'de
/// TAŞINMAZ — yalnızca "PIN ayarlanmış mı" bilgisi (`hasPinSet`) dışa açılır,
/// gerçek hash `LockRepository` implementasyonunun içinde (güvenli
/// depolamada) kalır.
enum LockMethod { none, pin, biometric, both }

class LockSettings {
  const LockSettings({required this.method, required this.hasPinSet});

  static const disabled = LockSettings(method: LockMethod.none, hasPinSet: false);

  final LockMethod method;
  final bool hasPinSet;

  bool get isEnabled => method != LockMethod.none;
  bool get requiresPin => method == LockMethod.pin || method == LockMethod.both;
  bool get requiresBiometric => method == LockMethod.biometric || method == LockMethod.both;

  LockSettings copyWith({LockMethod? method, bool? hasPinSet}) {
    return LockSettings(
      method: method ?? this.method,
      hasPinSet: hasPinSet ?? this.hasPinSet,
    );
  }
}
