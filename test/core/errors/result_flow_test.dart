import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';

/// FAZ 2 tamamlanma kriteri: "Failure/Result yaklaşımı, en az bir örnek
/// (dummy) UseCase üzerinde uçtan uca (hata → Failure → UI state) test
/// edilebiliyor." Bu, gerçek bir feature'a bağlı olmayan, yalnızca
/// ARCHITECTURE.md Bölüm 7.2 hata akışını (Datasource → Repository → UseCase)
/// doğrulayan minimal bir dummy zincirdir.
class _DummyDatasource {
  _DummyDatasource({required this.shouldFail});

  final bool shouldFail;

  Future<int> fetchValue() async {
    if (shouldFail) throw const NetworkException('bağlantı yok');
    return 42;
  }
}

class _DummyRepository {
  _DummyRepository(this._datasource);

  final _DummyDatasource _datasource;

  Future<Result<int>> getValue() async {
    try {
      final value = await _datasource.fetchValue();
      return Ok(value);
    } on AppException catch (e) {
      return Err(NetworkFailure(e.message));
    }
  }
}

class _DummyGetValueUseCase {
  _DummyGetValueUseCase(this._repository);

  final _DummyRepository _repository;

  Future<Result<int>> call() => _repository.getValue();
}

void main() {
  test('Datasource başarılı olduğunda UseCase Ok(value) döndürür', () async {
    final useCase = _DummyGetValueUseCase(_DummyRepository(_DummyDatasource(shouldFail: false)));

    final result = await useCase();

    expect(result, isA<Ok<int>>());
    expect((result as Ok<int>).value, 42);
  });

  test('Datasource NetworkException fırlattığında UseCase Err(NetworkFailure) döndürür', () async {
    final useCase = _DummyGetValueUseCase(_DummyRepository(_DummyDatasource(shouldFail: true)));

    final result = await useCase();

    expect(result, isA<Err<int>>());
    expect((result as Err<int>).failure, isA<NetworkFailure>());
    expect(result.failure.message, 'bağlantı yok');
  });

  test('Presentation, Result tipine göre deterministik şekilde dallanabilir (switch)', () async {
    final okResult = await _DummyGetValueUseCase(_DummyRepository(_DummyDatasource(shouldFail: false)))();
    final errResult = await _DummyGetValueUseCase(_DummyRepository(_DummyDatasource(shouldFail: true)))();

    String describe(Result<int> result) => switch (result) {
          Ok(:final value) => 'value: $value',
          Err(:final failure) => 'error: ${failure.message}',
        };

    expect(describe(okResult), 'value: 42');
    expect(describe(errResult), 'error: bağlantı yok');
  });
}
