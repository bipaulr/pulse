import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../shared/models/models.dart';
import 'transactions_repository.dart';

/// The compact filters above the feed.
enum TransactionFilter {
  all('All'),
  income('Income'),
  expenses('Expenses'),
  food('Food', TransactionCategory.food),
  shopping('Shopping', TransactionCategory.shopping),
  transport('Transport', TransactionCategory.transport),
  bills('Bills', TransactionCategory.bills),
  entertainment('Entertainment', TransactionCategory.entertainment),
  travel('Travel', TransactionCategory.travel),
  health('Health', TransactionCategory.health),
  investments('Investments', TransactionCategory.investments);

  const TransactionFilter(this.label, [this.category]);

  final String label;

  /// Set for the category filters; null for the three direction filters.
  final TransactionCategory? category;

  bool accepts(PulseTransaction transaction) {
    if (this == TransactionFilter.all) return true;
    if (this == TransactionFilter.income) return transaction.isIncome;
    if (this == TransactionFilter.expenses) return !transaction.isIncome;
    return transaction.category == category;
  }
}

@immutable
class TransactionQuery {
  const TransactionQuery({
    this.search = '',
    this.filter = TransactionFilter.all,
  });

  final String search;
  final TransactionFilter filter;

  bool get isFiltering => search.isNotEmpty || filter != TransactionFilter.all;

  TransactionQuery copyWith({String? search, TransactionFilter? filter}) =>
      TransactionQuery(
        search: search ?? this.search,
        filter: filter ?? this.filter,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionQuery &&
          other.search == search &&
          other.filter == filter;

  @override
  int get hashCode => Object.hash(search, filter);
}

class TransactionQueryController extends Notifier<TransactionQuery> {
  @override
  TransactionQuery build() => const TransactionQuery();

  /// Called from the search field *after* it has debounced.
  void setSearch(String value) {
    if (state.search == value) return;
    state = state.copyWith(search: value);
  }

  void setFilter(TransactionFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
  }

  void clear() => state = const TransactionQuery();
}

final transactionQueryProvider =
    NotifierProvider<TransactionQueryController, TransactionQuery>(
      TransactionQueryController.new,
    );

/// The records that survive the active search and filter.
final visibleTransactionsProvider =
    Provider<AsyncValue<List<PulseTransaction>>>((ref) {
      final query = ref.watch(transactionQueryProvider);
      return ref.watch(allTransactionsProvider).whenData(
        (all) => all
            .where(
              (transaction) =>
                  query.filter.accepts(transaction) &&
                  transaction.matches(query.search),
            )
            .toList(growable: false),
      );
    });

/// A flat list of headers and rows, ready for `ListView.builder`.
///
/// Flattening the groups keeps the feed lazily built — a nested
/// `Column`-per-day would construct every row up front.
sealed class TransactionFeedItem {
  const TransactionFeedItem();
}

final class TransactionDayHeader extends TransactionFeedItem {
  const TransactionDayHeader(this.label);

  final String label;
}

final class TransactionEntry extends TransactionFeedItem {
  const TransactionEntry(this.transaction);

  final PulseTransaction transaction;
}

List<TransactionFeedItem> buildTransactionFeed(
  List<PulseTransaction> transactions,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final items = <TransactionFeedItem>[];
  DateTime? currentDay;

  for (final transaction in transactions) {
    final day = transaction.day;
    if (day != currentDay) {
      currentDay = day;
      items.add(TransactionDayHeader(dayLabel(day, today)));
    }
    items.add(TransactionEntry(transaction));
  }

  return items;
}

/// `TODAY`, `YESTERDAY`, or `12 AUGUST`.
String dayLabel(DateTime day, DateTime today) {
  final daysAgo = today.difference(day).inDays;
  if (daysAgo == 0) return 'TODAY';
  if (daysAgo == 1) return 'YESTERDAY';
  return '${day.day} '
      '${PulseTransaction.fullMonthNames[day.month - 1].toUpperCase()}';
}

final transactionFeedProvider =
    Provider<AsyncValue<List<TransactionFeedItem>>>((ref) {
      // Same clock the sample data was generated against, so "Today" means the
      // same day in both places.
      final now = ref.watch(nowProvider)();
      return ref
          .watch(visibleTransactionsProvider)
          .whenData((list) => buildTransactionFeed(list, now));
    });
