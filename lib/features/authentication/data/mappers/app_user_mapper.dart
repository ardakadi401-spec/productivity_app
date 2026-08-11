import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';

class AppUserMapper {
  AppUserMapper._();

  static AppUser toEntity(AppUserModel model) {
    return AppUser(
      uid: model.userId,
      email: model.email,
      name: model.name,
      photoUrl: model.photoUrl,
      authProvider: model.authProvider == 'google'
          ? AuthProviderType.google
          : AuthProviderType.email,
    );
  }
}
