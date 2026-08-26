import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/email_validator.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../controllers/login_controller.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_text_field.dart';

/// Login Screen — SCREENS.md §4.3.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = EmailValidator.isValid(_emailController.text.trim())
          ? null
          : 'Geçerli bir e-posta adresi gir.';
      _passwordError = _passwordController.text.isEmpty ? 'Şifreni gir.' : null;
    });
    return _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final isLoading = ref.watch(loginControllerProvider).isLoading;

    ref.listen(loginControllerProvider, (previous, next) {
      if (next is AsyncError) {
        final failure = next.error;
        final message = failure is Failure ? failure.message : 'Bir şeyler ters gitti. Lütfen tekrar dene.';
        AppSnackbar.show(context, message: message);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giriş Yap', style: AppTypography.h1.copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: AppSpacing.lg),
              GoogleSignInButton(
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () => ref.read(loginControllerProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: Divider(color: tokens.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('veya', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
                  ),
                  Expanded(child: Divider(color: tokens.border)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'E-posta',
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                hintText: 'ornek@eposta.com',
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordTextField(
                label: 'Şifre',
                controller: _passwordController,
                errorText: _passwordError,
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: 'Şifremi Unuttum',
                  variant: AppButtonVariant.text,
                  onPressed: () => context.push(RoutePaths.forgotPassword),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Giriş Yap',
                isFullWidth: true,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () {
                        if (!_validate()) return;
                        ref.read(loginControllerProvider.notifier).signInWithEmail(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: AppButton(
                  label: 'Hesabın yok mu? Kayıt Ol',
                  variant: AppButtonVariant.text,
                  onPressed: () => context.go(RoutePaths.register),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
