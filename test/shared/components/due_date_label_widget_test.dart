import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/shared/components/due_date_label_widget.dart';

/// Due Date Label (COMPONENTS.md §6.4), ROADMAP.md FAZ 16 — coverage
/// denetiminde %0 bulunan paylaşılan bir bileşen. Renk/ikon durumları
/// gerçek `DateTime.now()`'a göre hesaplandığından ("Gecikti"/"Bugün"/
/// gelecek), sınır-değer flaky olabilecek "Yaklaşan" (24 saat içi) durumu
/// hariç, deterministik olan durumlar test edilir.
Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('dueDate null ise hiçbir şey render etmez', (tester) async {
    await tester.pumpWidget(_wrap(const DueDateLabel(dueDate: null)));

    expect(find.byType(DueDateLabel), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('geçmiş tarih, tamamlanmamış -> "Gecikti" + schedule ikonu', (tester) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await tester.pumpWidget(_wrap(DueDateLabel(dueDate: yesterday)));

    expect(find.textContaining('Gecikti · Dün'), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });

  testWidgets('geçmiş tarih ama isCompleted=true ise "Gecikti" gösterilmez', (tester) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await tester.pumpWidget(_wrap(DueDateLabel(dueDate: yesterday, isCompleted: true)));

    expect(find.textContaining('Gecikti'), findsNothing);
    expect(find.text('Dün'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });

  testWidgets('bugünün tarihi -> "Bugün" gösterir', (tester) async {
    await tester.pumpWidget(_wrap(DueDateLabel(dueDate: DateTime.now())));

    expect(find.text('Bugün'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });

  testWidgets('uzak gelecekteki tarih -> kısa tarih biçimi gösterir', (tester) async {
    final future = DateTime.now().add(const Duration(days: 10));
    await tester.pumpWidget(_wrap(DueDateLabel(dueDate: future)));

    expect(find.textContaining(RegExp(r'^\d{1,2} ')), findsOneWidget);
  });

  testWidgets('dueTime verilirse metne eklenir', (tester) async {
    // Yarının tarihi kullanılır: bugünün saatiyle karşılaştırıldığında her
    // zaman gelecekte kalır, testin çalıştığı saate bağlı "Gecikti" flake
    // riskini ortadan kaldırır.
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await tester.pumpWidget(_wrap(DueDateLabel(dueDate: tomorrow, dueTime: '14:30')));

    expect(find.text('Yarın 14:30'), findsOneWidget);
  });
}
