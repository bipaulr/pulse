import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/data/auth_controller.dart';
import 'data/home_repository.dart';
import 'widgets/balance_summary_view.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_activity_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Sections enter in sequence, ~60ms apart, top to bottom.
  static const _stagger = Duration(milliseconds: 60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(homeSnapshotProvider);
    final colors = context.pulseColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        // The floating navigation bar handles the bottom inset itself.
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: PulseSpacing.md,
            bottom: PulseSpacing.bottomNavClearance,
          ),
          children: [
            PulseFadeIn(
              child: HomeHeader(
                user: snapshot.user,
                onNotificationsTap: () => _notImplemented(context, 'Alerts'),
                onAvatarTap: () => _showProfileSheet(context, ref, snapshot.user),
              ),
            ),
            const SizedBox(height: PulseSpacing.sectionGap),
            PulseFadeIn(
              delay: _stagger,
              child: BalanceSummaryView(balance: snapshot.balance),
            ),
            const SizedBox(height: PulseSpacing.xxl),
            PulseFadeIn(
              delay: _stagger * 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PulseSpacing.screenGutter,
                ),
                child: PulsePaymentCard(
                  card: snapshot.card,
                  onTap: () => context.go(AppRoutes.cards),
                  onMoreTap: () => _notImplemented(context, 'Card options'),
                ),
              ),
            ),
            const SizedBox(height: PulseSpacing.xl),
            PulseFadeIn(
              delay: _stagger * 3,
              child: QuickActions(
                actions: [
                  QuickAction(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Deposit',
                    onTap: () => _notImplemented(context, 'Deposit'),
                  ),
                  QuickAction(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer',
                    onTap: () => _notImplemented(context, 'Transfer'),
                  ),
                  QuickAction(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Withdraw',
                    onTap: () => _notImplemented(context, 'Withdraw'),
                  ),
                  QuickAction(
                    icon: Icons.grid_view_rounded,
                    label: 'More',
                    onTap: () => _notImplemented(context, 'More actions'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PulseSpacing.sectionGap),
            PulseFadeIn(
              delay: _stagger * 4,
              child: RecentActivitySection(
                transactions: snapshot.recentTransactions,
                onViewAll: () => context.go(AppRoutes.transactions),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The one place Logout lives — tapping the existing avatar, so nothing new
  /// is added to the header itself.
  void _showProfileSheet(BuildContext context, WidgetRef ref, UserProfile user) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final colors = sheetContext.pulseColors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PulseSpacing.screenGutter,
              PulseSpacing.xl,
              PulseSpacing.screenGutter,
              PulseSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 44,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: PulseRadii.chipRadius,
                    ),
                  ),
                ),
                const SizedBox(height: PulseSpacing.xl),
                Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        user.initials,
                        style: PulseTypography.titleSm.copyWith(
                          color: colors.onAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: PulseSpacing.md),
                    Expanded(
                      child: Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PulseTypography.headingMd.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PulseSpacing.xxl),
                PulseButton(
                  label: 'Log Out',
                  variant: PulseButtonVariant.dark,
                  icon: Icons.logout_rounded,
                  expand: true,
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await ref.read(authControllerProvider.notifier).logout();
                  },
                ),
                const SizedBox(height: PulseSpacing.sm),
                PulseButton(
                  label: 'Cancel',
                  variant: PulseButtonVariant.outline,
                  expand: true,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// These controls are live to the touch but own no behaviour yet, so say so
  /// rather than faking a result.
  void _notImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is coming soon'),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
