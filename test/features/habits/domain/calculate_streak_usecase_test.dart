import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/usecases/calculate_streak_usecase.dart';

Habit _habit({
  HabitTargetFrequency targetFrequency = HabitTargetFrequency.daily,
  List<int> targetDays = const [],
}) =>
    Habit(
      habitId: 'h1',
      name: 'Su iç',
      color: '#FF8A8A',
      targetFrequency: targetFrequency,
      targetDays: targetDays,
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

HabitRecord _record(DateTime date, {bool isCompleted = true}) => HabitRecord(
      recordId: '${date.year}-${date.month}-${date.day}',
      habitId: 'h1',
      date: DateTime(date.year, date.month, date.day),
      isCompleted: isCompleted,
    );

void main() {
  const useCase = CalculateStreakUseCase();

  group('daily — temel senaryolar', () {
    test('hiç kayıt yoksa 0/0 döner', () {
      final result = useCase.call(habit: _habit(), records: const [], referenceDate: DateTime(2026, 3, 10));
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
    });

    test('ardışık 3 gün tamamlandıysa currentStreak=3, longestStreak=3', () {
      final habit = _habit();
      final records = [
        _record(DateTime(2026, 3, 8)),
        _record(DateTime(2026, 3, 9)),
        _record(DateTime(2026, 3, 10)),
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 10));
      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test('bir gün atlandığında (kayıt yok) streak doğru sıfırlanır', () {
      final habit = _habit();
      final records = [
        _record(DateTime(2026, 3, 7)),
        _record(DateTime(2026, 3, 8)),
        // 3/9 atlandı (kayıt yok).
        _record(DateTime(2026, 3, 10)),
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 10));
      // Yalnızca bugün (3/10) sayılır; önceki seri (3/7-3/8) 3/9 atlaması
      // nedeniyle kopmuştur.
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 2);
    });

    test('bir gün açıkça isCompleted:false ile işaretlendiğinde streak sıfırlanır', () {
      final habit = _habit();
      final records = [
        _record(DateTime(2026, 3, 8)),
        _record(DateTime(2026, 3, 9), isCompleted: false),
        _record(DateTime(2026, 3, 10)),
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 10));
      expect(result.currentStreak, 1);
    });

    test('en uzun seri, güncel seri kırıldıktan sonra da korunur', () {
      final habit = _habit();
      final records = [
        _record(DateTime(2026, 3, 1)),
        _record(DateTime(2026, 3, 2)),
        _record(DateTime(2026, 3, 3)),
        _record(DateTime(2026, 3, 4)),
        _record(DateTime(2026, 3, 5)),
        // 3/6 atlandı — 5 günlük seri kırılır.
        _record(DateTime(2026, 3, 7)),
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 7));
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 5);
    });
  });

  group('"bugün henüz işaretlenmedi" grace period (COMPONENTS.md §9.1)', () {
    test('dün tamamlandı, bugün için kayıt yoksa currentStreak sıfırlanmaz', () {
      final habit = _habit();
      final records = [
        _record(DateTime(2026, 3, 8)),
        _record(DateTime(2026, 3, 9)),
        // 3/10 (bugün) için kayıt YOK — henüz işaretlenmedi.
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 10));
      expect(result.currentStreak, 2);
    });

    test('bugün geri alınıp (kayıt silinip) tekrar hesaplandığında dünkü seri korunur', () {
      final habit = _habit();
      // Kullanıcı önce bugünü işaretledi (currentStreak=3 olurdu), sonra
      // geri aldı — HabitRecord kalıcı silindiğinden bir sonraki
      // hesaplamada bugünün kaydı artık listede yok.
      final afterUndo = [
        _record(DateTime(2026, 3, 8)),
        _record(DateTime(2026, 3, 9)),
      ];
      final result =
          useCase.call(habit: habit, records: afterUndo, referenceDate: DateTime(2026, 3, 10));
      expect(result.currentStreak, 2);
    });
  });

  group('specificDays — haftanın belirli günleri (ROADMAP FAZ 9 kritik risk)', () {
    test('hedef olmayan bir gün (Salı/Perşembe) streak\'i bozmaz', () {
      // Pazartesi(1)/Çarşamba(3)/Cuma(5) hedef. 2026-03-09 Pazartesi.
      final habit = _habit(targetFrequency: HabitTargetFrequency.specificDays, targetDays: const [1, 3, 5]);
      final records = [
        _record(DateTime(2026, 3, 9)), // Pzt
        _record(DateTime(2026, 3, 11)), // Çar
        _record(DateTime(2026, 3, 13)), // Cum
      ];
      // Referans: Cuma (3/13). Aradaki Salı(3/10)/Perşembe(3/12) hiç
      // hedef olmadığından değerlendirmeye girmez.
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 13));
      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test('hedef bir gün (örn. Çarşamba) atlanırsa streak gerçekten kırılır', () {
      final habit = _habit(targetFrequency: HabitTargetFrequency.specificDays, targetDays: const [1, 3, 5]);
      final records = [
        _record(DateTime(2026, 3, 9)), // Pzt — tamam
        // 3/11 Çarşamba atlandı (kayıt yok).
        _record(DateTime(2026, 3, 13)), // Cum — tamam
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 13));
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
    });

    test('hafta sınırını (Cuma → Pazartesi) doğru şekilde ardışık sayar', () {
      final habit = _habit(targetFrequency: HabitTargetFrequency.specificDays, targetDays: const [1, 5]);
      final records = [
        _record(DateTime(2026, 3, 6)), // Cuma
        _record(DateTime(2026, 3, 9)), // Pazartesi (bir sonraki hedef gün)
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 9));
      expect(result.currentStreak, 2);
    });

    test('bugün hedef gün değilse (örn. Salı) bir önceki hedef günün serisi gösterilir', () {
      final habit = _habit(targetFrequency: HabitTargetFrequency.specificDays, targetDays: const [1, 3, 5]);
      final records = [_record(DateTime(2026, 3, 9))]; // Pazartesi tamam.
      // Referans: Salı (3/10) — hedef gün değil, listeye hiç girmez.
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 10));
      expect(result.currentStreak, 1);
    });
  });

  group('gece yarısı / tarih sınırı (timezone-benzeri senaryolar)', () {
    test('referans tarih gece yarısına yakın bir saat taşısa da gün doğru normalize edilir', () {
      final habit = _habit();
      final records = [
        _record(DateTime(2026, 3, 9)),
        _record(DateTime(2026, 3, 10)),
      ];
      final result = useCase.call(
        habit: habit,
        records: records,
        referenceDate: DateTime(2026, 3, 10, 23, 59, 59),
      );
      expect(result.currentStreak, 2);
    });

    test('kaydın saat bileşeni olsa da (örn. 08:30) doğru güne eşlenir', () {
      final habit = _habit();
      final records = [
        HabitRecord(
          recordId: '2026-3-9',
          habitId: 'h1',
          date: DateTime(2026, 3, 9, 8, 30),
          isCompleted: true,
        ),
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 9, 22));
      expect(result.currentStreak, 1);
    });

    test('gece yarısını geçip yeni gün başladığında (referans tarih ilerledi) dünün kaydı olmadan streak kırılır', () {
      final habit = _habit();
      final records = [
        _record(DateTime(2026, 3, 8)),
        _record(DateTime(2026, 3, 9)),
        // 3/10 için hiç kayıt yok (gece yarısını geçti, kullanıcı henüz
        // check-in yapmadı ve 3/9 de artık "bugün" değil).
      ];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 11));
      // 3/10 (dün, artık "bugün" değil) için kayıt yoksa gerçekten kırılmış
      // sayılır — grace period yalnızca tam olarak referenceDate'e uygulanır.
      expect(result.currentStreak, 0);
    });
  });

  group('ilk check-in / tek kayıt', () {
    test('yalnızca bugün tamamlandıysa currentStreak=1, longestStreak=1', () {
      final habit = _habit();
      final records = [_record(DateTime(2026, 3, 10))];
      final result = useCase.call(habit: habit, records: records, referenceDate: DateTime(2026, 3, 10));
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
    });
  });
}
