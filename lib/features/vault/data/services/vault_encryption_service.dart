import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/exceptions/app_exceptions.dart';

/// Kasa alanlarının (`password`, `notes`) hesaba özgü bir anahtarla AES-256-GCM
/// ile şifrelenmesini sağlar.
///
/// Anahtar HİÇBİR YERDE saklanmaz/senkronlanmaz — her cihazda aynı Firebase
/// hesabından (`uid`) ve uygulamaya gömülü sabit bir "pepper"dan SHA-256 ile
/// YENİDEN TÜRETİLİR (deterministik KDF). Böylece aynı hesapla giriş yapılan
/// her cihaz, anahtarı hiç senkronlamadan bağımsızca aynı sonuca ulaşır —
/// Firestore'a yalnızca şifreli metin gider (kullanıcının açık isteği: kasa
/// kayıtları hesap genelinde senkronlansın).
///
/// NOT: Bu uçtan uca sıfır-bilgi (zero-knowledge) bir tasarım DEĞİLDİR —
/// pepper uygulama ikili dosyasının içindedir, sunucu tarafı bir yetkili
/// (ör. Firestore'a doğrudan erişimi olan biri) prensipte anahtarı yeniden
/// türetebilir. Kişisel/tek kullanıcılı bir üretkenlik uygulaması için kabul
/// edilebilir bir güvenlik/karmaşıklık dengesidir; kullanıcının ayrıca
/// hatırlaması gereken bir "ana şifre" (master password) tasarımı BİLİNÇLİ
/// OLARAK tercih edilmedi — unutulursa TÜM kasa kalıcı olarak okunamaz hale
/// gelirdi, bu ölçekte orantısız bir risk.
class VaultEncryptionService {
  VaultEncryptionService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const _pepper = 'productivity_app.vault.v1';

  enc.Encrypter _encrypterFor(String uid) {
    final keyBytes = Uint8List.fromList(sha256.convert(utf8.encode('$uid:$_pepper')).bytes);
    return enc.Encrypter(enc.AES(enc.Key(keyBytes), mode: enc.AESMode.gcm));
  }

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('user-not-authenticated');
    return uid;
  }

  /// `base64(iv):base64(şifreli metin+tag)` biçiminde döner — her çağrıda
  /// rastgele bir IV (nonce) üretilir, aynı düz metin her seferinde farklı
  /// şifreli metin üretir.
  String encrypt(String plainText) {
    final encrypter = _encrypterFor(_uid);
    final iv = enc.IV.fromSecureRandom(12);
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decrypt(String cipherText) {
    final parts = cipherText.split(':');
    if (parts.length != 2) throw const CacheException('Kasa kaydı çözülemedi.');
    try {
      final encrypter = _encrypterFor(_uid);
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
