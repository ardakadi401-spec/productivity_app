import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

/// PRD.md Bölüm 6.1 — KVKK/Play Store politikaları gereği hesap silme.
/// Bu UseCase FAZ 3'te hazırdır; tetikleyecek Ayarlar ekranı UI'ı FAZ 4+/16'da
/// eklenecektir (bkz. plan "Kapsam Dışı").
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.deleteAccount();
}
