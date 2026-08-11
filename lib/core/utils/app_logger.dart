import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Merkezi loglama mekanizması — ROADMAP.md FAZ 2. Debug'da tüm seviyeler
/// konsola yazılır; release'de yalnızca [warning]/[error] yazılır (gürültüyü
/// azaltmak için — gerçek bir crash-reporting servisine bağlama FAZ 17'nin
/// kapsamındadır, bu yalnızca yerel/konsol loglamadır).
class AppLogger {
  AppLogger._();

  static void debug(String message, {String name = 'app'}) {
    if (kDebugMode) {
      developer.log(message, name: name, level: 500);
    }
  }

  static void info(String message, {String name = 'app'}) {
    if (kDebugMode) {
      developer.log(message, name: name, level: 800);
    }
  }

  static void warning(String message, {String name = 'app'}) {
    developer.log(message, name: name, level: 900);
  }

  static void error(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
