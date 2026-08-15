import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/activity_screen.dart';
import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/data/auth_state.dart';
import '../../features/auth/data/onboarding_controller.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/cards/cards_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/transactions/transaction_details_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The app's router.
///
/// A single [StatefulShellRoute] holds the four top-level tabs so each keeps
/// its own navigation stack behind the shared bottom bar. Transaction details
/// is nested inside the transactions branch, so pushing it keeps the bar in
/// place and popping returns to the feed at its previous scroll position.
///
/// Splash, Onboarding, Login, Sign Up and Forgot Password sit outside the
/// shell — they have no bottom navigation — and [_redirect] is what keeps an
/// unauthenticated visitor out of the four protected tabs.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.initial,
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branch(AppRoutes.home, const HomeScreen()),
          _branch(AppRoutes.cards, const CardsScreen()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.transactionDetailsSegment,
                    builder: (context, state) => TransactionDetailsScreen(
                      transactionId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _branch(AppRoutes.activity, const ActivityScreen()),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(String path, Widget child) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => child)],
  );
}

/// The auth guard.
///
/// Splash is exempt — it decides its own destination once its entrance
/// animation finishes, and re-evaluating this on every one of its rebuilds
/// would fight that timing. Everything else follows two rules: an
/// authenticated visitor is bounced off the auth/onboarding screens to Home,
/// and an unauthenticated one is bounced off the protected tabs to either
/// Onboarding (first time) or Login (returning).
String? _redirect(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;
  if (location == AppRoutes.splash) return null;

  final isAuthenticated =
      ref.read(authControllerProvider).status == AuthStatus.authenticated;
  final onboarded = ref.read(onboardingCompleteProvider);

  final isAuthRoute =
      location == AppRoutes.login ||
      location == AppRoutes.signUp ||
      location == AppRoutes.forgotPassword;
  final isOnboarding = location == AppRoutes.onboarding;

  if (isAuthenticated) {
    return (isAuthRoute || isOnboarding) ? AppRoutes.home : null;
  }

  if (isAuthRoute || isOnboarding) return null;
  return onboarded ? AppRoutes.login : AppRoutes.onboarding;
}

/// Bridges Riverpod's [authControllerProvider] to GoRouter's polling model —
/// GoRouter only re-runs [_redirect] when told to, so a logout while sitting
/// on a protected screen needs this to actually be kicked to Login.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (previous?.status != next.status) notifyListeners();
      },
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
