import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/services/supabase_service.dart';
import '../presentation/screens/auth_email_password_screen.dart';
import '../presentation/screens/authenticated_home_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/auth',
      refreshListenable: _GoRouterRefreshStream(
        SupabaseService.authStateChanges(),
      ),
      redirect: (context, state) {
        if (!SupabaseService.isInitialized) {
          return state.matchedLocation == '/config' ? null : '/config';
        }

        final hasSession = SupabaseService.client.auth.currentSession != null;
        final inAuth = state.matchedLocation == '/auth';
        final inDashboard = state.matchedLocation == '/dashboard';

        if (!hasSession) {
          return inAuth ? null : '/auth';
        }

        return inDashboard ? null : '/dashboard';
      },
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthEmailPasswordScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            final session = SupabaseService.client.auth.currentSession;
            if (session == null) {
              return const SizedBox.shrink();
            }
            return AuthenticatedHomeScreen(user: session.user);
          },
        ),
        GoRoute(
          path: '/config',
          builder: (context, state) => const _MissingConfigScreen(),
        ),
      ],
    );
  }
}

class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
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
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
