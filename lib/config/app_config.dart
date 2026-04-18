import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'BillMate - Sprint 1 Foundation';
  static const String demoUserId = 'demo-user-id';

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
}
