import 'package:flutter/material.dart';

/// İçerik alanının biçimlendirme araç çubuğu eylemleri (SCREENS.md §4.19) —
/// `note_formatting.dart`'ın (Domain, saf ayrıştırıcı) tam tersi yönde
/// çalışır: imleç/seçim konumuna düz metin işaretçisi ekler. Flutter'ın
/// `TextEditingController`'ına bağımlı olduğundan Presentation katmanında
/// yaşar.
void insertBoldMarker(TextEditingController controller) {
  final selection = controller.selection;
  final text = controller.text;
  final start = selection.start < 0 ? text.length : selection.start;
  final end = selection.end < 0 ? text.length : selection.end;
  final selectedText = text.substring(start, end);

  final replacement = '**$selectedText**';
  final newText = text.replaceRange(start, end, replacement);
  final cursorOffset = selectedText.isEmpty ? start + 2 : start + replacement.length;

  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: cursorOffset),
  );
}

void insertBulletMarker(TextEditingController controller) {
  final selection = controller.selection;
  final text = controller.text;
  final cursor = selection.start < 0 ? text.length : selection.start;

  final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
  if (text.substring(lineStart).startsWith('- ')) return;

  final newText = text.replaceRange(lineStart, lineStart, '- ');
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: cursor + 2),
  );
}
