/// Note Card önizlemesi (COMPONENTS.md §4.7) için `content`'i tek satırlık,
/// biçimlendirme işaretçilerinden (`**kalın**`, `- madde işareti`)
/// arındırılmış düz metne çevirir. `shared/components/`'teki
/// `NoteCardWidget` `Note`/`note_formatting.dart`'a bağımlı olamayacağından
/// (shared kuralı) bu dönüşüm Notes'un kendi Presentation katmanında yapılır.
String? notePreviewText(String? content) {
  if (content == null || content.trim().isEmpty) return null;
  return content
      .split('\n')
      .map((line) => line.startsWith('- ') ? line.substring(2) : line)
      .join(' ')
      .replaceAll('**', '')
      .trim();
}
