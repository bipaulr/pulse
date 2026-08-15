import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../transactions/data/transactions_repository.dart';
import 'activity_analytics.dart';
import 'activity_models.dart';

/// Which window the screen is reporting on.
class ActivityPeriodController extends Notifier<ActivityPeriod> {
  @override
  ActivityPeriod build() => ActivityPeriod.month;

  void select(ActivityPeriod period) {
    if (state == period) return;
    state = period;
    // A bar index from the old period would point at the wrong bucket.
    ref.read(selectedBucketIndexProvider.notifier).clear();
  }
}

final activityPeriodProvider =
    NotifierProvider<ActivityPeriodController, ActivityPeriod>(
      ActivityPeriodController.new,
    );

/// Which chart bar is highlighted. Null means "the most recent bucket".
class SelectedBucketIndex extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int index) => state = index;

  void clear() => state = null;
}

final selectedBucketIndexProvider = NotifierProvider<SelectedBucketIndex, int?>(
  SelectedBucketIndex.new,
);

/// Expense or income, for the Categories section.
class CategoryDirectionController extends Notifier<CategoryDirection> {
  @override
  CategoryDirection build() => CategoryDirection.expense;

  void select(CategoryDirection direction) => state = direction;
}

final categoryDirectionProvider =
    NotifierProvider<CategoryDirectionController, CategoryDirection>(
      CategoryDirectionController.new,
    );

/// Everything the Activity screen renders.
///
/// One derived provider rather than one per widget: the analytics are a single
/// pass over the transactions, and splitting them would mean repeating it.
final activitySummaryProvider = Provider<AsyncValue<ActivitySummary>>((ref) {
  final period = ref.watch(activityPeriodProvider);
  final direction = ref.watch(categoryDirectionProvider);
  final now = ref.watch(nowProvider)();

  return ref
      .watch(allTransactionsProvider)
      .whenData(
        (transactions) => ActivityAnalytics.summarize(
          transactions: transactions,
          period: period,
          now: now,
          direction: direction,
        ),
      );
});

/// The bar the chart should highlight, resolved against the current buckets.
///
/// Falls back to the newest bucket so there is always exactly one selection.
final resolvedBucketIndexProvider = Provider<int>((ref) {
  final summary = ref.watch(activitySummaryProvider).value;
  final bucketCount = summary?.buckets.length ?? 0;
  if (bucketCount == 0) return 0;

  final selected = ref.watch(selectedBucketIndexProvider);
  if (selected == null || selected < 0 || selected >= bucketCount) {
    return bucketCount - 1;
  }
  return selected;
});
