import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';

/// Welcome Screen — SCREENS.md §4.2. Splash'ten `unauthenticated` sonucu ile
/// veya oturum kapatıldığında buraya gelinir.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.check_circle_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Productivity App',
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Görevlerini, alışkanlıklarını ve zamanını tek yerden yönet.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg.copyWith(color: tokens.textSecondary),
              ),
              const Spacer(flex: 3),
              AppButton(
                label: 'Giriş Yap',
                isFullWidth: true,
                onPressed: () => context.go(RoutePaths.login),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Kayıt Ol',
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                onPressed: () => context.go(RoutePaths.register),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
