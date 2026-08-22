import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:productivity_app/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:productivity_app/features/pomodoro/presentation/pages/pomodoro_page.dart';
import 'package:productivity_app/features/pomodoro/presentation/providers/pomodoro_providers.dart';

class _FakePomodoroRepository implements PomodoroRepository {
  final Map<String, PomodoroSession> sessions = {};
  int _counter = 0;

  @override
  String newSessionId() => 'session-${_counter++}';

  @override
  Stream<List<PomodoroSession>> watchSessionsByTask(String taskId) =>
      Stream.value(sessions.values.where((s) => s.taskId == taskId).toList());

  @override
  Future<Result<PomodoroSession>> createSession(PomodoroSession session) async {
    sessions[session.sessionId] = session;
    return Ok(session);
  }

  @override
  Future<Result<PomodoroSession>> completeSession(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  }) async {
    final updated = sessions[sessionId]!.copyWith(actualDuration: actualDuration, isCompleted: isCompleted);
    sessions[sessionId] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<PomodoroSession>> linkSessionToTask(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  }) async {
    final updated = sessions[sessionId]!.copyWith(taskId: taskId, clearTaskId: clearTaskId);
    sessions[sessionId] = updated;
    return Ok(updated);
  }

  @override
  Future<List<PomodoroSession>> getSessionsInRange(DateTime start, DateTime end) async {
    return sessions.values
        .where((s) => !s.startedAt.isBefore(start) && !s.startedAt.isAfter(end))
        .toList();
  }
}

Widget _wrap(_FakePomodoroRepository fake, {String? initialTaskId}) {
  return ProviderScope(
    overrides: [
      pomodoroRepositoryProvider.overrideWithValue(fake),
      pomodoroClockProvider.overrideWithValue(() => DateTime(2026, 1, 1, 9)),
    ],
    child: MaterialApp(theme: AppTheme.light, home: PomodoroPage(initialTaskId: initialTaskId)),
  );
}

void main() {
  testWidgets('boşta iken 25:00 ve "Başlat" butonu gösterilir', (tester) async {
    await tester.pumpWidget(_wrap(_FakePomodoroRepository()));
    await tester.pump();

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('ÇALIŞMA'), findsOneWidget);
    expect(find.text('Başlat'), findsOneWidget);
  });

  testWidgets('Başlat\'a dokunma bir oturum oluşturur ve butonu Duraklat\'a çevirir', (tester) async {
    final fake = _FakePomodoroRepository();
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.tap(find.text('Başlat'));
    await tester.pump();

    expect(find.text('Duraklat'), findsOneWidget);
    expect(fake.sessions, hasLength(1));
    expect(fake.sessions.values.single.isCompleted, isFalse);
  });

  testWidgets('Task Detail\'den initialTaskId ile gelindiğinde göreve otomatik bağlanır', (tester) async {
    final fake = _FakePomodoroRepository();
    await tester.pumpWidget(_wrap(fake, initialTaskId: 't1'));
    await tester.pump();

    await tester.tap(find.text('Başlat'));
    await tester.pump();

    expect(fake.sessions.values.single.taskId, 't1');
  });

  testWidgets('Sıfırla butonuna boştayken dokunmak hiçbir oturum oluşturmaz (devre dışı)', (tester) async {
    final fake = _FakePomodoroRepository();
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.tap(find.text('Sıfırla'), warnIfMissed: false);
    await tester.pump();

    expect(fake.sessions, isEmpty);
    expect(find.text('25:00'), findsOneWidget);
  });
}
