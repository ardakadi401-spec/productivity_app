import '../repositories/notification_repository.dart';

class RequestNotificationPermissionUseCase {
  const RequestNotificationPermissionUseCase(this._repository);

  final NotificationRepository _repository;

  Future<bool> call() => _repository.requestPermission();
}
