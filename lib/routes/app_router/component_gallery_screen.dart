import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_elevation.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_mode.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../shared/buttons/app_button_widget.dart';
import '../../shared/dialogs/app_bottom_sheet.dart';
import '../../shared/dialogs/app_dialog.dart';
import '../../shared/forms/app_text_field_widget.dart';
import '../../shared/loaders/loading_skeleton_widget.dart';
import '../../shared/widgets/app_snackbar_widget.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_state_widget.dart';

/// FAZ 2 doğrulama ekranı — geçici/dahili, 23 resmi ekranın dışında.
///
/// Tüm shared component'lerin Light/Dark/AMOLED'de bağımsız olarak
/// çalıştığını görsel olarak doğrulamak için var (ROADMAP.md FAZ 2
/// tamamlanma kriteri: "bir örnek sayfada gösterilebiliyor"). FAZ 3'ten
/// itibaren ayrıca geçici bir "Çıkış Yap" tetikleyicisi barındırır (bkz.
/// Authentication bölümü). FAZ 4'ten itibaren tema seçici, Settings
/// ekranıyla aynı gerçek `themeModeProvider`'ı kullanır (kendi geçici
/// `ValueNotifier`'ı kaldırıldı). FAZ 4 sonunda gerçek ekranlar
/// tamamlandığından bu ekranın kaldırılması değerlendirilecek.
class ComponentGalleryScreen extends ConsumerStatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  ConsumerState<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends ConsumerState<ComponentGalleryScreen> {
  bool _textError = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Gallery (FAZ 2)'),
        actions: [
          PopupMenuButton<AppThemeMode>(
            initialValue: mode,
            onSelected: (m) => ref.read(themeModeProvider.notifier).setMode(m),
            itemBuilder: (context) => const [
              PopupMenuItem(value: AppThemeMode.system, child: Text('System')),
              PopupMenuItem(value: AppThemeMode.light, child: Text('Light')),
              PopupMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
              PopupMenuItem(value: AppThemeMode.amoled, child: Text('AMOLED')),
            ],
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
                _SectionHeader('Authentication (FAZ 3 doğrulama)'),
                // ROADMAP.md FAZ 3 tamamlanma kriteri: "Oturum kapatıldığında
                // kullanıcı otomatik olarak Welcome'a yönlendiriliyor" —
                // gerçek Settings ekranı gelene kadar (FAZ 4+/16) çıkış
                // yapmayı test edebilmek için geçici tetikleyici.
                Consumer(
                  builder: (context, ref, _) {
                    final authState = ref.watch(authStateProvider);
                    final isSignedIn = authState.valueOrNull != null;
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            authState.when(
                              loading: () => 'Oturum kontrol ediliyor...',
                              error: (_, _) => 'Oturum hatası',
                              data: (user) =>
                                  user == null ? 'Oturum yok' : 'Oturum açık: ${user.email}',
                            ),
                            style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
                          ),
                        ),
                        AppButton(
                          label: 'Çıkış Yap',
                          variant: AppButtonVariant.outline,
                          onPressed: isSignedIn
                              ? () => ref.read(signOutUseCaseProvider)()
                              : null,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader('Buttons'),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppButton(label: 'Primary', onPressed: () {}),
                    AppButton(label: 'Secondary', variant: AppButtonVariant.secondary, onPressed: () {}),
                    AppButton(label: 'Outline', variant: AppButtonVariant.outline, onPressed: () {}),
                    AppButton(label: 'Text', variant: AppButtonVariant.text, onPressed: () {}),
                    AppButton(label: 'Destructive', isDestructive: true, onPressed: () {}),
                    const AppButton(label: 'Disabled', onPressed: null),
                    AppButton(label: 'Loading', isLoading: true, onPressed: () {}),
                    AppIconButton(icon: Icons.favorite_border, semanticLabel: 'Favori', onPressed: () {}),
                    AppFabButton(icon: Icons.add, semanticLabel: 'Ekle', onPressed: () {}),
                    AppFabButton(icon: Icons.add, semanticLabel: 'Ekle', mini: true, onPressed: () {}),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader('Text Field'),
                AppTextField(
                  label: 'E-posta',
                  hintText: 'ornek@eposta.com',
                  errorText: _textError ? 'Geçerli bir e-posta girin' : null,
                  onChanged: (v) => setState(() => _textError = v.isNotEmpty && !v.contains('@')),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader('Loading Skeleton'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    LoadingSkeleton(width: 160, height: 20),
                    SizedBox(height: AppSpacing.xs),
                    LoadingSkeleton(width: 240, height: 14),
                    SizedBox(height: AppSpacing.xs),
                    LoadingSkeleton(height: 64, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader('Empty / Error State'),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: mode == AppThemeMode.amoled ? AppElevation.none : AppElevation.level1(),
                    border: mode == AppThemeMode.amoled ? Border.all(color: tokens.border) : null,
                  ),
                  child: EmptyState(
                    icon: Icons.check_circle_outline,
                    message: 'Henüz alışkanlık eklemedin',
                    actionLabel: 'Alışkanlık Ekle',
                    onAction: () {},
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: mode == AppThemeMode.amoled ? AppElevation.none : AppElevation.level1(),
                    border: mode == AppThemeMode.amoled ? Border.all(color: tokens.border) : null,
                  ),
                  child: ErrorState(
                    message: 'Görevler yüklenemedi. Bağlantını kontrol edip tekrar dene.',
                    onRetry: () {},
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader('Snackbar / Dialog / Bottom Sheet'),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppButton(
                      label: 'Snackbar',
                      variant: AppButtonVariant.outline,
                      onPressed: () => AppSnackbar.show(
                        context,
                        message: 'Görev silindi',
                        actionLabel: 'Geri Al',
                        onAction: () {},
                      ),
                    ),
                    AppButton(
                      label: 'Success Snackbar',
                      variant: AppButtonVariant.outline,
                      onPressed: () => AppSnackbar.show(
                        context,
                        message: 'Değişiklikler kaydedildi',
                        isSuccess: true,
                      ),
                    ),
                    AppButton(
                      label: 'Dialog',
                      variant: AppButtonVariant.outline,
                      onPressed: () => AppDialog.show(
                        context,
                        title: 'Hesabı sil',
                        description: 'Bu işlem geri alınamaz. Devam etmek istiyor musun?',
                        confirmLabel: 'Sil',
                        isDestructive: true,
                      ),
                    ),
                    AppButton(
                      label: 'Bottom Sheet',
                      variant: AppButtonVariant.outline,
                      onPressed: () => AppBottomSheet.show(
                        context,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Hızlı ekleme paneli örneği',
                            style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.h3.copyWith(color: tokens.textSecondary),
      ),
    );
  }
}
