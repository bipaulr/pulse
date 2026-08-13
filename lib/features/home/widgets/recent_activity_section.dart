import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Recent movements, one card per row.
///
/// Separate cards rather than a single grouped list — it matches the airier
/// rhythm of the rest of the screen and lets each row animate in on its own.
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.transactions,
    required this.onViewAll,
    this.now,
  });

  final List<PulseTransaction> transactions;
  final VoidCallback onViewAll;

  /// Injectable clock, so the relative timestamps are testable.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final clock = now ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PulseSectionHeader(
          title: 'Recent Activity',
          trailing: PulseChip(
            label: 'View All',
            trailingIcon: Icons.arrow_forward_rounded,
            dense: true,
            onTap: onViewAll,
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
                title: 'Nothing yet',
                message: 'Your recent transactions will appear here.',
                compact: true,
              ),
            ),
          )
        else
          for (var i = 0; i < transactions.length; i++)
            Padding(
              padding: EdgeInsets.only(
                left: PulseSpacing.screenGutter,
                right: PulseSpacing.screenGutter,
                bottom: i == transactions.length - 1 ? 0 : PulseSpacing.sm + 2,
              ),
              child: PulseFadeIn(
                delay: Duration(milliseconds: 40 * i),
                child: PulseCard(
                  padding: EdgeInsets.zero,
                  radius: PulseRadii.button,
                  child: _TransactionRow(
                    transaction: transactions[i],
                    now: clock,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction, required this.now});

  final PulseTransaction transaction;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return PulseTransactionTile(
      title: transaction.merchant,
      subtitle: transaction.category.label,
      icon: transaction.category.icon,
      amount: transaction.amount,
      currencySymbol: transaction.currencySymbol,
      decimalDigits: transaction.displayDecimals,
      trailingCaption: transaction.shortWhenLabel(now),
      // Income gets the solid lime well so money coming in is findable at a
      // glance; outflows share the quieter tinted one.
      iconTone: transaction.isIncome
          ? PulseTransactionIconTone.accent
          : PulseTransactionIconTone.accentSoft,
    );
  }
}
