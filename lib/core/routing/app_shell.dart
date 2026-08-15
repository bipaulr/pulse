import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/widgets.dart';
import '../theme/pulse_theme.dart';

/// Chrome shared by every top-level tab: the canvas plus the floating
/// navigation bar. The bar sits over the content ([Scaffold.extendBody]) so
/// scrolled content passes underneath it.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Order must match the branch order in `app_router.dart`.
  static const destinations = <PulseNavigationDestination>[
    PulseNavigationDestination(icon: Icons.grid_view_rounded, label: 'Home'),
    PulseNavigationDestination(
      icon: Icons.credit_card_rounded,
      label: 'Cards',
    ),
    PulseNavigationDestination(
      icon: Icons.swap_horiz_rounded,
      label: 'Transactions',
    ),
    PulseNavigationDestination(
      icon: Icons.pie_chart_rounded,
      label: 'Activity',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pulseColors.background,
      extendBody: true,
      // Pulse is a phone design. On a wide window every screen centres in one
      // column instead of stretching — without this the aspect-ratio'd payment
      // cards grow to several hundred pixels tall and list rows strand their
      // amounts at the far edge. No effect below the threshold.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PulseSpacing.maxContentWidth,
          ),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: PulseBottomNavigation(
        destinations: destinations,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab returns it to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
