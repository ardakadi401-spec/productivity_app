import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/components/app_top_bar.dart';

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
                                style: AppTypography.bodyLg
                                    .copyWith(color: theme.colorScheme.onSurface),
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
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Diğer'),
                const _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Bildirimler',
                  trailing: 'Yakında (FAZ 13)',
                ),
                const _SettingsTile(
                  icon: Icons.lock_outline,
                  label: 'Uygulama Kilidi',
                  trailing: 'Yakında (FAZ 15)',
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xs),
      child: Text(text, style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, this.onTap, this.trailing});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    return ListTile(
      leading: Icon(icon, color: tokens.textSecondary),
      title: Text(label, style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.onSurface)),
      trailing: trailing != null
          ? Text(trailing!, style: AppTypography.caption.copyWith(color: tokens.textDisabled))
          : Icon(Icons.chevron_right, color: tokens.textSecondary),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}
