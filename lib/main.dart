import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/services/supabase_service.dart';
import 'presentation/screens/auth_email_password_screen.dart';
import 'presentation/screens/authenticated_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    // Keep app startup alive so users can still reach fallback UI.
    debugPrint('dotenv load skipped: $error');
  }
  await SupabaseService.initialize();

  runApp(const BillMateApp());
}

class BillMateApp extends StatelessWidget {
  const BillMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3C4BD1),
          surface: const Color(0xFFF9F5FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F5FF),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        useMaterial3: true,
      ),
      home: const _AppHome(),
    );
  }
}

class _AppHome extends StatelessWidget {
  const _AppHome();

  @override
  Widget build(BuildContext context) {
    if (!SupabaseService.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Supabase configuration missing. Update .env before using auth.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session =
            snapshot.data?.session ?? SupabaseService.client.auth.currentSession;

        if (session == null) {
          return const AuthEmailPasswordScreen();
        }

        return AuthenticatedHomeScreen(user: session.user);
      },
    );
  }
}
