// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsLocalModelCollection on Isar {
  IsarCollection<SettingsLocalModel> get settingsLocalModels =>
      this.collection();
}

const SettingsLocalModelSchema = CollectionSchema(
  name: r'SettingsLocalModel',
  id: -7215758362110481024,
  properties: {
    r'habitRemindersEnabled': PropertySchema(
      id: 0,
      name: r'habitRemindersEnabled',
      type: IsarType.bool,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 1,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'localUpdatedAt': PropertySchema(
      id: 2,
      name: r'localUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 3,
      name: r'notificationsEnabled',
      type: IsarType.bool,
    ),
    r'pomodoroNotificationsEnabled': PropertySchema(
      id: 4,
      name: r'pomodoroNotificationsEnabled',
      type: IsarType.bool,
    ),
    r'syncStatus': PropertySchema(
      id: 5,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _SettingsLocalModelsyncStatusEnumValueMap,
    ),
    r'taskRemindersEnabled': PropertySchema(
      id: 6,
      name: r'taskRemindersEnabled',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 7,
      name: r'themeMode',
      type: IsarType.string,
    ),
  },

  estimateSize: _settingsLocalModelEstimateSize,
  serialize: _settingsLocalModelSerialize,
  deserialize: _settingsLocalModelDeserialize,
  deserializeProp: _settingsLocalModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _settingsLocalModelGetId,
  getLinks: _settingsLocalModelGetLinks,
  attach: _settingsLocalModelAttach,
  version: '3.3.2',
);

int _settingsLocalModelEstimateSize(
  SettingsLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.syncStatus.name.length * 3;
  bytesCount += 3 + object.themeMode.length * 3;
  return bytesCount;
}

void _settingsLocalModelSerialize(
  SettingsLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.habitRemindersEnabled);
  writer.writeDateTime(offsets[1], object.lastSyncedAt);
  writer.writeDateTime(offsets[2], object.localUpdatedAt);
  writer.writeBool(offsets[3], object.notificationsEnabled);
  writer.writeBool(offsets[4], object.pomodoroNotificationsEnabled);
  writer.writeString(offsets[5], object.syncStatus.name);
  writer.writeBool(offsets[6], object.taskRemindersEnabled);
  writer.writeString(offsets[7], object.themeMode);
}

SettingsLocalModel _settingsLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsLocalModel();
  object.habitRemindersEnabled = reader.readBool(offsets[0]);
  object.id = id;
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[1]);
  object.localUpdatedAt = reader.readDateTime(offsets[2]);
  object.notificationsEnabled = reader.readBool(offsets[3]);
  object.pomodoroNotificationsEnabled = reader.readBool(offsets[4]);
  object.syncStatus =
      _SettingsLocalModelsyncStatusValueEnumMap[reader.readStringOrNull(
        offsets[5],
      )] ??
      SettingsSyncStatusLocal.synced;
  object.taskRemindersEnabled = reader.readBool(offsets[6]);
  object.themeMode = reader.readString(offsets[7]);
  return object;
}

P _settingsLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (_SettingsLocalModelsyncStatusValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SettingsSyncStatusLocal.synced)
          as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsLocalModelsyncStatusEnumValueMap = {
  r'synced': r'synced',
  r'pendingUpdate': r'pendingUpdate',
  r'error': r'error',
};
const _SettingsLocalModelsyncStatusValueEnumMap = {
  r'synced': SettingsSyncStatusLocal.synced,
  r'pendingUpdate': SettingsSyncStatusLocal.pendingUpdate,
  r'error': SettingsSyncStatusLocal.error,
};

Id _settingsLocalModelGetId(SettingsLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsLocalModelGetLinks(
  SettingsLocalModel object,
) {
  return [];
}

void _settingsLocalModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  SettingsLocalModel object,
) {
  object.id = id;
}

extension SettingsLocalModelQueryWhereSort
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QWhere> {
  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsLocalModelQueryWhere
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QWhereClause> {
  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterWhereClause>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterWhereClause>
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
}

extension SettingsLocalModelQueryFilter
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QFilterCondition> {
  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  habitRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'habitRemindersEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  localUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  notificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notificationsEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  pomodoroNotificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pomodoroNotificationsEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  syncStatusEqualTo(
    SettingsSyncStatusLocal value, {
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  syncStatusGreaterThan(
    SettingsSyncStatusLocal value, {
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  syncStatusLessThan(
    SettingsSyncStatusLocal value, {
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  syncStatusBetween(
    SettingsSyncStatusLocal lower,
    SettingsSyncStatusLocal upper, {
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  taskRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'taskRemindersEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themeMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'themeMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themeMode', value: ''),
      );
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterFilterCondition>
  themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'themeMode', value: ''),
      );
    });
  }
}

extension SettingsLocalModelQueryObject
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QFilterCondition> {}

extension SettingsLocalModelQueryLinks
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QFilterCondition> {}

extension SettingsLocalModelQuerySortBy
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QSortBy> {
  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByHabitRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByHabitRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByPomodoroNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByPomodoroNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByTaskRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByTaskRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension SettingsLocalModelQuerySortThenBy
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QSortThenBy> {
  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByHabitRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByHabitRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByPomodoroNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByPomodoroNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByTaskRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByTaskRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QAfterSortBy>
  thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension SettingsLocalModelQueryWhereDistinct
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct> {
  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctByHabitRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitRemindersEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localUpdatedAt');
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationsEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctByPomodoroNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroNotificationsEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctByTaskRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskRemindersEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsLocalModel, QDistinct>
  distinctByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }
}

extension SettingsLocalModelQueryProperty
    on QueryBuilder<SettingsLocalModel, SettingsLocalModel, QQueryProperty> {
  QueryBuilder<SettingsLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsLocalModel, bool, QQueryOperations>
  habitRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitRemindersEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<SettingsLocalModel, DateTime, QQueryOperations>
  localUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localUpdatedAt');
    });
  }

  QueryBuilder<SettingsLocalModel, bool, QQueryOperations>
  notificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationsEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, bool, QQueryOperations>
  pomodoroNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroNotificationsEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, SettingsSyncStatusLocal, QQueryOperations>
  syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<SettingsLocalModel, bool, QQueryOperations>
  taskRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskRemindersEnabled');
    });
  }

  QueryBuilder<SettingsLocalModel, String, QQueryOperations>
  themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }
}
