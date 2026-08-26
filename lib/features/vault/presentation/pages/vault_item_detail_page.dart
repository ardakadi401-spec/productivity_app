import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../domain/entities/vault_item.dart';
import '../providers/vault_providers.dart';

/// Kasa kaydı ekranı — Notes'un "unified create/edit" deseniyle aynı:
/// `itemId == null` yeni kayıt, aksi halde mevcut kaydın görüntülenmesi/
/// düzenlenmesidir. Basit alan sayısı (5 alan, alt-varlık/etiket yok)
/// nedeniyle Notes'taki ayrı Create/Edit controller + FormState katmanı
/// yerine, Settings sayfasındaki `_PinSetupDialog`/`_SecuritySection` ile
/// aynı daha hafif desen izlenir: mutasyonlar doğrudan sayfadan `ref.read`
/// ile usecase'lere yapılır.
class VaultItemDetailPage extends ConsumerWidget {
  const VaultItemDetailPage({super.key, this.itemId, this.initialFolderId});

  final String? itemId;

  /// Yalnızca yeni kayıt oluştururken (`itemId == null`) kullanılır — Kasa
  /// Listesi'nin o an içinde bulunulan klasörü, yeni kayıt oraya
  /// eklensin diye iletir.
  final String? initialFolderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemId == null) return _VaultItemForm(initial: null, initialFolderId: initialFolderId);

    final itemAsync = ref.watch(vaultItemDetailProvider(itemId!));
    return itemAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Kasa Kaydı')),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: LoadingSkeleton(height: 200, borderRadius: 16),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Kasa Kaydı')),
        body: const Center(child: Text('Kayıt yüklenemedi.')),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kasa Kaydı')),
            body: const Center(child: Text('Bu kayıt artık mevcut değil.')),
          );
        }
        return _VaultItemForm(initial: item);
      },
    );
  }
}

class _VaultItemForm extends ConsumerStatefulWidget {
  const _VaultItemForm({required this.initial, this.initialFolderId});

  final VaultItem? initial;
  final String? initialFolderId;

  @override
  ConsumerState<_VaultItemForm> createState() => _VaultItemFormState();
}

class _VaultItemFormState extends ConsumerState<_VaultItemForm> {
  late final _titleController = TextEditingController(text: widget.initial?.title ?? '');
  late final _usernameController = TextEditingController(text: widget.initial?.username ?? '');
  late final _passwordController = TextEditingController(text: widget.initial?.password ?? '');
  late final _urlController = TextEditingController(text: widget.initial?.url ?? '');
  late final _notesController = TextEditingController(text: widget.initial?.notes ?? '');
  late VaultItemCategory _category = widget.initial?.category ?? VaultItemCategory.app;

  String? _titleError;
  bool _obscurePassword = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  bool get _isCreate => widget.initial == null;

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Başlık boş olamaz.' : null;
    });
    return _titleError == null;
  }

  String? _nullIfEmpty(String value) => value.trim().isEmpty ? null : value.trim();

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final Result<VaultItem> result;
    if (_isCreate) {
      final repository = ref.read(vaultRepositoryProvider);
      final item = VaultItem(
        itemId: repository.newVaultItemId(),
        title: _titleController.text.trim(),
        category: _category,
        folderId: widget.initialFolderId,
        username: _nullIfEmpty(_usernameController.text),
        password: _nullIfEmpty(_passwordController.text),
        url: _nullIfEmpty(_urlController.text),
        notes: _nullIfEmpty(_notesController.text),
        createdAt: now,
        updatedAt: now,
      );
      result = await ref.read(createVaultItemUseCaseProvider).call(item);
    } else {
      final updated = widget.initial!.copyWith(
        title: _titleController.text.trim(),
        category: _category,
        username: _nullIfEmpty(_usernameController.text),
        clearUsername: _nullIfEmpty(_usernameController.text) == null,
        password: _nullIfEmpty(_passwordController.text),
        clearPassword: _nullIfEmpty(_passwordController.text) == null,
        url: _nullIfEmpty(_urlController.text),
        clearUrl: _nullIfEmpty(_urlController.text) == null,
        notes: _nullIfEmpty(_notesController.text),
        clearNotes: _nullIfEmpty(_notesController.text) == null,
        updatedAt: now,
      );
      result = await ref.read(updateVaultItemUseCaseProvider).call(updated);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    switch (result) {
      case Ok():
        if (_isCreate && context.mounted) context.pop();
        if (!_isCreate && context.mounted) {
          AppSnackbar.show(context, message: 'Kayıt güncellendi', isSuccess: true);
        }
      case Err(:final failure):
        if (context.mounted) AppSnackbar.show(context, message: failure.message);
    }
  }

  Future<void> _delete() async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Kaydı Sil',
      description: '"${widget.initial!.title}" kaydını silmek istediğine emin misin? Bu işlem geri alınamaz.',
      confirmLabel: 'Sil',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final result = await ref.read(deleteVaultItemUseCaseProvider).call(widget.initial!.itemId);
    if (!mounted) return;
    switch (result) {
      case Ok():
        if (context.mounted) context.pop();
      case Err(:final failure):
        setState(() => _isDeleting = false);
        if (context.mounted) AppSnackbar.show(context, message: failure.message);
    }
  }

  void _copyPassword() {
    final password = _passwordController.text;
    if (password.isEmpty) return;
    Clipboard.setData(ClipboardData(text: password));
    AppSnackbar.show(context, message: 'Şifre panoya kopyalandı', isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreate ? 'Yeni Kayıt' : 'Kasa Kaydı'),
        actions: [
          if (!_isCreate)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Sil',
              onPressed: _isDeleting ? null : _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppTextField(label: 'Başlık', controller: _titleController, errorText: _titleError),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              AppChip(
                label: 'Uygulama',
                selected: _category == VaultItemCategory.app,
                onTap: () => setState(() => _category = VaultItemCategory.app),
              ),
              AppChip(
                label: 'Proje',
                selected: _category == VaultItemCategory.project,
                onTap: () => setState(() => _category = VaultItemCategory.project),
              ),
              AppChip(
                label: 'Diğer',
                selected: _category == VaultItemCategory.other,
                onTap: () => setState(() => _category = VaultItemCategory.other),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Kullanıcı Adı / E-posta', controller: _usernameController),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Şifre',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'Kopyala',
                  onPressed: _copyPassword,
                ),
                IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  tooltip: _obscurePassword ? 'Göster' : 'Gizle',
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Bağlantı (URL)',
            controller: _urlController,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Notlar', controller: _notesController),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _isCreate ? 'Kaydet' : 'Güncelle',
            isFullWidth: true,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
    );
  }
}
