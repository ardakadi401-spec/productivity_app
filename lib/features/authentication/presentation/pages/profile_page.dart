import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

/// Profile Screen — önceden `PlaceholderScreen` idi (SCREENS.md §1.2'de
/// tanımlı ama hiç uygulanmamıştı). Kullanıcı isteğiyle: profil bilgilerini
/// gösterir ve görünen adın düzenlenmesine izin verir.
///
/// E-posta/şifre düzenlenemez — Firebase bu işlemler için yeniden
/// kimlik doğrulama ister (`updateEmail`/`updatePassword`, ayrı bir akış),
/// bilinçli olarak bu ilk sürümün kapsamı dışında bırakıldı.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(child: Text('Profil yüklenemedi.')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Center(child: _Avatar(user: user)),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.name,
                    style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Adı Düzenle',
                    onPressed: () => _editName(context, ref, user),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  user.email,
                  style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tokens.border),
                ),
                child: ListTile(
                  leading: Icon(
                    user.authProvider == AuthProviderType.google
                        ? Icons.g_mobiledata
                        : Icons.email_outlined,
                    color: tokens.textSecondary,
                  ),
                  title: Text(
                    'Giriş Yöntemi',
                    style: AppTypography.caption.copyWith(color: tokens.textSecondary),
                  ),
                  subtitle: Text(
                    user.authProvider == AuthProviderType.google ? 'Google' : 'E-posta',
                    style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, AppUser user) async {
    final name = await _EditNameDialog.show(context, initialValue: user.name);
    if (name == null || !context.mounted) return;

    final result = await ref.read(updateProfileUseCaseProvider).call(name: name);
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        AppSnackbar.show(context, message: 'Profil güncellendi', isSuccess: true);
      case Err(:final failure):
        AppSnackbar.show(context, message: failure.message);
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = user.photoUrl;
    final initial = user.name.isEmpty ? '?' : user.name[0].toUpperCase();

    return CircleAvatar(
      radius: 48,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.16),
      backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
      child: photoUrl == null
          ? Text(
              initial,
              style: AppTypography.h1.copyWith(color: theme.colorScheme.primary),
            )
          : null,
    );
  }
}

/// `_FolderNameDialog`/`_PinSetupDialog` ile aynı hafif dialog deseni.
class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialValue});

  final String initialValue;

  static Future<String?> show(BuildContext context, {required String initialValue}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialValue: initialValue),
    );
  }

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Ad boş olamaz.');
      return;
    }
    Navigator.of(context).pop(name);
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
              Text('Adı Düzenle', style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: AppSpacing.md),
              AppTextField(label: 'Ad', controller: _controller, errorText: _error),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Vazgeç',
                    variant: AppButtonVariant.text,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(label: 'Kaydet', onPressed: _submit),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
