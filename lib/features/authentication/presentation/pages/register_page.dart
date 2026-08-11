import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../controllers/register_controller.dart';
import '../widgets/password_text_field.dart';

/// Register Screen — SCREENS.md §4.4.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().length < 2 ? 'Adını gir.' : null;
      _emailError = _emailRegex.hasMatch(_emailController.text.trim())
          ? null
          : 'Geçerli bir e-posta adresi gir.';
      _passwordError =
          _passwordController.text.length < 6 ? 'Şifre en az 6 karakter olmalı.' : null;
      _confirmPasswordError = _confirmPasswordController.text != _passwordController.text
          ? 'Şifreler eşleşmiyor.'
          : null;
    });
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(registerControllerProvider).isLoading;

    ref.listen(registerControllerProvider, (previous, next) {
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
              Text('Kayıt Ol', style: AppTypography.h1.copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(label: 'Ad', controller: _nameController, errorText: _nameError),
              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),
              PasswordTextField(
                label: 'Şifre Tekrar',
                controller: _confirmPasswordController,
                errorText: _confirmPasswordError,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Kayıt Ol',
                isFullWidth: true,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () {
                        if (!_validate()) return;
                        ref.read(registerControllerProvider.notifier).register(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: AppButton(
                  label: 'Zaten hesabın var mı? Giriş Yap',
                  variant: AppButtonVariant.text,
                  onPressed: () => context.go(RoutePaths.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
