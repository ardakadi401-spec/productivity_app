import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../../../shared/components/sync_status_indicator_widget.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../domain/entities/lock_settings.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/pomodoro_duration_settings.dart';
import '../providers/lock_providers.dart';
import '../providers/settings_providers.dart';

/// Settings Screen iskeleti — ROADMAP.md FAZ 4: tema seçimi bu fazda
/// gerçek işlevle bağlanır (Core Theme altyapısına bağımlı olduğu için
/// erken bağlanabilir); bildirim tercihleri ve PIN/Biyometri ayarları
/// ilgili fazlarda (FAZ 13, FAZ 15) doldurulur.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final mode = ref.watch(themeModeProvider);
    final isAmoled = mode == AppThemeMode.amoled;

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(title: 'Ayarlar', isAmoled: isAmoled),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _SectionLabel('Tema'),
                // Dış Container yalnızca border çizer (rengi yok) — ListTile'ın
                // ripple/seçim efektleri en yakın Material atasında (aşağıdaki
                // Material widget'ında) boyandığından, opak bir DecoratedBox
                // bu efektleri gizlemez (Flutter'ın kendi uyarısı).
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: theme.colorScheme.surface,
                    child: RadioGroup<AppThemeMode>(
                      groupValue: mode,
                      onChanged: (value) =>
                          ref.read(themeModeProvider.notifier).setMode(value!),
                      child: Column(
                        children: [
                          for (final entry in const {
                            AppThemeMode.system: 'Sistem',
                            AppThemeMode.light: 'Açık',
                            AppThemeMode.dark: 'Koyu',
                            AppThemeMode.amoled: 'AMOLED',
                          }.entries)
                            RadioListTile<AppThemeMode>(
                              value: entry.key,
                              title: Text(
                                entry.value,
                                style: AppTypography.bodyLg.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              activeColor: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Hesap'),
                _SettingsTile(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  onTap: () => context.push(RoutePaths.profile),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _SignOutTile(),
                const SizedBox(height: AppSpacing.sm),
                const _DeleteAccountTile(),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Bildirimler'),
                const _NotificationsSection(),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Pomodoro'),
                const _PomodoroDurationSection(),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Senkronizasyon'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.border),
                  ),
                  child: const SyncStatusIndicatorWidget(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Güvenlik'),
                const _SecuritySection(),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Şifre Kasası'),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: theme.colorScheme.surface,
                    child: _SettingsTile(
                      icon: Icons.lock_outline,
                      label: 'Şifrelerim ve Notlarım',
                      onTap: () => context.push(RoutePaths.vault),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
        left: AppSpacing.xs,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: tokens.textSecondary),
      ),
    );
  }
}

/// SCREENS.md §4.22/§6.7 "Bildirimler bölümü → Genel bildirim anahtarı +
/// tür bazlı tercihler". Genel anahtar kapalıyken tür bazlı anahtarlar
/// görsel olarak devre dışı bırakılır (kullanıcı kararı: genel kapalıysa
/// hiçbir tür planlanmaz — bu, `NotificationPreferences.tasksAllowed` vb.
/// getter'larının UI'daki yansıması).
class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final preferencesAsync = ref.watch(notificationPreferencesProvider);
    final preferences =
        preferencesAsync.valueOrNull ?? NotificationPreferences.defaults;
    // ROADMAP.md FAZ 13 test noktası — "Bildirim izni sonradan (Ayarlar
    // üzerinden) iptal edildiğinde uygulama bunu algılayıp kullanıcıyı
    // bilgilendiriyor mu?" Tercih içeride açık AMA OS izni artık kapalıysa
    // (kullanıcı sistem ayarlarından iptal etmişse) uyarı gösterilir.
    final osEnabled =
        ref.watch(osNotificationsEnabledProvider).valueOrNull ?? true;
    final showOsPermissionWarning =
        preferences.notificationsEnabled && !osEnabled;

    Future<void> update(NotificationPreferences updated) async {
      final result = await ref
          .read(updateNotificationPreferencesUseCaseProvider)
          .call(updated);
      if (!context.mounted) return;
      if (result case Err(:final failure)) {
        AppSnackbar.show(context, message: failure.message);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showOsPermissionWarning) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Bildirim izni sistem ayarlarından kapatılmış — hatırlatmalar gösterilmeyecek.',
                    style: AppTypography.bodyMd.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Bildirimleri Etkinleştir',
                    style: AppTypography.bodyLg.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Kapatılırsa hiçbir görev/alışkanlık/pomodoro bildirimi planlanmaz',
                    style: AppTypography.caption.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  value: preferences.notificationsEnabled,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (value) async {
                    if (value) {
                      final granted = await ref
                          .read(requestNotificationPermissionUseCaseProvider)
                          .call();
                      if (!context.mounted) return;
                      if (!granted) {
                        AppSnackbar.show(
                          context,
                          message:
                              'Bildirim izni verilmedi — sistem ayarlarından izin vermeden bildirimler gösterilemez.',
                        );
                      }
                    }
                    await update(
                      preferences.copyWith(notificationsEnabled: value),
                    );
                  },
                ),
                const Divider(height: 1),
                _NotificationTypeTile(
                  label: 'Görev Hatırlatmaları',
                  value: preferences.taskRemindersEnabled,
                  enabled: preferences.notificationsEnabled,
                  onChanged: (value) =>
                      update(preferences.copyWith(taskRemindersEnabled: value)),
                ),
                _NotificationTypeTile(
                  label: 'Alışkanlık Hatırlatmaları',
                  value: preferences.habitRemindersEnabled,
                  enabled: preferences.notificationsEnabled,
                  onChanged: (value) => update(
                    preferences.copyWith(habitRemindersEnabled: value),
                  ),
                ),
                _NotificationTypeTile(
                  label: 'Pomodoro Bildirimleri',
                  value: preferences.pomodoroNotificationsEnabled,
                  enabled: preferences.notificationsEnabled,
                  onChanged: (value) => update(
                    preferences.copyWith(pomodoroNotificationsEnabled: value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Yeni bir Pomodoro oturumu başlatıldığında kullanılacak varsayılan
/// çalışma/mola sürelerini yapılandırır (DATABASE.md §2.3
/// `pomodoroWorkDuration`/`pomodoroBreakDuration` — daha önce hiç UI'dan
/// erişilebilir değildi, yalnızca kayıt sırasında Firestore'a yazılan ama
/// hiç okunmayan "yetim" varsayılanlardı). Pomodoro Screen'deki
/// `_DurationPresets` ile KARIŞTIRILMAMALI — o, yalnızca o anki oturum için
/// geçici bir geçersiz kılmadır; buradaki değişiklik kalıcıdır ve yalnızca
/// SONRAKİ yeni oturumları etkiler.
class _PomodoroDurationSection extends ConsumerWidget {
  const _PomodoroDurationSection();

  static const _workPresets = [15, 25, 45, 60];
  static const _breakPresets = [5, 10, 15];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final settings =
        ref.watch(pomodoroDurationSettingsProvider).valueOrNull ?? PomodoroDurationSettings.defaults;

    Future<void> update(PomodoroDurationSettings updated) async {
      final result = await ref.read(updatePomodoroDurationSettingsUseCaseProvider).call(updated);
      if (!context.mounted) return;
      if (result case Err(:final failure)) {
        AppSnackbar.show(context, message: failure.message);
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Çalışma Süresi (dk)',
            style: AppTypography.caption.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final minutes in _workPresets)
                AppChip(
                  label: '$minutes',
                  selected: settings.workMinutes == minutes,
                  onTap: () => update(settings.copyWith(workMinutes: minutes)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Mola Süresi (dk)',
            style: AppTypography.caption.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final minutes in _breakPresets)
                AppChip(
                  label: '$minutes',
                  selected: settings.breakMinutes == minutes,
                  onTap: () => update(settings.copyWith(breakMinutes: minutes)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationTypeTile extends StatelessWidget {
  const _NotificationTypeTile({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SwitchListTile(
        title: Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        value: value,
        activeThumbColor: theme.colorScheme.primary,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    return ListTile(
      leading: Icon(icon, color: tokens.textSecondary),
      title: Text(
        label,
        style: AppTypography.bodyLg.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: tokens.textSecondary),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}

/// PRD §6.15 / SCREENS.md §4.22 — "kilit türünü (PIN/Biyometri/İkisi/Yok)
/// ayarlama". Biyometri desteklenmeyen cihazlarda `biometric`/`both`
/// seçenekleri listeden bilerek çıkarılır (ARCHITECTURE.md §13.4).
class _SecuritySection extends ConsumerWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final lockSettings =
        ref.watch(lockSettingsProvider).valueOrNull ?? LockSettings.disabled;
    final biometricAvailable =
        ref.watch(biometricAvailableProvider).valueOrNull ?? false;

    Future<void> applyFailure(Result<void> result) async {
      if (!context.mounted) return;
      if (result case Err(:final failure)) {
        AppSnackbar.show(context, message: failure.message);
      }
    }

    Future<void> selectMethod(LockMethod method) async {
      // `biometric` de PIN gerektirir (ARCHITECTURE.md §13.4 fallback kuralı
      // — bkz. `SetLockMethodUseCase`) — biyometrik başarısız olduğunda
      // düşülecek bir PIN her zaman var olmalı.
      final needsPinFirst =
          method != LockMethod.none && !lockSettings.hasPinSet;
      if (needsPinFirst) {
        final pinWasSet = await showDialog<bool>(
          context: context,
          builder: (_) => const _PinSetupDialog(),
        );
        if (pinWasSet != true || !context.mounted) return;
      }

      if (method == LockMethod.none) {
        await applyFailure(await ref.read(disableLockUseCaseProvider).call());
      } else {
        await applyFailure(
          await ref.read(setLockMethodUseCaseProvider).call(method),
        );
      }
    }

    final options = <LockMethod, String>{
      LockMethod.none: 'Yok',
      LockMethod.pin: 'PIN',
      if (biometricAvailable) LockMethod.biometric: 'Biyometri',
      if (biometricAvailable) LockMethod.both: 'İkisi',
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: theme.colorScheme.surface,
        child: RadioGroup<LockMethod>(
          groupValue: lockSettings.method,
          onChanged: (value) {
            if (value != null) unawaited(selectMethod(value));
          },
          child: Column(
            children: [
              for (final entry in options.entries)
                RadioListTile<LockMethod>(
                  value: entry.key,
                  title: Text(
                    entry.value,
                    style: AppTypography.bodyLg.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  activeColor: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `SignOutUseCase` FAZ 3'te hazırlanmıştı ama gerçek bir ekrandan hiç
/// erişilebilir değildi (yalnızca `component_gallery_screen.dart`'taki
/// geliştirici demo ekranında kullanılıyordu). Başarılı çıkış sonrası
/// `authStateProvider` `null` yayınlar ve Auth Guard kullanıcıyı otomatik
/// Welcome'a yönlendirir (bkz. `auth_guard.dart`, `_DeleteAccountTile` ile
/// aynı desen) — burada manuel navigasyon gerekmez.
class _SignOutTile extends ConsumerStatefulWidget {
  const _SignOutTile();

  @override
  ConsumerState<_SignOutTile> createState() => _SignOutTileState();
}

class _SignOutTileState extends ConsumerState<_SignOutTile> {
  bool _isSigningOut = false;

  Future<void> _confirmAndSignOut() async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Çıkış Yap',
      description: 'Hesabından çıkış yapmak istediğine emin misin?',
      confirmLabel: 'Çıkış Yap',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);
    final result = await ref.read(signOutUseCaseProvider).call();
    if (!mounted) return;

    if (result case Err(:final failure)) {
      setState(() => _isSigningOut = false);
      AppSnackbar.show(context, message: failure.message);
    }
    // Ok() durumunda widget zaten Auth Guard'ın yönlendirmesiyle
    // kaldırılacağından `_isSigningOut`'u sıfırlamaya gerek yok.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    return ListTile(
      leading: Icon(Icons.logout, color: tokens.textSecondary),
      title: Text(
        'Çıkış Yap',
        style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.onSurface),
      ),
      trailing: _isSigningOut
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right, color: tokens.textSecondary),
      onTap: _isSigningOut ? null : _confirmAndSignOut,
    );
  }
}

/// PRD Bölüm 6.1 / Play Store politikası gereği zorunlu hesap silme akışı —
/// `DeleteAccountUseCase` FAZ 3'te hazırlanmıştı, bu tile onu ilk kez gerçek
/// bir ekrandan erişilebilir kılar. Başarılı silme sonrası `authStateProvider`
/// `null` yayınlar ve Auth Guard kullanıcıyı otomatik Welcome'a yönlendirir
/// (bkz. `auth_guard.dart`) — burada manuel navigasyon gerekmez.
class _DeleteAccountTile extends ConsumerStatefulWidget {
  const _DeleteAccountTile();

  @override
  ConsumerState<_DeleteAccountTile> createState() => _DeleteAccountTileState();
}

class _DeleteAccountTileState extends ConsumerState<_DeleteAccountTile> {
  bool _isDeleting = false;

  Future<void> _confirmAndDelete() async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Hesabı Sil',
      description:
          'Hesabın ve tüm verilerin (görevler, projeler, notlar, alışkanlıklar ve diğer tüm '
          'kişisel verilerin) kalıcı olarak silinecek. Bu işlem geri alınamaz.',
      confirmLabel: 'Hesabı Sil',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final result = await ref.read(deleteAccountUseCaseProvider).call();
    if (!mounted) return;

    if (result case Err(:final failure)) {
      setState(() => _isDeleting = false);
      AppSnackbar.show(context, message: failure.message);
    }
    // Ok() durumunda widget zaten Auth Guard'ın yönlendirmesiyle
    // kaldırılacağından `_isDeleting`'i sıfırlamaya gerek yok.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.delete_forever_outlined,
        color: theme.colorScheme.error,
      ),
      title: Text(
        'Hesabı Sil',
        style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.error),
      ),
      trailing: _isDeleting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right, color: theme.colorScheme.error),
      onTap: _isDeleting ? null : _confirmAndDelete,
    );
  }
}

/// "PIN" veya "İkisi" ilk kez seçildiğinde gösterilir — `SetPinUseCase`
/// (min 4 haneli rakam) ile PIN'i güvenli şekilde kaydeder. `true` ile
/// kapanırsa çağıran `SetLockMethodUseCase`'i devam ettirir.
class _PinSetupDialog extends ConsumerStatefulWidget {
  const _PinSetupDialog();

  @override
  ConsumerState<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends ConsumerState<_PinSetupDialog> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _isSaving = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text;
    if (pin != _confirmController.text) {
      setState(() => _error = 'PIN\'ler eşleşmiyor.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final result = await ref.read(setPinUseCaseProvider).call(pin);
    if (!mounted) return;

    switch (result) {
      case Ok():
        Navigator.of(context).pop(true);
      case Err(:final failure):
        setState(() {
          _isSaving = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PIN Belirle',
                style: AppTypography.h2.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'PIN',
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'PIN Tekrar',
                controller: _confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                errorText: _error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Vazgeç',
                    variant: AppButtonVariant.text,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'Kaydet',
                    isLoading: _isSaving,
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
