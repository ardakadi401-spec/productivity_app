import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../shared/forms/app_text_field_widget.dart';
import '../utils/note_color_options.dart';
import '../utils/note_formatting_actions.dart';
import 'note_content_preview.dart';

/// Note Detail Screen'in ortak form alanları (SCREENS.md §4.19) — başlık,
/// biçimlendirme araç çubuklu içerik alanı + her zaman görünür canlı
/// önizleme, renk seçimi. Zengin metin editörü DEĞİLDİR: içerik her zaman
/// düz `TextField`'dır, araç çubuğu yalnızca imleç/seçim konumuna düz metin
/// işaretçisi ekler (`note_formatting_actions.dart`).
class NoteFormFields extends StatefulWidget {
  const NoteFormFields({
    super.key,
    required this.titleController,
    required this.contentController,
    this.titleError,
    required this.color,
    required this.onColorChanged,
  });

  final TextEditingController titleController;
  final TextEditingController contentController;
  final String? titleError;

  final String? color;
  final ValueChanged<String?> onColorChanged;

  @override
  State<NoteFormFields> createState() => _NoteFormFieldsState();
}

class _NoteFormFieldsState extends State<NoteFormFields> {
  @override
  void initState() {
    super.initState();
    widget.contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    widget.contentController.removeListener(_onContentChanged);
    super.dispose();
  }

  void _onContentChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Başlık',
          controller: widget.titleController,
          errorText: widget.titleError,
          hintText: 'Not başlığı',
        ),
        const SizedBox(height: AppSpacing.md),
        Text('İçerik', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold),
              tooltip: 'Kalın',
              onPressed: () => insertBoldMarker(widget.contentController),
            ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              tooltip: 'Madde İşareti',
              onPressed: () => insertBulletMarker(widget.contentController),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.border),
          ),
          child: TextField(
            controller: widget.contentController,
            minLines: 4,
            maxLines: 10,
            style: AppTypography.bodyLg.copyWith(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Not içeriği (opsiyonel)',
              hintStyle: AppTypography.bodyLg.copyWith(color: tokens.textDisabled),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Önizleme', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: tokens.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: NoteContentPreview(content: widget.contentController.text),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Renk', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ColorDot(
              hex: null,
              selected: widget.color == null,
              onTap: () => widget.onColorChanged(null),
            ),
            for (final hex in noteColorPalette)
              _ColorDot(
                hex: hex,
                selected: hex == widget.color,
                onTap: () => widget.onColorChanged(hex),
              ),
          ],
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.hex, required this.selected, required this.onTap});

  /// `null` — "Renksiz" seçeneği.
  final String? hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hex == null ? Colors.transparent : hexToColor(hex!),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? theme.colorScheme.onSurface : tokens.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: hex == null
            ? Icon(Icons.block, size: 16, color: tokens.textSecondary)
            : (selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
      ),
    );
  }
}
