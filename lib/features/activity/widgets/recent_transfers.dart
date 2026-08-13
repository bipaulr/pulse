import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// The latest movements in the reported window.
///
/// Uses the same card-per-row treatment as Home and the Transactions feed, so
/// the three read as one product.
class RecentTransfers extends StatelessWidget {
  const RecentTransfers({super.key, required this.transactions});

  final List<PulseTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PulseSectionHeader(
          title: 'Recent Transfer',
          trailing: PulseChip(
            label: 'View All',
            trailingIcon: Icons.arrow_forward_rounded,
            dense: true,
            onTap: () => context.go(AppRoutes.transactions),
          ),
        ),
        const SizedBox(height: PulseSpacing.md),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: PulseSpacing.screenGutter,
            ),
            child: PulseCard(
              padding: EdgeInsets.zero,
              child: PulseEmptyState(
                title: 'No transfers yet',
                message: 'Movements in this period will appear here.',
                icon: Icons.receipt_long_rounded,
                compact: true,
              ),
            ),
          )
        else
          for (final transaction in transactions)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PulseSpacing.screenGutter,
                0,
                PulseSpacing.screenGutter,
                PulseSpacing.sm + 2,
              ),
              child: PulseCard(
                padding: EdgeInsets.zero,
                radius: PulseRadii.button,
                child: PulseTransactionTile(
                  title: transaction.merchant,
                  subtitle: transaction.category.label,
                  icon: transaction.category.icon,
                  amount: transaction.amount,
                  currencySymbol: transaction.currencySymbol,
                  decimalDigits: transaction.displayDecimals,
                  trailingCaption: transaction.shortWhenLabel(now),
                  iconTone: transaction.isIncome
                      ? PulseTransactionIconTone.accent
                      : PulseTransactionIconTone.accentSoft,
                  onTap: () => context.push(
                    AppRoutes.transactionDetails(transaction.id),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
