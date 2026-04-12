import '../services/auth_service.dart';

abstract class AuthGateway {
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  Future<bool> signInWithGoogle();

  Future<void> signOut();
}

class SupabaseAuthGateway implements AuthGateway {
  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await AuthService.signInWithEmailPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await AuthService.signUpWithEmailPassword(
      email: email,
      password: password,
    );

    return response.session == null;
  }

  @override
  Future<bool> signInWithGoogle() {
    return AuthService.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return AuthService.signOut();
  }
}

class AuthRepository {
  AuthRepository({AuthGateway? gateway})
      : _gateway = gateway ?? SupabaseAuthGateway();

  final AuthGateway _gateway;

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _gateway.signInWithEmailPassword(
      email: email,
      password: password,
    );
  }

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _gateway.signUpWithEmailPassword(
      email: email,
      password: password,
    );
  }

  Future<bool> signInWithGoogle() {
    return _gateway.signInWithGoogle();
  }

  Future<void> signOut() {
    return _gateway.signOut();
  }
}
