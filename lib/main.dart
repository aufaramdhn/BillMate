import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'data/services/onesignal_service.dart';
import 'data/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    // Keep app startup alive so users can still reach fallback UI.
    debugPrint('dotenv load skipped: $error');
  }
  await OneSignalService.initialize();
  await SupabaseService.initialize();

  runApp(const BillMateApp());
}

class BillMateApp extends StatelessWidget {
  const BillMateApp({super.key});

  static final _router = AppRouter.createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routerConfig: _router,
      title: 'BillMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
    );
  }
}
