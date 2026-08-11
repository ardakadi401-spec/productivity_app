import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../providers/auth_providers.dart';

/// STATE_MANAGEMENT.md Bölüm 4.2 — ekran bazlı, `autoDispose`. Başarı
/// durumunda navigasyonu Router'ın Auth Guard'ı (authStateProvider'ı
/// izleyerek) otomatik yapar; bu controller yalnızca loading/error UI
/// durumunu taşır.
class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithEmail({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithEmailUseCaseProvider)(email: email, password: password);
    state = switch (result) {
      Ok() => const AsyncData(null),
      Err(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Kullanıcı Google akışını iptal ederse (`Ok(null)`) sessizce başarı
  /// durumuna döner — hata gösterilmez (ROADMAP.md FAZ 3 test kriteri).
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithGoogleUseCaseProvider)();
    state = switch (result) {
      Ok() => const AsyncData(null),
      Err(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(LoginController.new);
