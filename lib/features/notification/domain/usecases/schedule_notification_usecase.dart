import '../entities/notification_request.dart';
import '../repositories/notification_repository.dart';

class ScheduleNotificationUseCase {
  const ScheduleNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call(NotificationRequest request) => _repository.scheduleNotification(request);
}
