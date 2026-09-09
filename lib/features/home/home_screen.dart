import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../shared/data/ledger_controller.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/data/auth_controller.dart';
import '../cards/data/cards_repository.dart';
import 'data/home_repository.dart';
import 'data/home_snapshot.dart';
import 'widgets/balance_summary_view.dart';
import 'widgets/home_header.dart';
import 'widgets/money_move_sheet.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_activity_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Sections enter in sequence, ~60ms apart, top to bottom.
  static const _stagger = Duration(milliseconds: 60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(homeSnapshotProvider);
    final isCardFrozen = ref.watch(
      frozenCardsProvider.select((ids) => ids.contains(snapshot.card.id)),
    );
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
                  frozen: isCardFrozen,
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
                    onTap: () => _openMoneyMove(
                      context,
                      ref,
                      MoneyMoveKind.deposit,
                      snapshot,
                    ),
                  ),
                  QuickAction(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer',
                    onTap: () => _openMoneyMove(
                      context,
                      ref,
                      MoneyMoveKind.transfer,
                      snapshot,
                    ),
                  ),
                  QuickAction(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Withdraw',
                    onTap: () => _openMoneyMove(
                      context,
                      ref,
                      MoneyMoveKind.withdraw,
                      snapshot,
                    ),
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
                const SizedBox(height: PulseSpacing.xl),
                Consumer(
                  builder: (context, sheetRef, _) => _ThemeModeRow(
                    current: sheetRef.watch(themeModeControllerProvider),
                    onSelect: (mode) => sheetRef
                        .read(themeModeControllerProvider.notifier)
                        .setThemeMode(mode),
                  ),
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

  /// Opens the Deposit/Withdraw/Send sheet and, on a confirmed submit, writes
  /// the result to [ledgerControllerProvider] — the same state
  /// [homeSnapshotProvider] and the Transactions feed both read.
  Future<void> _openMoneyMove(
    BuildContext context,
    WidgetRef ref,
    MoneyMoveKind kind,
    HomeSnapshot snapshot,
  ) async {
    final result = await showModalBottomSheet<MoneyMoveResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MoneyMoveSheet(
        kind: kind,
        availableBalance: snapshot.balance.total,
        currencySymbol: snapshot.balance.currencySymbol,
      ),
    );
    if (result == null || !context.mounted) return;

    final ledger = ref.read(ledgerControllerProvider.notifier);
    final symbol = snapshot.balance.currencySymbol;
    final amountLabel = result.amount.toStringAsFixed(0);
    final String message;
    switch (kind) {
      case MoneyMoveKind.deposit:
        ledger.deposit(result.amount);
        message = 'Deposited $symbol$amountLabel';
      case MoneyMoveKind.withdraw:
        ledger.withdraw(result.amount);
        message = 'Withdrew $symbol$amountLabel';
      case MoneyMoveKind.transfer:
        ledger.transfer(result.amount, recipient: result.recipient!);
        message = 'Sent $symbol$amountLabel to ${result.recipient}';
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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

/// The System / Light / Dark segmented control shown in the profile sheet.
class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({required this.current, required this.onSelect});

  final ThemeMode current;
  final ValueChanged<ThemeMode> onSelect;

  static const _options = [
    (ThemeMode.system, 'Auto'),
    (ThemeMode.light, 'Light'),
    (ThemeMode.dark, 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Row(
      children: [
        Text(
          'Appearance',
          style: PulseTypography.labelSm.copyWith(color: colors.textSecondary),
        ),
        const Spacer(),
        for (final (mode, label) in _options) ...[
          PulseChip(
            label: label,
            selected: current == mode,
            dense: true,
            onTap: () => onSelect(mode),
          ),
          if (mode != _options.last.$1) const SizedBox(width: PulseSpacing.xs),
        ],
      ],
    );
  }
}
