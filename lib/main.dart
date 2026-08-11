import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'config/firebase_config/firebase_options.dart';
import 'core/storage/isar_provider.dart';
import 'services/database_service/isar_service.dart';

/// Uygulama giriş noktası — FOLDER_STRUCTURE.md Bölüm 1'e göre minimal
/// tutulur; kök widget kurulumu `app/app.dart`'a devredilir.
///
/// `ProviderScope`, tüm Riverpod provider ağacının köküdür (FAZ 1.5).
/// Bu noktadan itibaren, ARCHITECTURE.md Bölüm 5'teki provider tipi karar
/// kriterleri proje genelinde bağlayıcı kuraldır:
///   - Değişmeyen bağımlılık (repository/usecase/service)  → `Provider`
///   - Tek seferlik asenkron okuma                          → `FutureProvider`
///   - Sürekli/canlı veri kaynağı (auth, sync durumu)        → `StreamProvider`
///   - Çok adımlı senkron kullanıcı etkileşimi                → `NotifierProvider`
///   - Asenkron başlangıçlı, sonradan etkileşimle değişen    → `AsyncNotifierProvider`
/// Provider'ların katmanlara göre gruplanması (Data/Domain/Presentation)
/// ve dosya konumları ARCHITECTURE.md Bölüm 5.2 ile FOLDER_STRUCTURE.md
/// Bölüm 13'te tanımlıdır; bu faz henüz hiçbir feature provider'ı
/// oluşturmaz — yalnızca kök scope kurulur.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final isar = await IsarService.open();
  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const ProductivityApp(),
    ),
  );
}
