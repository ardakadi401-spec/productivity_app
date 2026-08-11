/// Feature-agnostik `DateTime` yardımcıları — FOLDER_STRUCTURE.md Bölüm 2.1
/// örneği (Calendar ve Statistics gibi en az 2 feature'ın ortak ihtiyacı).
extension DateTimeExtensions on DateTime {
  static const _months = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  bool _isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => _isSameDay(DateTime.now());

  bool get isTomorrow => _isSameDay(DateTime.now().add(const Duration(days: 1)));

  bool get isYesterday => _isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// "Bugün" / "Yarın" / "Dün" / "6 Ağu" biçiminde göreli gün etiketi.
  String get relativeDayLabel {
    if (isToday) return 'Bugün';
    if (isTomorrow) return 'Yarın';
    if (isYesterday) return 'Dün';
    return '$day ${_months[month - 1]}';
  }
}
