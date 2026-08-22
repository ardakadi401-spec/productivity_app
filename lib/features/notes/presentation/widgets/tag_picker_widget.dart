import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../tags/presentation/providers/tag_providers.dart';
import '../utils/note_color_options.dart';

/// Not oluşturma/düzenleme ekranının etiket seçim alanı (SCREENS.md §4.19,
/// PRD §6.11) — çoklu seçim chip grubu + satır içi "Yeni Etiket" oluşturma.
/// DATABASE.md §1.5'in ayrı `tags` lookup koleksiyonu kararını korur: burada
/// yalnızca mevcut etiketler listelenir/seçilir, geçici/gömülü bir etiket
/// mekanizması kurulmaz.
class TagPickerWidget extends ConsumerWidget {
  const TagPickerWidget({super.key, required this.selectedTagIds, required this.onToggle});

  final List<String> selectedTagIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final tagsAsync = ref.watch(tagListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Etiketler', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        tagsAsync.when(
          loading: () => const LoadingSkeleton(height: 32, borderRadius: 16),
          error: (_, _) => const SizedBox.shrink(),
          data: (tags) => Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tag in tags)
                AppChip(
                  label: tag.name,
                  selected: selectedTagIds.contains(tag.tagId),
                  selectedColor: hexToColor(tag.color),
                  onTap: () => onToggle(tag.tagId),
                ),
              AppChip(
                label: '+ Yeni Etiket',
                onTap: () => _showCreateTagSheet(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateTagSheet(BuildContext context, WidgetRef ref) {
    AppBottomSheet.show<void>(
      context,
      child: _CreateTagSheetBody(onCreated: onToggle),
    );
  }
}

class _CreateTagSheetBody extends ConsumerStatefulWidget {
  const _CreateTagSheetBody({required this.onCreated});

  final ValueChanged<String> onCreated;

  @override
  ConsumerState<_CreateTagSheetBody> createState() => _CreateTagSheetBodyState();
}

class _CreateTagSheetBodyState extends ConsumerState<_CreateTagSheetBody> {
  final _nameController = TextEditingController();
  String _color = noteColorPalette.first;
  String? _nameError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yeni Etiket', style: AppTypography.h2.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Etiket Adı',
            controller: _nameController,
            errorText: _nameError,
            hintText: 'Etiket adı',
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Renk', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final hex in noteColorPalette)
                InkWell(
                  onTap: () => setState(() => _color = hex),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hexToColor(hex),
                      shape: BoxShape.circle,
                      border: hex == _color
                          ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                          : null,
                    ),
                    child: hex == _color ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Oluştur',
            isFullWidth: true,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Etiket adı boş olamaz.');
      return;
    }
    setState(() {
      _isSaving = true;
      _nameError = null;
    });

    final repository = ref.read(tagRepositoryProvider);
    final now = DateTime.now();
    final tag = Tag(
      tagId: repository.newTagId(),
      name: name,
      color: _color,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(createTagUseCaseProvider).call(tag);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        widget.onCreated(value.tagId);
        Navigator.of(context).pop();
      case Err(:final failure):
        setState(() => _isSaving = false);
        AppSnackbar.show(context, message: failure.message);
    }
  }
}
