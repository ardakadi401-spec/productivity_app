/// Görece/kısa tarih biçimlendirme — `intl` paketi olmadan, projenin Türkçe
/// arayüz diline uygun küçük bir yardımcı (Due Date Label, Task Detail gibi
/// birden fazla feature'da tekrarlanacağı için `core/utils/`'te).
class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  /// "12 Ağu" gibi kısa gün/ay biçimi.
  static String shortDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

  /// Bugün → "Bugün", yarın → "Yarın", dün → "Dün", diğer → [shortDate].
  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    return switch (diff) {
      0 => 'Bugün',
      1 => 'Yarın',
      -1 => 'Dün',
      _ => shortDate(date),
    };
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
