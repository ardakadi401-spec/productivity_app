/// Feature-agnostik `Duration` yardımcıları (Pomodoro sayaç, Statistics
/// toplam süre gösterimi gibi en az 2 feature'ın ortak ihtiyacı).
extension DurationExtensions on Duration {
  /// "mm:ss" biçiminde sayaç gösterimi (örn. Pomodoro geri sayımı).
  String get mmss {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
