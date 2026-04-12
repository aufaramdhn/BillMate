import 'package:billmate/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthGateway implements AuthGateway {
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  int signInGoogleCalls = 0;

  String? lastEmail;
  String? lastPassword;

  bool requiresEmailConfirmation = true;
  bool googleSignInResult = true;
  bool throwOnSignIn = false;

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;

    if (throwOnSignIn) {
      throw StateError('sign in failed');
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    signInGoogleCalls++;
    return googleSignInResult;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    lastEmail = email;
    lastPassword = password;
    return requiresEmailConfirmation;
  }
}

void main() {
  group('AuthRepository', () {
    test('delegates email sign-in to gateway', () async {
      final gateway = _FakeAuthGateway();
      final repository = AuthRepository(gateway: gateway);

      await repository.signInWithEmailPassword(
        email: 'test@example.com',
        password: 'secret123',
      );

      expect(gateway.signInCalls, 1);
      expect(gateway.lastEmail, 'test@example.com');
      expect(gateway.lastPassword, 'secret123');
    });

    test('returns confirmation requirement from sign-up', () async {
      final gateway = _FakeAuthGateway()..requiresEmailConfirmation = false;
      final repository = AuthRepository(gateway: gateway);

      final result = await repository.signUpWithEmailPassword(
        email: 'test@example.com',
        password: 'secret123',
      );

      expect(gateway.signUpCalls, 1);
      expect(result, isFalse);
    });

    test('delegates google sign-in', () async {
      final gateway = _FakeAuthGateway()..googleSignInResult = true;
      final repository = AuthRepository(gateway: gateway);

      final result = await repository.signInWithGoogle();

      expect(gateway.signInGoogleCalls, 1);
      expect(result, isTrue);
    });

    test('delegates sign-out', () async {
      final gateway = _FakeAuthGateway();
      final repository = AuthRepository(gateway: gateway);

      await repository.signOut();

      expect(gateway.signOutCalls, 1);
    });

    test('propagates sign-in error', () async {
      final gateway = _FakeAuthGateway()..throwOnSignIn = true;
      final repository = AuthRepository(gateway: gateway);

      expect(
        () => repository.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'secret123',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
