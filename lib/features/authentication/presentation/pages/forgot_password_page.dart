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
import '../controllers/forgot_password_controller.dart';

/// Forgot Password Screen — SCREENS.md §4.5.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = EmailValidator.isValid(_emailController.text.trim())
          ? null
          : 'Geçerli bir e-posta adresi gir.';
    });
    return _emailError == null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final isLoading = ref.watch(forgotPasswordControllerProvider).isLoading;

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next is AsyncData && previous is AsyncLoading) {
        AppSnackbar.show(
          context,
          message: 'Sıfırlama bağlantısı e-postana gönderildi',
          isSuccess: true,
        );
        context.go(RoutePaths.login);
      } else if (next is AsyncError) {
        final failure = next.error;
        final message = failure is Failure ? failure.message : 'Bir şeyler ters gitti. Lütfen tekrar dene.';
        AppSnackbar.show(context, message: message);
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Şifreni Sıfırla',
                style: AppTypography.h1.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'E-posta adresini gir, sana bir sıfırlama bağlantısı gönderelim.',
                style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'E-posta',
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                hintText: 'ornek@eposta.com',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Sıfırlama Bağlantısı Gönder',
                isFullWidth: true,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () {
                        if (!_validate()) return;
                        ref
                            .read(forgotPasswordControllerProvider.notifier)
                            .sendResetLink(email: _emailController.text.trim());
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
