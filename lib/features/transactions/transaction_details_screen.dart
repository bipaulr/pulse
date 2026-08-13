import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import 'data/transactions_repository.dart';

/// A single transaction, in full.
///
/// The amount is the headline — everything else is a quiet label/value pair
/// beneath it.
class TransactionDetailsScreen extends ConsumerWidget {
  const TransactionDetailsScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.pulseColors;
    final transaction = ref.watch(transactionByIdProvider(transactionId));

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailsAppBar(onBack: () => _back(context)),
            Expanded(
              child: transaction == null
                  ? _MissingTransaction(onBack: () => _back(context))
                  : _DetailsBody(transaction: transaction),
            ),
          ],
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.transactions);
    }
  }
}

class _DetailsAppBar extends StatelessWidget {
  const _DetailsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PulseSpacing.screenGutter,
        PulseSpacing.md,
        PulseSpacing.screenGutter,
        PulseSpacing.sm,
      ),
      child: Row(
        children: [
          PulseIconButton(
            icon: Icons.arrow_back_rounded,
            tone: PulseIconButtonTone.surface,
            onPressed: onBack,
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              'Transaction',
              textAlign: TextAlign.center,
              style: PulseTypography.headingLg.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          // Balances the back button so the title stays optically centred.
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.transaction});

  final PulseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return ListView(
      padding: const EdgeInsets.only(
        bottom: PulseSpacing.bottomNavClearance,
      ),
      children: [
        PulseFadeIn(
          child: _AmountHeader(transaction: transaction),
        ),
        const SizedBox(height: PulseSpacing.sectionGap),
        PulseFadeIn(
          delay: const Duration(milliseconds: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PulseSpacing.screenGutter,
            ),
            child: Column(
              children: [
                PulseDetailRow(
                  label: 'Category',
                  value: transaction.category.label,
                ),
                PulseDetailRow(
                  label: 'Date',
                  value: transaction.fullDateLabel,
                ),
                PulseDetailRow(label: 'Time', value: transaction.clockLabel),
                PulseDetailRow(
                  label: 'Payment Method',
                  value: transaction.paymentMethod,
                ),
                PulseDetailRow(
                  label: 'Transaction ID',
                  value: transaction.id.toUpperCase(),
                ),
                if (transaction.description != null)
                  PulseDetailRow(
                    label: 'Description',
                    value: transaction.description!,
                  ),
                PulseDetailRow(
                  label: 'Status',
                  value: transaction.status.label,
                  valueColor: switch (transaction.status) {
                    TransactionStatus.completed => colors.positive,
                    TransactionStatus.pending => colors.textSecondary,
                    TransactionStatus.failed => colors.negative,
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountHeader extends StatelessWidget {
  const _AmountHeader({required this.transaction});

  final PulseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Column(
      children: [
        const SizedBox(height: PulseSpacing.lg),
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: transaction.isIncome ? colors.accent : colors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.category.icon,
            size: 30,
            color: transaction.isIncome ? colors.onAccent : colors.accentMuted,
          ),
        ),
        const SizedBox(height: PulseSpacing.lg),
        Text(
          transaction.merchant,
          textAlign: TextAlign.center,
          style: PulseTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: PulseSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.screenGutter,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: PulseAmount(
              value: transaction.amount,
              size: PulseAmountSize.xl,
              currencySymbol: transaction.currencySymbol,
              decimalDigits: transaction.displayDecimals,
              sign: PulseAmountSign.signed,
              color: transaction.isIncome
                  ? colors.positive
                  : colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: PulseSpacing.md),
        PulseChip(
          label: transaction.shortWhenLabel(DateTime.now()),
          icon: Icons.schedule_rounded,
          tone: PulseChipTone.muted,
          dense: true,
        ),
      ],
    );
  }
}

class _MissingTransaction extends StatelessWidget {
  const _MissingTransaction({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PulseEmptyState(
        title: 'Transaction not found',
        message: 'This record is no longer available.',
        icon: Icons.search_off_rounded,
        actionLabel: 'Back to transactions',
        onAction: onBack,
      ),
    );
  }
}
