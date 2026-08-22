import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/utils/note_formatting.dart';

/// İçerik alanının altında her zaman görünür canlı önizleme (SCREENS.md
/// §4.19) — `parseSimpleNoteFormatting`'in (Domain, saf ayrıştırıcı) çıktısını
/// `Text.rich` ile render eder. Zengin metin editörü DEĞİLDİR — salt okunur
/// bir önizlemedir, düzenleme her zaman düz `TextField`'da yapılır.
class NoteContentPreview extends StatelessWidget {
  const NoteContentPreview({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final lines = parseSimpleNoteFormatting(content);

    if (content.trim().isEmpty) {
      return Text(
        'Önizleme burada görünecek',
        style: AppTypography.bodyMd.copyWith(color: tokens.textDisabled),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line.isBullet) ...[
                  Text('•  ', style: AppTypography.bodyMd.copyWith(color: theme.colorScheme.onSurface)),
                ],
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        for (final span in line.spans)
                          TextSpan(
                            text: span.text,
                            style: AppTypography.bodyMd.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: span.isBold ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
