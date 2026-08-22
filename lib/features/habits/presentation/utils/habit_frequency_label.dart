import '../../domain/entities/habit.dart';

/// `DateTime.weekday` (1=Pazartesi..7=Pazar) kısa gün adları — Calendar'ın
/// hafta günü etiketleriyle aynı sıra/kısaltma.
const List<String> weekdayShortLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Habit Card'da (COMPONENTS.md §9.1) "tekrar sıklığı özeti" — "Her gün" ya
/// da seçili günlerin kısaltmaları ("Pzt, Çar, Cum").
String habitFrequencySummary(Habit habit) {
  if (habit.targetFrequency == HabitTargetFrequency.daily) return 'Her gün';
  if (habit.targetDays.isEmpty) return 'Gün seçilmedi';
  final sorted = [...habit.targetDays]..sort();
  return sorted.map((day) => weekdayShortLabels[day - 1]).join(', ');
}
