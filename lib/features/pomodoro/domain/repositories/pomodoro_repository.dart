import '../../../../core/errors/result.dart';
import '../entities/pomodoro_session.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
abstract interface class PomodoroRepository {
  /// Ağ çağrısı yapmadan yeni bir oturum ID'si tahsis eder (Firestore
  /// client-side doküman ID — offline de çalışır).
  String newSessionId();

  /// Task Detail Screen'in oturum geçmişi (SCREENS.md §4.10 "Sonraki Ekran
  /// Bağlantıları").
  Stream<List<PomodoroSession>> watchSessionsByTask(String taskId);

  /// Oturum başlarken (ROADMAP FAZ 11 risk mitigasyonu — "oturum
  /// başlangıcında pending durumda yerel kayıt oluşturulması") çağrılır;
  /// uygulama oturum bitmeden kapatılsa bile bu kayıt `isCompleted: false`
  /// olarak güvenle kalır, veri kaybı olmaz.
  Future<Result<PomodoroSession>> createSession(PomodoroSession session);

  /// Oturum doğal olarak bitince veya erken iptal edilince çağrılır.
  Future<Result<PomodoroSession>> completeSession(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  });

  /// ROADMAP.md FAZ 11 `LinkSessionToTaskUseCase` — devam eden/tamamlanmış
  /// bir oturumun görev bağlantısını `updateSession`'dan ayrı, dedike bir
  /// yazma olarak tutar (Notes'un `setLink`'i ile aynı ilke).
  Future<Result<PomodoroSession>> linkSessionToTask(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  });

  /// ROADMAP.md FAZ 12 — Statistics'in dönemsel agregasyonu için eklendi.
  /// TÜM oturumlar genelinde (görev bazlı filtre olmadan), `startedAt`
  /// tarih aralığındaki (kapsayıcı) kayıtları tek seferlik olarak döner.
  Future<List<PomodoroSession>> getSessionsInRange(DateTime start, DateTime end);
}
