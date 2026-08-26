import 'dart:async';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_record.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/calculate_streak_usecase.dart';
import '../datasources/local/habit_local_datasource.dart';
import '../datasources/remote/habit_remote_datasource.dart';
import '../mappers/habit_mapper.dart';
import '../mappers/habit_record_mapper.dart';
import '../models/habit_local_model.dart';
import '../models/habit_record_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması —
/// Tasks/Projects/Goals ile birebir aynı desen: her yazma önce Isar'a
/// (anında, `pendingX` işaretiyle) yazılır, bağlantı varsa arka planda
/// Firestore'a gönderilir.
///
/// `CalculateStreakUseCase` (saf, bağımsız Domain algoritması) her
/// check-in'de burada çağrılır ve sonuç Habit'e denormalize edilir —
/// `TaskRepositoryImpl._recalculate`'in alt görev ilerlemesi için yaptığının
/// birebir aynısı, DATABASE.md §6.4'ün öngördüğü şekilde.
///
/// FAZ 14 ADIM 6 — `SyncableRepository`'yi de implemente eder (Tasks'taki
/// ADIM 5 deseniyle birebir aynı): merkezi `SyncCoordinator`, bağlantı
/// offline→online geçtiğinde `syncPending()`'i çağırabilir. `HabitRepository`
/// (Domain) BİLEREK değiştirilmedi — yalnızca bu somut Data-katmanı
/// implementasyonu ek sözleşmeyi taşır. `getPendingSyncHabits()` adlandırma
/// farkı (diğer 6 feature'ın `getPendingSync()`'inden farklı) BİLEREK
/// yeniden adlandırılmadı — `syncPending()` bunu tamamen kapsüller, coordinator
/// veya başka hiçbir dış katman bu ismi hiç bilmez/çağırmaz.
class HabitRepositoryImpl implements HabitRepository, SyncableRepository {
  HabitRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final HabitLocalDatasource _local;
  final HabitRemoteDatasource _remote;
  final ConnectivityService _connectivity;
  final _calculateStreak = const CalculateStreakUseCase();

  @override
  String newHabitId() => _remote.newHabitId();

  @override
  Stream<List<Habit>> watchHabits() {
    return _local.watchHabits().map((models) => models.map(HabitMapper.toEntity).toList());
  }

  @override
  Stream<Habit?> watchHabit(String habitId) {
    return _local.watchHabit(habitId).map((m) => m == null ? null : HabitMapper.toEntity(m));
  }

  @override
  Stream<List<HabitRecord>> watchHabitRecords(String habitId) {
    return _local
        .watchHabitRecords(habitId)
        .map((list) => list.map(HabitRecordMapper.toEntity).toList());
  }

  @override
  Future<Result<Habit>> createHabit(Habit habit) => _guard(() async {
        final model = HabitMapper.fromEntity(habit, syncStatus: HabitSyncStatusLocal.pendingCreate);
        await _local.putHabit(model);
        await _trySyncHabit(model);
        return HabitMapper.toEntity(model);
      });

  @override
  Future<Result<Habit>> updateHabit(Habit habit) => _guard(() async {
        final model = HabitMapper.fromEntity(habit, syncStatus: HabitSyncStatusLocal.pendingUpdate);
        await _local.putHabit(model);
        await _trySyncHabit(model);
        return HabitMapper.toEntity(model);
      });

  @override
  Future<Result<void>> deleteHabit(String habitId) => _guard(() async {
        final existing = await _local.getByHabitId(habitId);
        if (existing == null) throw const CacheException('Alışkanlık bulunamadı.');
        final now = DateTime.now();
        existing
          ..isDeleted = true
          ..deletedAt = now
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = HabitSyncStatusLocal.pendingDelete;
        await _local.putHabit(existing);
        await _trySyncHabit(existing);
      });

  @override
  Future<Result<Habit>> setCheckIn(String habitId, DateTime date, {required bool isCompleted}) =>
      _guard(() async {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final recordId = _formatRecordId(normalizedDate);
        final compositeKey = HabitRecordLocalModel.buildCompositeKey(habitId, recordId);

        if (isCompleted) {
          final now = DateTime.now();
          final record = HabitRecordLocalModel()
            ..compositeKey = compositeKey
            ..habitId = habitId
            ..recordId = recordId
            ..date = normalizedDate
            ..isCompleted = true
            ..completedAt = now
            ..syncStatus = HabitRecordSyncStatusLocal.pendingCreate
            ..localUpdatedAt = now;
          await _local.putHabitRecord(record);
          await _trySyncHabitRecord(record);
        } else {
          // Geri alma — HabitRecord soft delete taşımadığından (DATABASE.md
          // §13.4 istisnası) kayıt kalıcı olarak silinir. Çevrimdışıyken
          // silinirse uzak taraftaki eski kayıt, bir sonraki `_syncFromRemote`
          // sırasında geri "hayalet" olarak dönebilir — tam çakışma/tombstone
          // yönetimi FAZ 14 kapsamıdır (ROADMAP.md genelinde kabul edilen
          // sınırlama, bkz. TaskRepositoryImpl benzer notu).
          await _local.deleteHabitRecord(compositeKey);
          if (await _connectivity.isConnected) {
            try {
              await _remote.deleteHabitRecord(habitId, recordId);
            } catch (_) {
              // pending kalır — bir sonraki bağlantıda tekrar denenmez
              // (FAZ 14 kapsamı), kabul edilen sınırlama.
            }
          }
        }

        return _recalculateStreak(habitId);
      });

  @override
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end) async {
    final models = await _local.getRecordsInRange(start, end);
    return models.map(HabitRecordMapper.toEntity).toList();
  }

  Future<Habit> _recalculateStreak(String habitId) async {
    final habitModel = await _local.getByHabitId(habitId);
    if (habitModel == null) throw const CacheException('Alışkanlık bulunamadı.');
    final recordModels = await _local.getHabitRecords(habitId);
    final habit = HabitMapper.toEntity(habitModel);
    final records = recordModels.map(HabitRecordMapper.toEntity).toList();

    final result = _calculateStreak.call(habit: habit, records: records, referenceDate: DateTime.now());
    final now = DateTime.now();
    habitModel
      ..currentStreak = result.currentStreak
      ..longestStreak = result.longestStreak
      ..updatedAt = now
      ..localUpdatedAt = now
      ..syncStatus = HabitSyncStatusLocal.pendingUpdate;
    await _local.putHabit(habitModel);
    await _trySyncHabit(habitModel);
    return HabitMapper.toEntity(habitModel);
  }

  String _formatRecordId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Bağlantı varsa Firestore'a gönderir; başarısız olursa sessizce
  /// `pending` bırakır (ARCHITECTURE.md §8.2).
  Future<void> _trySyncHabit(HabitLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setHabit(model);
      model
        ..syncStatus = HabitSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putHabit(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _trySyncHabitRecord(HabitRecordLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setHabitRecord(model);
      model
        ..syncStatus = HabitRecordSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putHabitRecord(model);
    } catch (_) {
      // pending kalır.
    }
  }

  /// DATABASE.md §12.4 — bir kerelik uzaktan çekme + Last-Write-Wins eşleme,
  /// ardından yerelde hâlâ `pending*` olan kayıtları göndermeyi dener
  /// (`syncPending()` — bkz. aşağı). Yalnızca constructor'dan, uygulama
  /// ömrü boyunca BİR KEZ çağrılır; bu ADIM'da değiştirilmedi. HabitRecord
  /// açık pending listesi olmadığından, kayıtlar yalnızca ilgili Habit'in
  /// kaydı senkronize olduğunda ayrıca gönderilmiş kabul edilir — check-in
  /// anında zaten `_trySyncHabitRecord` denenmiştir (değişmedi).
  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteHabits = await _remote.fetchAllHabits();
      for (final remoteHabit in remoteHabits) {
        final local = await _local.getByHabitId(remoteHabit.habitId);
        if (local == null || remoteHabit.updatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putHabit(remoteHabit);
        }
        final remoteRecords = await _remote.fetchHabitRecords(remoteHabit.habitId);
        for (final remoteRecord in remoteRecords) {
          await _local.putHabitRecord(remoteRecord);
        }
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 ADIM 6 — merkezi `SyncCoordinator` tarafından, bağlantı
  /// offline→online geçtiğinde çağrılır. Yalnızca yerelde `pending*` durumda
  /// kalan alışkanlıkları Firestore'a göndermeyi dener (`pendingCreate`/
  /// `pendingUpdate`/`pendingDelete` ayrımı `_trySyncHabit`'e dokunmadığı
  /// için korunur); `_syncFromRemote` içindeki tek seferlik "uzaktan çek +
  /// LWW eşle" adımını TEKRARLAMAZ (o hâlâ yalnızca constructor'da, bir
  /// kerelik çalışır — bkz. yukarı).
  ///
  /// `getPendingSyncHabits()` adlandırma farkı burada kapsüllenir — bu
  /// metodun dışındaki hiçbir kod (coordinator dahil) bu ismi bilmez.
  ///
  /// Bağlantı yoksa güvenle hiçbir şey yapmadan döner. Bir kaydın gönderimi
  /// başarısız olursa `_trySyncHabit` onu sessizce `pending` bırakır —
  /// hiçbir istisna dışarı fırlatılmaz, coordinator kalıcı olarak etkilenmez.
  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final pending = await _local.getPendingSyncHabits();
      for (final model in pending) {
        await _trySyncHabit(model);
      }
    } catch (_) {
      // Sessiz — pending kayıtlar bir sonraki tetikleyicide tekrar denenir.
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (e) {
      return Err(_mapToFailure(e));
    }
  }

  Failure _mapToFailure(AppException exception) {
    return switch (exception) {
      CacheException(:final message) => CacheFailure(message),
      NetworkException() => const NetworkFailure('Bağlantını kontrol edip tekrar dene.'),
      AuthException() => const AuthFailure('Oturum bulunamadı, lütfen tekrar giriş yap.'),
      _ => UnknownFailure(exception.message),
    };
  }
}
