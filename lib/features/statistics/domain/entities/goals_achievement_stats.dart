/// `GetGoalsAchievementRateUseCase`'in döndürdüğü, persist edilmeyen canlı
/// hesaplama — kullanıcı kararı gereği `StatisticsSnapshot` şemasına
/// eklenmedi (Goals dönem başına küçük hacimli olduğundan her seferinde
/// Goals Domain'inden canlı hesaplanır).
class GoalsAchievementStats {
  const GoalsAchievementStats({required this.achievedCount, required this.totalCount});

  final int achievedCount;
  final int totalCount;

  /// 0 hedef varsa bölme hatası olmadan 0 döner.
  double get achievementRatio => totalCount == 0 ? 0 : achievedCount / totalCount;
}
