// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_snapshot_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStatisticsSnapshotLocalModelCollection on Isar {
  IsarCollection<StatisticsSnapshotLocalModel>
  get statisticsSnapshotLocalModels => this.collection();
}

const StatisticsSnapshotLocalModelSchema = CollectionSchema(
  name: r'StatisticsSnapshotLocalModel',
  id: -7559221390097419682,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(id: 1, name: r'date', type: IsarType.dateTime),
    r'habitsCompletedCount': PropertySchema(
      id: 2,
      name: r'habitsCompletedCount',
      type: IsarType.long,
    ),
    r'habitsTotalCount': PropertySchema(
      id: 3,
      name: r'habitsTotalCount',
      type: IsarType.long,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 4,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'localUpdatedAt': PropertySchema(
      id: 5,
      name: r'localUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'pomodoroSessionsCompleted': PropertySchema(
      id: 6,
      name: r'pomodoroSessionsCompleted',
      type: IsarType.long,
    ),
    r'pomodoroTotalMinutes': PropertySchema(
      id: 7,
      name: r'pomodoroTotalMinutes',
      type: IsarType.long,
    ),
    r'snapshotId': PropertySchema(
      id: 8,
      name: r'snapshotId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 9,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _StatisticsSnapshotLocalModelsyncStatusEnumValueMap,
    ),
    r'tasksCompleted': PropertySchema(
      id: 10,
      name: r'tasksCompleted',
      type: IsarType.long,
    ),
    r'tasksCreated': PropertySchema(
      id: 11,
      name: r'tasksCreated',
      type: IsarType.long,
    ),
  },

  estimateSize: _statisticsSnapshotLocalModelEstimateSize,
  serialize: _statisticsSnapshotLocalModelSerialize,
  deserialize: _statisticsSnapshotLocalModelDeserialize,
  deserializeProp: _statisticsSnapshotLocalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'snapshotId': IndexSchema(
      id: -7574188874426247601,
      name: r'snapshotId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'snapshotId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _statisticsSnapshotLocalModelGetId,
  getLinks: _statisticsSnapshotLocalModelGetLinks,
  attach: _statisticsSnapshotLocalModelAttach,
  version: '3.3.2',
);

int _statisticsSnapshotLocalModelEstimateSize(
  StatisticsSnapshotLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.snapshotId.length * 3;
  bytesCount += 3 + object.syncStatus.name.length * 3;
  return bytesCount;
}

void _statisticsSnapshotLocalModelSerialize(
  StatisticsSnapshotLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeLong(offsets[2], object.habitsCompletedCount);
  writer.writeLong(offsets[3], object.habitsTotalCount);
  writer.writeDateTime(offsets[4], object.lastSyncedAt);
  writer.writeDateTime(offsets[5], object.localUpdatedAt);
  writer.writeLong(offsets[6], object.pomodoroSessionsCompleted);
  writer.writeLong(offsets[7], object.pomodoroTotalMinutes);
  writer.writeString(offsets[8], object.snapshotId);
  writer.writeString(offsets[9], object.syncStatus.name);
  writer.writeLong(offsets[10], object.tasksCompleted);
  writer.writeLong(offsets[11], object.tasksCreated);
}

StatisticsSnapshotLocalModel _statisticsSnapshotLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StatisticsSnapshotLocalModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.habitsCompletedCount = reader.readLong(offsets[2]);
  object.habitsTotalCount = reader.readLong(offsets[3]);
  object.id = id;
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[4]);
  object.localUpdatedAt = reader.readDateTime(offsets[5]);
  object.pomodoroSessionsCompleted = reader.readLong(offsets[6]);
  object.pomodoroTotalMinutes = reader.readLong(offsets[7]);
  object.snapshotId = reader.readString(offsets[8]);
  object.syncStatus =
      _StatisticsSnapshotLocalModelsyncStatusValueEnumMap[reader
          .readStringOrNull(offsets[9])] ??
      StatisticsSyncStatusLocal.synced;
  object.tasksCompleted = reader.readLong(offsets[10]);
  object.tasksCreated = reader.readLong(offsets[11]);
  return object;
}

P _statisticsSnapshotLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (_StatisticsSnapshotLocalModelsyncStatusValueEnumMap[reader
                  .readStringOrNull(offset)] ??
              StatisticsSyncStatusLocal.synced)
          as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _StatisticsSnapshotLocalModelsyncStatusEnumValueMap = {
  r'synced': r'synced',
  r'pendingCreate': r'pendingCreate',
  r'error': r'error',
};
const _StatisticsSnapshotLocalModelsyncStatusValueEnumMap = {
  r'synced': StatisticsSyncStatusLocal.synced,
  r'pendingCreate': StatisticsSyncStatusLocal.pendingCreate,
  r'error': StatisticsSyncStatusLocal.error,
};

Id _statisticsSnapshotLocalModelGetId(StatisticsSnapshotLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _statisticsSnapshotLocalModelGetLinks(
  StatisticsSnapshotLocalModel object,
) {
  return [];
}

void _statisticsSnapshotLocalModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  StatisticsSnapshotLocalModel object,
) {
  object.id = id;
}

extension StatisticsSnapshotLocalModelByIndex
    on IsarCollection<StatisticsSnapshotLocalModel> {
  Future<StatisticsSnapshotLocalModel?> getBySnapshotId(String snapshotId) {
    return getByIndex(r'snapshotId', [snapshotId]);
  }

  StatisticsSnapshotLocalModel? getBySnapshotIdSync(String snapshotId) {
    return getByIndexSync(r'snapshotId', [snapshotId]);
  }

  Future<bool> deleteBySnapshotId(String snapshotId) {
    return deleteByIndex(r'snapshotId', [snapshotId]);
  }

  bool deleteBySnapshotIdSync(String snapshotId) {
    return deleteByIndexSync(r'snapshotId', [snapshotId]);
  }

  Future<List<StatisticsSnapshotLocalModel?>> getAllBySnapshotId(
    List<String> snapshotIdValues,
  ) {
    final values = snapshotIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'snapshotId', values);
  }

  List<StatisticsSnapshotLocalModel?> getAllBySnapshotIdSync(
    List<String> snapshotIdValues,
  ) {
    final values = snapshotIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'snapshotId', values);
  }

  Future<int> deleteAllBySnapshotId(List<String> snapshotIdValues) {
    final values = snapshotIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'snapshotId', values);
  }

  int deleteAllBySnapshotIdSync(List<String> snapshotIdValues) {
    final values = snapshotIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'snapshotId', values);
  }

  Future<Id> putBySnapshotId(StatisticsSnapshotLocalModel object) {
    return putByIndex(r'snapshotId', object);
  }

  Id putBySnapshotIdSync(
    StatisticsSnapshotLocalModel object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'snapshotId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySnapshotId(
    List<StatisticsSnapshotLocalModel> objects,
  ) {
    return putAllByIndex(r'snapshotId', objects);
  }

  List<Id> putAllBySnapshotIdSync(
    List<StatisticsSnapshotLocalModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'snapshotId', objects, saveLinks: saveLinks);
  }
}

extension StatisticsSnapshotLocalModelQueryWhereSort
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QWhere
        > {
  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhere
  >
  anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension StatisticsSnapshotLocalModelQueryWhere
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QWhereClause
        > {
  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  snapshotIdEqualTo(String snapshotId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'snapshotId', value: [snapshotId]),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  snapshotIdNotEqualTo(String snapshotId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'snapshotId',
                lower: [],
                upper: [snapshotId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'snapshotId',
                lower: [snapshotId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'snapshotId',
                lower: [snapshotId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'snapshotId',
                lower: [],
                upper: [snapshotId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'date', value: [date]),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  dateGreaterThan(DateTime date, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [date],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  dateLessThan(DateTime date, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [],
          upper: [date],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterWhereClause
  >
  dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [lowerDate],
          includeLower: includeLower,
          upper: [upperDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StatisticsSnapshotLocalModelQueryFilter
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QFilterCondition
        > {
  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsCompletedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'habitsCompletedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsCompletedCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'habitsCompletedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsCompletedCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'habitsCompletedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsCompletedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'habitsCompletedCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsTotalCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'habitsTotalCount', value: value),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsTotalCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'habitsTotalCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsTotalCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'habitsTotalCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  habitsTotalCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'habitsTotalCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroSessionsCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pomodoroSessionsCompleted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroSessionsCompletedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pomodoroSessionsCompleted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroSessionsCompletedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pomodoroSessionsCompleted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroSessionsCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pomodoroSessionsCompleted',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroTotalMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pomodoroTotalMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroTotalMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pomodoroTotalMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroTotalMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pomodoroTotalMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  pomodoroTotalMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pomodoroTotalMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'snapshotId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'snapshotId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'snapshotId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'snapshotId',
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'snapshotId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'snapshotId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'snapshotId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'snapshotId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'snapshotId', value: ''),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  snapshotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'snapshotId', value: ''),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  syncStatusEqualTo(
    StatisticsSyncStatusLocal value, {
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  syncStatusGreaterThan(
    StatisticsSyncStatusLocal value, {
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  syncStatusLessThan(
    StatisticsSyncStatusLocal value, {
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  syncStatusBetween(
    StatisticsSyncStatusLocal lower,
    StatisticsSyncStatusLocal upper, {
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
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
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tasksCompleted', value: value),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCompletedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tasksCompleted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCompletedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tasksCompleted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tasksCompleted',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCreatedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tasksCreated', value: value),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCreatedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tasksCreated',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCreatedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tasksCreated',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterFilterCondition
  >
  tasksCreatedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tasksCreated',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StatisticsSnapshotLocalModelQueryObject
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QFilterCondition
        > {}

extension StatisticsSnapshotLocalModelQueryLinks
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QFilterCondition
        > {}

extension StatisticsSnapshotLocalModelQuerySortBy
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QSortBy
        > {
  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByHabitsCompletedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsCompletedCount', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByHabitsCompletedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsCompletedCount', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByHabitsTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsTotalCount', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByHabitsTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsTotalCount', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByPomodoroSessionsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessionsCompleted', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByPomodoroSessionsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessionsCompleted', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByPomodoroTotalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroTotalMinutes', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByPomodoroTotalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroTotalMinutes', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortBySnapshotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotId', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortBySnapshotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotId', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByTasksCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  sortByTasksCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.desc);
    });
  }
}

extension StatisticsSnapshotLocalModelQuerySortThenBy
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QSortThenBy
        > {
  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByHabitsCompletedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsCompletedCount', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByHabitsCompletedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsCompletedCount', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByHabitsTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsTotalCount', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByHabitsTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitsTotalCount', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByPomodoroSessionsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessionsCompleted', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByPomodoroSessionsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessionsCompleted', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByPomodoroTotalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroTotalMinutes', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByPomodoroTotalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroTotalMinutes', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenBySnapshotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotId', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenBySnapshotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snapshotId', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByTasksCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.asc);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QAfterSortBy
  >
  thenByTasksCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCreated', Sort.desc);
    });
  }
}

extension StatisticsSnapshotLocalModelQueryWhereDistinct
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QDistinct
        > {
  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByHabitsCompletedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitsCompletedCount');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByHabitsTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitsTotalCount');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localUpdatedAt');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByPomodoroSessionsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroSessionsCompleted');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByPomodoroTotalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroTotalMinutes');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctBySnapshotId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snapshotId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasksCompleted');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSnapshotLocalModel,
    QDistinct
  >
  distinctByTasksCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasksCreated');
    });
  }
}

extension StatisticsSnapshotLocalModelQueryProperty
    on
        QueryBuilder<
          StatisticsSnapshotLocalModel,
          StatisticsSnapshotLocalModel,
          QQueryProperty
        > {
  QueryBuilder<StatisticsSnapshotLocalModel, int, QQueryOperations>
  idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, DateTime, QQueryOperations>
  dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, int, QQueryOperations>
  habitsCompletedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitsCompletedCount');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, int, QQueryOperations>
  habitsTotalCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitsTotalCount');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, DateTime, QQueryOperations>
  localUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localUpdatedAt');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, int, QQueryOperations>
  pomodoroSessionsCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroSessionsCompleted');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, int, QQueryOperations>
  pomodoroTotalMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroTotalMinutes');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, String, QQueryOperations>
  snapshotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snapshotId');
    });
  }

  QueryBuilder<
    StatisticsSnapshotLocalModel,
    StatisticsSyncStatusLocal,
    QQueryOperations
  >
  syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, int, QQueryOperations>
  tasksCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasksCompleted');
    });
  }

  QueryBuilder<StatisticsSnapshotLocalModel, int, QQueryOperations>
  tasksCreatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasksCreated');
    });
  }
}
