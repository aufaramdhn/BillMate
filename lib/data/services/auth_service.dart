import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  static Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) {
    return SupabaseService.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() {
    return SupabaseService.client.auth.signOut();
  }
}
