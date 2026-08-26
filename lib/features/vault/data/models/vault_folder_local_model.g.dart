// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_folder_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVaultFolderLocalModelCollection on Isar {
  IsarCollection<VaultFolderLocalModel> get vaultFolderLocalModels =>
      this.collection();
}

const VaultFolderLocalModelSchema = CollectionSchema(
  name: r'VaultFolderLocalModel',
  id: 2834959538275981599,
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
    r'folderId': PropertySchema(
      id: 2,
      name: r'folderId',
      type: IsarType.string,
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
    r'name': PropertySchema(id: 6, name: r'name', type: IsarType.string),
    r'parentFolderId': PropertySchema(
      id: 7,
      name: r'parentFolderId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 8,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _VaultFolderLocalModelsyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _vaultFolderLocalModelEstimateSize,
  serialize: _vaultFolderLocalModelSerialize,
  deserialize: _vaultFolderLocalModelDeserialize,
  deserializeProp: _vaultFolderLocalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'folderId': IndexSchema(
      id: 6340065978996931043,
      name: r'folderId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'folderId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'parentFolderId': IndexSchema(
      id: -8947968903566032810,
      name: r'parentFolderId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'parentFolderId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _vaultFolderLocalModelGetId,
  getLinks: _vaultFolderLocalModelGetLinks,
  attach: _vaultFolderLocalModelAttach,
  version: '3.3.2',
);

int _vaultFolderLocalModelEstimateSize(
  VaultFolderLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.folderId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.parentFolderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncStatus.name.length * 3;
  return bytesCount;
}

void _vaultFolderLocalModelSerialize(
  VaultFolderLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeString(offsets[2], object.folderId);
  writer.writeBool(offsets[3], object.isDeleted);
  writer.writeDateTime(offsets[4], object.lastSyncedAt);
  writer.writeDateTime(offsets[5], object.localUpdatedAt);
  writer.writeString(offsets[6], object.name);
  writer.writeString(offsets[7], object.parentFolderId);
  writer.writeString(offsets[8], object.syncStatus.name);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

VaultFolderLocalModel _vaultFolderLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VaultFolderLocalModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.folderId = reader.readString(offsets[2]);
  object.id = id;
  object.isDeleted = reader.readBool(offsets[3]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[4]);
  object.localUpdatedAt = reader.readDateTime(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.parentFolderId = reader.readStringOrNull(offsets[7]);
  object.syncStatus =
      _VaultFolderLocalModelsyncStatusValueEnumMap[reader.readStringOrNull(
        offsets[8],
      )] ??
      VaultFolderSyncStatusLocal.synced;
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _vaultFolderLocalModelDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (_VaultFolderLocalModelsyncStatusValueEnumMap[reader
                  .readStringOrNull(offset)] ??
              VaultFolderSyncStatusLocal.synced)
          as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _VaultFolderLocalModelsyncStatusEnumValueMap = {
  r'synced': r'synced',
  r'pendingCreate': r'pendingCreate',
  r'pendingUpdate': r'pendingUpdate',
  r'pendingDelete': r'pendingDelete',
  r'error': r'error',
};
const _VaultFolderLocalModelsyncStatusValueEnumMap = {
  r'synced': VaultFolderSyncStatusLocal.synced,
  r'pendingCreate': VaultFolderSyncStatusLocal.pendingCreate,
  r'pendingUpdate': VaultFolderSyncStatusLocal.pendingUpdate,
  r'pendingDelete': VaultFolderSyncStatusLocal.pendingDelete,
  r'error': VaultFolderSyncStatusLocal.error,
};

Id _vaultFolderLocalModelGetId(VaultFolderLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vaultFolderLocalModelGetLinks(
  VaultFolderLocalModel object,
) {
  return [];
}

void _vaultFolderLocalModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  VaultFolderLocalModel object,
) {
  object.id = id;
}

extension VaultFolderLocalModelByIndex
    on IsarCollection<VaultFolderLocalModel> {
  Future<VaultFolderLocalModel?> getByFolderId(String folderId) {
    return getByIndex(r'folderId', [folderId]);
  }

  VaultFolderLocalModel? getByFolderIdSync(String folderId) {
    return getByIndexSync(r'folderId', [folderId]);
  }

  Future<bool> deleteByFolderId(String folderId) {
    return deleteByIndex(r'folderId', [folderId]);
  }

  bool deleteByFolderIdSync(String folderId) {
    return deleteByIndexSync(r'folderId', [folderId]);
  }

  Future<List<VaultFolderLocalModel?>> getAllByFolderId(
    List<String> folderIdValues,
  ) {
    final values = folderIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'folderId', values);
  }

  List<VaultFolderLocalModel?> getAllByFolderIdSync(
    List<String> folderIdValues,
  ) {
    final values = folderIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'folderId', values);
  }

  Future<int> deleteAllByFolderId(List<String> folderIdValues) {
    final values = folderIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'folderId', values);
  }

  int deleteAllByFolderIdSync(List<String> folderIdValues) {
    final values = folderIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'folderId', values);
  }

  Future<Id> putByFolderId(VaultFolderLocalModel object) {
    return putByIndex(r'folderId', object);
  }

  Id putByFolderIdSync(VaultFolderLocalModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'folderId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFolderId(List<VaultFolderLocalModel> objects) {
    return putAllByIndex(r'folderId', objects);
  }

  List<Id> putAllByFolderIdSync(
    List<VaultFolderLocalModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'folderId', objects, saveLinks: saveLinks);
  }
}

extension VaultFolderLocalModelQueryWhereSort
    on QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QWhere> {
  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VaultFolderLocalModelQueryWhere
    on
        QueryBuilder<
          VaultFolderLocalModel,
          VaultFolderLocalModel,
          QWhereClause
        > {
  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
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

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
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

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  folderIdEqualTo(String folderId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'folderId', value: [folderId]),
      );
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  folderIdNotEqualTo(String folderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [],
                upper: [folderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [folderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [folderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [],
                upper: [folderId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  parentFolderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'parentFolderId', value: [null]),
      );
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  parentFolderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'parentFolderId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  parentFolderIdEqualTo(String? parentFolderId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'parentFolderId',
          value: [parentFolderId],
        ),
      );
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterWhereClause>
  parentFolderIdNotEqualTo(String? parentFolderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentFolderId',
                lower: [],
                upper: [parentFolderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentFolderId',
                lower: [parentFolderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentFolderId',
                lower: [parentFolderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentFolderId',
                lower: [],
                upper: [parentFolderId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension VaultFolderLocalModelQueryFilter
    on
        QueryBuilder<
          VaultFolderLocalModel,
          VaultFolderLocalModel,
          QFilterCondition
        > {
  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'folderId',
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'folderId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'folderId', value: ''),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  folderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'folderId', value: ''),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDeleted', value: value),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parentFolderId'),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parentFolderId'),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parentFolderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parentFolderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parentFolderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parentFolderId',
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parentFolderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parentFolderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parentFolderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parentFolderId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentFolderId', value: ''),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  parentFolderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parentFolderId', value: ''),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  syncStatusEqualTo(
    VaultFolderSyncStatusLocal value, {
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  syncStatusGreaterThan(
    VaultFolderSyncStatusLocal value, {
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  syncStatusLessThan(
    VaultFolderSyncStatusLocal value, {
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  syncStatusBetween(
    VaultFolderSyncStatusLocal lower,
    VaultFolderSyncStatusLocal upper, {
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
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
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderLocalModel,
    QAfterFilterCondition
  >
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

extension VaultFolderLocalModelQueryObject
    on
        QueryBuilder<
          VaultFolderLocalModel,
          VaultFolderLocalModel,
          QFilterCondition
        > {}

extension VaultFolderLocalModelQueryLinks
    on
        QueryBuilder<
          VaultFolderLocalModel,
          VaultFolderLocalModel,
          QFilterCondition
        > {}

extension VaultFolderLocalModelQuerySortBy
    on QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QSortBy> {
  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByParentFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByParentFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension VaultFolderLocalModelQuerySortThenBy
    on QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QSortThenBy> {
  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByLocalUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByParentFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByParentFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentFolderId', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension VaultFolderLocalModelQueryWhereDistinct
    on QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct> {
  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByFolderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByLocalUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localUpdatedAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByParentFolderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'parentFolderId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultFolderLocalModel, VaultFolderLocalModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension VaultFolderLocalModelQueryProperty
    on
        QueryBuilder<
          VaultFolderLocalModel,
          VaultFolderLocalModel,
          QQueryProperty
        > {
  QueryBuilder<VaultFolderLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VaultFolderLocalModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, String, QQueryOperations>
  folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folderId');
    });
  }

  QueryBuilder<VaultFolderLocalModel, bool, QQueryOperations>
  isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<VaultFolderLocalModel, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, DateTime, QQueryOperations>
  localUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localUpdatedAt');
    });
  }

  QueryBuilder<VaultFolderLocalModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<VaultFolderLocalModel, String?, QQueryOperations>
  parentFolderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentFolderId');
    });
  }

  QueryBuilder<
    VaultFolderLocalModel,
    VaultFolderSyncStatusLocal,
    QQueryOperations
  >
  syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<VaultFolderLocalModel, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
