// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_session_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPomodoroSessionLocalModelCollection on Isar {
  IsarCollection<PomodoroSessionLocalModel> get pomodoroSessionLocalModels =>
      this.collection();
}

const PomodoroSessionLocalModelSchema = CollectionSchema(
  name: r'PomodoroSessionLocalModel',
  id: -7889253378338651727,
  properties: {
    r'actualDurationSeconds': PropertySchema(
      id: 0,
      name: r'actualDurationSeconds',
      type: IsarType.long,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 2,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 3,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'localUpdatedAt': PropertySchema(
      id: 4,
      name: r'localUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'plannedDurationSeconds': PropertySchema(
      id: 5,
      name: r'plannedDurationSeconds',
      type: IsarType.long,
    ),
    r'sessionId': PropertySchema(
      id: 6,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'startedAt': PropertySchema(
      id: 7,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'syncStatus': PropertySchema(
      id: 8,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _PomodoroSessionLocalModelsyncStatusEnumValueMap,
    ),
    r'taskId': PropertySchema(id: 9, name: r'taskId', type: IsarType.string),
    r'type': PropertySchema(
      id: 10,
      name: r'type',
      type: IsarType.string,
      enumMap: _PomodoroSessionLocalModeltypeEnumValueMap,
    ),
  },

  estimateSize: _pomodoroSessionLocalModelEstimateSize,
  serialize: _pomodoroSessionLocalModelSerialize,
  deserialize: _pomodoroSessionLocalModelDeserialize,
  deserializeProp: _pomodoroSessionLocalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'taskId': IndexSchema(
      id: -6391211041487498726,
      name: r'taskId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _pomodoroSessionLocalModelGetId,
  getLinks: _pomodoroSessionLocalModelGetLinks,
  attach: _pomodoroSessionLocalModelAttach,
  version: '3.3.2',
);

int _pomodoroSessionLocalModelEstimateSize(
  PomodoroSessionLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.syncStatus.name.length * 3;
  {
    final value = object.taskId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _pomodoroSessionLocalModelSerialize(
  PomodoroSessionLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actualDurationSeconds);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeBool(offsets[2], object.isCompleted);
  writer.writeDateTime(offsets[3], object.lastSyncedAt);
  writer.writeDateTime(offsets[4], object.localUpdatedAt);
  writer.writeLong(offsets[5], object.plannedDurationSeconds);
  writer.writeString(offsets[6], object.sessionId);
  writer.writeDateTime(offsets[7], object.startedAt);
  writer.writeString(offsets[8], object.syncStatus.name);
  writer.writeString(offsets[9], object.taskId);
  writer.writeString(offsets[10], object.type.name);
}

PomodoroSessionLocalModel _pomodoroSessionLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PomodoroSessionLocalModel();
  object.actualDurationSeconds = reader.readLong(offsets[0]);
  object.completedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[2]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[3]);
  object.localUpdatedAt = reader.readDateTime(offsets[4]);
  object.plannedDurationSeconds = reader.readLong(offsets[5]);
  object.sessionId = reader.readString(offsets[6]);
  object.startedAt = reader.readDateTime(offsets[7]);
  object.syncStatus =
      _PomodoroSessionLocalModelsyncStatusValueEnumMap[reader.readStringOrNull(
        offsets[8],
      )] ??
      PomodoroSyncStatusLocal.synced;
  object.taskId = reader.readStringOrNull(offsets[9]);
  object.type =
      _PomodoroSessionLocalModeltypeValueEnumMap[reader.readStringOrNull(
        offsets[10],
      )] ??
      PomodoroSessionTypeLocal.work;
  return object;
}

P _pomodoroSessionLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (_PomodoroSessionLocalModelsyncStatusValueEnumMap[reader
                  .readStringOrNull(offset)] ??
              PomodoroSyncStatusLocal.synced)
          as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (_PomodoroSessionLocalModeltypeValueEnumMap[reader
                  .readStringOrNull(offset)] ??
              PomodoroSessionTypeLocal.work)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PomodoroSessionLocalModelsyncStatusEnumValueMap = {
  r'synced': r'synced',
  r'pendingCreate': r'pendingCreate',
  r'pendingUpdate': r'pendingUpdate',
  r'error': r'error',
};
const _PomodoroSessionLocalModelsyncStatusValueEnumMap = {
  r'synced': PomodoroSyncStatusLocal.synced,
  r'pendingCreate': PomodoroSyncStatusLocal.pendingCreate,
  r'pendingUpdate': PomodoroSyncStatusLocal.pendingUpdate,
  r'error': PomodoroSyncStatusLocal.error,
};
const _PomodoroSessionLocalModeltypeEnumValueMap = {
  r'work': r'work',
  r'breakTime': r'breakTime',
};
const _PomodoroSessionLocalModeltypeValueEnumMap = {
  r'work': PomodoroSessionTypeLocal.work,
  r'breakTime': PomodoroSessionTypeLocal.breakTime,
};

Id _pomodoroSessionLocalModelGetId(PomodoroSessionLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pomodoroSessionLocalModelGetLinks(
  PomodoroSessionLocalModel object,
) {
  return [];
}

void _pomodoroSessionLocalModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  PomodoroSessionLocalModel object,
) {
  object.id = id;
}

extension PomodoroSessionLocalModelByIndex
    on IsarCollection<PomodoroSessionLocalModel> {
  Future<PomodoroSessionLocalModel?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  PomodoroSessionLocalModel? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<PomodoroSessionLocalModel?>> getAllBySessionId(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<PomodoroSessionLocalModel?> getAllBySessionIdSync(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(PomodoroSessionLocalModel object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(
    PomodoroSessionLocalModel object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<PomodoroSessionLocalModel> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(
    List<PomodoroSessionLocalModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension PomodoroSessionLocalModelQueryWhereSort
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QWhere
        > {
  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PomodoroSessionLocalModelQueryWhere
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QWhereClause
        > {
  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sessionId', value: [sessionId]),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  taskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'taskId', value: [null]),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  taskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'taskId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  taskIdEqualTo(String? taskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'taskId', value: [taskId]),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterWhereClause
  >
  taskIdNotEqualTo(String? taskId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskId',
                lower: [],
                upper: [taskId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskId',
                lower: [taskId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskId',
                lower: [taskId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskId',
                lower: [],
                upper: [taskId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PomodoroSessionLocalModelQueryFilter
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QFilterCondition
        > {
  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  actualDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'actualDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  actualDurationSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'actualDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  actualDurationSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'actualDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  actualDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'actualDurationSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  completedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  completedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isCompleted', value: value),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  lastSyncedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  lastSyncedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  localUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  localUpdatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  localUpdatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  localUpdatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localUpdatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  plannedDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'plannedDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  plannedDurationSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plannedDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  plannedDurationSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plannedDurationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  plannedDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plannedDurationSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sessionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusEqualTo(
    PomodoroSyncStatusLocal value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusGreaterThan(
    PomodoroSyncStatusLocal value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusLessThan(
    PomodoroSyncStatusLocal value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusBetween(
    PomodoroSyncStatusLocal lower,
    PomodoroSyncStatusLocal upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'syncStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'taskId'),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'taskId'),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'taskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'taskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'taskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'taskId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'taskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'taskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'taskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'taskId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'taskId', value: ''),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'taskId', value: ''),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeEqualTo(PomodoroSessionTypeLocal value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeGreaterThan(
    PomodoroSessionTypeLocal value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeLessThan(
    PomodoroSessionTypeLocal value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeBetween(
    PomodoroSessionTypeLocal lower,
    PomodoroSessionTypeLocal upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterFilterCondition
  >
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension PomodoroSessionLocalModelQueryObject
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QFilterCondition
        > {}

extension PomodoroSessionLocalModelQueryLinks
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QFilterCondition
        > {}

extension PomodoroSessionLocalModelQuerySortBy
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QSortBy
        > {
  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByActualDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByActualDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByPlannedDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByPlannedDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PomodoroSessionLocalModelQuerySortThenBy
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QSortThenBy
        > {
  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByActualDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByActualDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByPlannedDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByPlannedDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionLocalModel,
    QAfterSortBy
  >
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PomodoroSessionLocalModelQueryWhereDistinct
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QDistinct
        > {
  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByActualDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localUpdatedAt');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByPlannedDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByTaskId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, PomodoroSessionLocalModel, QDistinct>
  distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension PomodoroSessionLocalModelQueryProperty
    on
        QueryBuilder<
          PomodoroSessionLocalModel,
          PomodoroSessionLocalModel,
          QQueryProperty
        > {
  QueryBuilder<PomodoroSessionLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, int, QQueryOperations>
  actualDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, DateTime?, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, bool, QQueryOperations>
  isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, DateTime, QQueryOperations>
  localUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localUpdatedAt');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, int, QQueryOperations>
  plannedDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, String, QQueryOperations>
  sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, DateTime, QQueryOperations>
  startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSyncStatusLocal,
    QQueryOperations
  >
  syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<PomodoroSessionLocalModel, String?, QQueryOperations>
  taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }

  QueryBuilder<
    PomodoroSessionLocalModel,
    PomodoroSessionTypeLocal,
    QQueryOperations
  >
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
