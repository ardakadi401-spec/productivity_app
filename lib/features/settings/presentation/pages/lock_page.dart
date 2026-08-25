import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../domain/entities/lock_settings.dart';
import '../providers/lock_providers.dart';

/// PRD §5.7 Güvenlik Kilidi Akışı — kilit türü biyometrik/ikisi ise girişte
/// otomatik biyometrik prompt denenir; başarısız/iptal/desteklenmiyorsa
/// sessizce PIN alanına düşülür (ARCHITECTURE.md §13.4 fallback). Ekran,
/// başarılı doğrulama olmadan kapatılamaz (`PopScope(canPop: false)`) —
/// zorunlu kilit (ARCHITECTURE.md §13.5).
class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  final _pinController = TextEditingController();
  String? _errorText;
  bool _isVerifying = false;
  bool _biometricAttempted = false;

  /// Saf biyometrik modda (yalnızca `LockMethod.biometric`) biyometrik
  /// doğrulama başarısız/iptal/kullanılamaz olursa PIN alanına düşmek için
  /// (ARCHITECTURE.md §13.4) — `SetLockMethodUseCase` artık `biometric`
  /// seçilirken de bir PIN'in önceden ayarlanmış olmasını zorunlu kıldığı
  /// için bu her zaman güvenli bir fallback'tir (`PopScope(canPop:false)`
  /// nedeniyle bu olmadan kullanıcı ekranda sıkışıp kalırdı).
  bool _biometricFailed = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeTryBiometricOnEntry());
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _maybeTryBiometricOnEntry() async {
    if (_biometricAttempted) return;
    // `.valueOrNull` DEĞİL — StreamProvider'ın ilk değeri (özellikle gerçek
    // güvenli depolama I/O'su nedeniyle) bir sonraki frame'e kadar
    // gelmeyebilir; `.future` ilk değeri güvenilir şekilde bekler.
    final LockSettings settings;
    try {
      settings = await ref.read(lockSettingsProvider.future);
    } catch (_) {
      return;
    }
    if (!mounted || !settings.requiresBiometric) return;
    _biometricAttempted = true;
    await _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final result = await ref.read(authenticateWithBiometricUseCaseProvider).call();
    if (!mounted) return;
    if (result case Ok(value: true)) {
      _unlock();
      return;
    }
    // `false`/hata → PIN alanına düşülür (aşağıdaki `_biometricFailed`),
    // ek bir hata gösterilmez (kullanıcı biyometriği iptal etmiş veya
    // kullanılamıyor olabilir) — yalnızca sessizce PIN'e geçilir.
    setState(() => _biometricFailed = true);
  }

  void _unlock() {
    ref.read(appLockStateProvider.notifier).state = false;
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text;
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    final result = await ref.read(verifyPinUseCaseProvider).call(pin);
    if (!mounted) return;

    switch (result) {
      case Ok(value: true):
        // `_isVerifying` yine de sıfırlanır: üretimde router bu widget'ı
        // hemen kaldırır, ama navigasyon bir frame gecikirse (veya bu ekran
        // izole test edilirse) buton sonsuza dek spinner'da kalmamalı.
        setState(() => _isVerifying = false);
        _unlock();
      case Ok(value: false):
        setState(() {
          _isVerifying = false;
          _errorText = 'Yanlış PIN, tekrar dene.';
        });
        _pinController.clear();
      case Err(:final failure):
        setState(() {
          _isVerifying = false;
          _errorText = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final settings = ref.watch(lockSettingsProvider).valueOrNull;
    // Saf biyometrik modda, biyometrik başarısız olana kadar PIN alanı
    // gizlenir; başarısız olduğunda (`_biometricFailed`) PIN'e düşülür.
    final showPin = (settings?.requiresPin ?? true) ||
        (settings?.requiresBiometric == true && _biometricFailed);
    final showBiometric = settings?.requiresBiometric ?? false;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Kilitli',
                  textAlign: TextAlign.center,
                  style: AppTypography.display.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Devam etmek için kimliğini doğrula',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (showPin) ...[
                  AppTextField(
                    label: 'PIN',
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    errorText: _errorText,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Aç',
                    isFullWidth: true,
                    isLoading: _isVerifying,
                    onPressed: _pinController.text.isEmpty ? null : _verifyPin,
                  ),
                ],
                if (showBiometric) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Biyometrik ile Aç',
                    variant: AppButtonVariant.outline,
                    isFullWidth: true,
                    onPressed: _tryBiometric,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
