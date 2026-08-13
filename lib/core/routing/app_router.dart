import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/activity_screen.dart';
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
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.initial,
    debugLogDiagnostics: false,
    routes: [
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
