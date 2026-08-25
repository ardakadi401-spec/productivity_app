// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_task_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubTaskLocalModelCollection on Isar {
  IsarCollection<SubTaskLocalModel> get subTaskLocalModels => this.collection();
}

const SubTaskLocalModelSchema = CollectionSchema(
  name: r'SubTaskLocalModel',
  id: 6336119140230766310,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 2,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isDeleted': PropertySchema(
      id: 3,
      name: r'isDeleted',
      type: IsarType.bool,
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
    r'order': PropertySchema(id: 6, name: r'order', type: IsarType.long),
    r'subtaskId': PropertySchema(
      id: 7,
      name: r'subtaskId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 8,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _SubTaskLocalModelsyncStatusEnumValueMap,
    ),
    r'taskId': PropertySchema(id: 9, name: r'taskId', type: IsarType.string),
    r'title': PropertySchema(id: 10, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _subTaskLocalModelEstimateSize,
  serialize: _subTaskLocalModelSerialize,
  deserialize: _subTaskLocalModelDeserialize,
  deserializeProp: _subTaskLocalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'subtaskId': IndexSchema(
      id: 7818895549504634059,
      name: r'subtaskId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'subtaskId',
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

  getId: _subTaskLocalModelGetId,
  getLinks: _subTaskLocalModelGetLinks,
  attach: _subTaskLocalModelAttach,
  version: '3.3.2',
);

int _subTaskLocalModelEstimateSize(
  SubTaskLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.subtaskId.length * 3;
  bytesCount += 3 + object.syncStatus.name.length * 3;
  bytesCount += 3 + object.taskId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _subTaskLocalModelSerialize(
  SubTaskLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeBool(offsets[2], object.isCompleted);
  writer.writeBool(offsets[3], object.isDeleted);
  writer.writeDateTime(offsets[4], object.lastSyncedAt);
  writer.writeDateTime(offsets[5], object.localUpdatedAt);
  writer.writeLong(offsets[6], object.order);
  writer.writeString(offsets[7], object.subtaskId);
  writer.writeString(offsets[8], object.syncStatus.name);
  writer.writeString(offsets[9], object.taskId);
  writer.writeString(offsets[10], object.title);
  writer.writeDateTime(offsets[11], object.updatedAt);
}

SubTaskLocalModel _subTaskLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubTaskLocalModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[2]);
  object.isDeleted = reader.readBool(offsets[3]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[4]);
  object.localUpdatedAt = reader.readDateTime(offsets[5]);
  object.order = reader.readLong(offsets[6]);
  object.subtaskId = reader.readString(offsets[7]);
  object.syncStatus =
      _SubTaskLocalModelsyncStatusValueEnumMap[reader.readStringOrNull(
        offsets[8],
      )] ??
      SyncStatusLocal.synced;
  object.taskId = reader.readString(offsets[9]);
  object.title = reader.readString(offsets[10]);
  object.updatedAt = reader.readDateTime(offsets[11]);
  return object;
}

P _subTaskLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_SubTaskLocalModelsyncStatusValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SyncStatusLocal.synced)
          as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SubTaskLocalModelsyncStatusEnumValueMap = {
  r'synced': r'synced',
  r'pendingCreate': r'pendingCreate',
  r'pendingUpdate': r'pendingUpdate',
  r'pendingDelete': r'pendingDelete',
  r'error': r'error',
};
const _SubTaskLocalModelsyncStatusValueEnumMap = {
  r'synced': SyncStatusLocal.synced,
  r'pendingCreate': SyncStatusLocal.pendingCreate,
  r'pendingUpdate': SyncStatusLocal.pendingUpdate,
  r'pendingDelete': SyncStatusLocal.pendingDelete,
  r'error': SyncStatusLocal.error,
};

Id _subTaskLocalModelGetId(SubTaskLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subTaskLocalModelGetLinks(
  SubTaskLocalModel object,
) {
  return [];
}

void _subTaskLocalModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  SubTaskLocalModel object,
) {
  object.id = id;
}

extension SubTaskLocalModelByIndex on IsarCollection<SubTaskLocalModel> {
  Future<SubTaskLocalModel?> getBySubtaskId(String subtaskId) {
    return getByIndex(r'subtaskId', [subtaskId]);
  }

  SubTaskLocalModel? getBySubtaskIdSync(String subtaskId) {
    return getByIndexSync(r'subtaskId', [subtaskId]);
  }

  Future<bool> deleteBySubtaskId(String subtaskId) {
    return deleteByIndex(r'subtaskId', [subtaskId]);
  }

  bool deleteBySubtaskIdSync(String subtaskId) {
    return deleteByIndexSync(r'subtaskId', [subtaskId]);
  }

  Future<List<SubTaskLocalModel?>> getAllBySubtaskId(
    List<String> subtaskIdValues,
  ) {
    final values = subtaskIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'subtaskId', values);
  }

  List<SubTaskLocalModel?> getAllBySubtaskIdSync(List<String> subtaskIdValues) {
    final values = subtaskIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'subtaskId', values);
  }

  Future<int> deleteAllBySubtaskId(List<String> subtaskIdValues) {
    final values = subtaskIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'subtaskId', values);
  }

  int deleteAllBySubtaskIdSync(List<String> subtaskIdValues) {
    final values = subtaskIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'subtaskId', values);
  }

  Future<Id> putBySubtaskId(SubTaskLocalModel object) {
    return putByIndex(r'subtaskId', object);
  }

  Id putBySubtaskIdSync(SubTaskLocalModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'subtaskId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySubtaskId(List<SubTaskLocalModel> objects) {
    return putAllByIndex(r'subtaskId', objects);
  }

  List<Id> putAllBySubtaskIdSync(
    List<SubTaskLocalModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'subtaskId', objects, saveLinks: saveLinks);
  }
}

extension SubTaskLocalModelQueryWhereSort
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QWhere> {
  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubTaskLocalModelQueryWhere
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QWhereClause> {
  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
  subtaskIdEqualTo(String subtaskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'subtaskId', value: [subtaskId]),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
  subtaskIdNotEqualTo(String subtaskId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'subtaskId',
                lower: [],
                upper: [subtaskId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'subtaskId',
                lower: [subtaskId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'subtaskId',
                lower: [subtaskId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'subtaskId',
                lower: [],
                upper: [subtaskId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
  taskIdEqualTo(String taskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'taskId', value: [taskId]),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterWhereClause>
  taskIdNotEqualTo(String taskId) {
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

extension SubTaskLocalModelQueryFilter
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QFilterCondition> {
  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  deletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isCompleted', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDeleted', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  localUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  orderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  orderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'subtaskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subtaskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subtaskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subtaskId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'subtaskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'subtaskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'subtaskId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'subtaskId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subtaskId', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  subtaskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'subtaskId', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  syncStatusEqualTo(SyncStatusLocal value, {bool caseSensitive = true}) {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  syncStatusGreaterThan(
    SyncStatusLocal value, {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  syncStatusLessThan(
    SyncStatusLocal value, {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  syncStatusBetween(
    SyncStatusLocal lower,
    SyncStatusLocal upper, {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  taskIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  taskIdGreaterThan(
    String value, {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  taskIdLessThan(
    String value, {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  taskIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
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

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'taskId', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'taskId', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SubTaskLocalModelQueryObject
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QFilterCondition> {}

extension SubTaskLocalModelQueryLinks
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QFilterCondition> {}

extension SubTaskLocalModelQuerySortBy
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QSortBy> {
  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortBySubtaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtaskId', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortBySubtaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtaskId', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SubTaskLocalModelQuerySortThenBy
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QSortThenBy> {
  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenBySubtaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtaskId', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenBySubtaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtaskId', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SubTaskLocalModelQueryWhereDistinct
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct> {
  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localUpdatedAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctBySubtaskId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtaskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByTaskId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SubTaskLocalModelQueryProperty
    on QueryBuilder<SubTaskLocalModel, SubTaskLocalModel, QQueryProperty> {
  QueryBuilder<SubTaskLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubTaskLocalModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, bool, QQueryOperations>
  isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<SubTaskLocalModel, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<SubTaskLocalModel, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, DateTime, QQueryOperations>
  localUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localUpdatedAt');
    });
  }

  QueryBuilder<SubTaskLocalModel, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<SubTaskLocalModel, String, QQueryOperations>
  subtaskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtaskId');
    });
  }

  QueryBuilder<SubTaskLocalModel, SyncStatusLocal, QQueryOperations>
  syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<SubTaskLocalModel, String, QQueryOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }

  QueryBuilder<SubTaskLocalModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SubTaskLocalModel, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
