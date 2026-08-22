/// PRD.md §6.11 "basit biçimlendirme (kalın, madde işareti) — zengin metin
/// editörü kapsamı MVP'de sınırlı tutulur". Bu dosya bir editör DEĞİLDİR;
/// yalnızca düz metin içindeki iki sabit işaretçiyi ayrıştıran saf bir
/// fonksiyondur:
///   - `**kalın metin**` → kalın span
///   - Satır başında `- ` → madde işaretli satır
///
/// Domain katmanında yaşar (framework bağımsız, tamamen unit test edilebilir);
/// Presentation katmanındaki `NoteContentPreview` bu ayrıştırılmış modeli
/// `RichText`/`Text.rich` ile render eder.
class NoteContentLine {
  const NoteContentLine({required this.spans, required this.isBullet});

  final List<NoteContentSpan> spans;
  final bool isBullet;
}

class NoteContentSpan {
  const NoteContentSpan(this.text, {this.isBold = false});

  final String text;
  final bool isBold;
}

List<NoteContentLine> parseSimpleNoteFormatting(String content) {
  final lines = content.split('\n');
  return [
    for (final rawLine in lines) _parseLine(rawLine),
  ];
}

NoteContentLine _parseLine(String rawLine) {
  final isBullet = rawLine.startsWith('- ');
  final text = isBullet ? rawLine.substring(2) : rawLine;
  return NoteContentLine(spans: _parseBoldSpans(text), isBullet: isBullet);
}

final _boldPattern = RegExp(r'\*\*(.+?)\*\*');

List<NoteContentSpan> _parseBoldSpans(String text) {
  final spans = <NoteContentSpan>[];
  var cursor = 0;
  for (final match in _boldPattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(NoteContentSpan(text.substring(cursor, match.start)));
    }
    spans.add(NoteContentSpan(match.group(1)!, isBold: true));
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(NoteContentSpan(text.substring(cursor)));
  }
  if (spans.isEmpty) spans.add(const NoteContentSpan(''));
  return spans;
}
