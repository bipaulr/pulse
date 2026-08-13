import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/transaction_query.dart';

/// A single scrolling row of filter pills.
///
/// Deliberately light: no card, no border, no labels above it — just chips on
/// the canvas, so it never competes with the feed below.
class TransactionFilterBar extends ConsumerWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      transactionQueryProvider.select((query) => query.filter),
    );

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: PulseSpacing.screenGutter,
        ),
        itemCount: TransactionFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: PulseSpacing.sm),
        itemBuilder: (context, index) {
          final filter = TransactionFilter.values[index];
          return Center(
            child: PulseChip(
              label: filter.label,
              selected: filter == selected,
              onTap: () => ref
                  .read(transactionQueryProvider.notifier)
                  .setFilter(filter),
            ),
          );
        },
      ),
    );
  }
}
