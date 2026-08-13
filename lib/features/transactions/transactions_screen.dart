import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/transaction_feed_view.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/transaction_search_field.dart';

/// The transaction feed.
///
/// Search and filters stay pinned while only the feed scrolls, so the controls
/// never scroll away mid-search and the keyboard can't push them off screen.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            SizedBox(height: PulseSpacing.md),
            PulseFadeIn(
              child: PulseSectionHeader(
                title: 'Transactions',
                subtitle: 'Every movement across your cards',
              ),
            ),
            SizedBox(height: PulseSpacing.xl),
            PulseFadeIn(
              delay: Duration(milliseconds: 60),
              child: TransactionSearchField(),
            ),
            SizedBox(height: PulseSpacing.lg),
            PulseFadeIn(
              delay: Duration(milliseconds: 120),
              child: TransactionFilterBar(),
            ),
            Expanded(
              child: PulseFadeIn(
                delay: Duration(milliseconds: 180),
                child: TransactionFeedView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
