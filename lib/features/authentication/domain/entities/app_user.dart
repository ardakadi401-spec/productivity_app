/// Kullanıcı kimliği — DATABASE.md Bölüm 2.2'deki `users/{uid}` alanlarının
/// Domain katmanı saf temsili (framework/Firebase bağımsız).
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.authProvider,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String name;
  final AuthProviderType authProvider;
  final String? photoUrl;
}

/// DATABASE.md Bölüm 2.2 `authProvider` enum: `google`, `email`.
enum AuthProviderType { google, email }
