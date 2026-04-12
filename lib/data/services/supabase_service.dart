import '../../config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase is not initialized.');
    }

    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (!AppConfig.hasSupabaseConfig) {
      return;
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    _initialized = true;
  }

  static Stream<AuthState> authStateChanges() {
    if (!_initialized) {
      return const Stream<AuthState>.empty();
    }

    return client.auth.onAuthStateChange;
  }
}
