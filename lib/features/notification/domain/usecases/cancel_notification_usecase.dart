import '../repositories/notification_repository.dart';

class CancelNotificationUseCase {
  const CancelNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call(int id) => _repository.cancelNotification(id);
}
