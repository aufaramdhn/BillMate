import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

class AuthService {
  static const String _supabaseRedirectUrl =
      'io.supabase.flutter://signin-callback/';

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

  static Future<bool> signInWithGoogle() {
    return SupabaseService.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : _supabaseRedirectUrl,
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  static Future<void> signOut() {
    return SupabaseService.client.auth.signOut();
  }
}
