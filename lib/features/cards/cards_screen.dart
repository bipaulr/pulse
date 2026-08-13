import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../transactions/data/transactions_repository.dart';
import 'data/cards_repository.dart';
import 'widgets/card_actions.dart';
import 'widgets/card_carousel.dart';
import 'widgets/card_details_panel.dart';

/// Wallet: the card stack, the selected card's particulars, its controls, and
/// the activity that ran through it.
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.pulseColors;
    final cards = ref.watch(cardsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: cards.when(
          loading: () => const _CardsSkeleton(),
          error: (error, _) => PulseErrorState(
            title: 'Could not load your cards',
            onRetry: () => ref.invalidate(cardsProvider),
          ),
          data: (list) => list.isEmpty
              ? const _NoCards()
              : _CardsBody(cards: list),
        ),
      ),
    );
  }
}

class _CardsBody extends ConsumerWidget {
  const _CardsBody({required this.cards});

  final List<PaymentCard> cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guard against a stale index if the card list ever shrinks.
    final selectedIndex = ref
        .watch(selectedCardIndexProvider)
        .clamp(0, cards.length - 1);
    final selectedCard = cards[selectedIndex];
    final frozenIds = ref.watch(frozenCardsProvider);

    return ListView(
      padding: const EdgeInsets.only(
        top: PulseSpacing.md,
        bottom: PulseSpacing.bottomNavClearance,
      ),
      children: [
        PulseFadeIn(
          child: PulseSectionHeader(
            title: 'My Cards',
            subtitle: '${cards.length} active',
            trailing: PulseIconButton(
              icon: Icons.add_rounded,
              tone: PulseIconButtonTone.surface,
              tooltip: 'Add card',
              onPressed: () => _notify(context, 'Adding cards is coming soon'),
            ),
          ),
        ),
        const SizedBox(height: PulseSpacing.xl),
        PulseFadeIn(
          delay: const Duration(milliseconds: 60),
          child: CardCarousel(
            cards: cards,
            selectedIndex: selectedIndex,
            frozenCardIds: frozenIds,
            onSelected: (index) =>
                ref.read(selectedCardIndexProvider.notifier).select(index),
            onMoreTap: (card) =>
                _notify(context, 'Options for •••• ${card.last4} coming soon'),
          ),
        ),
        const SizedBox(height: PulseSpacing.lg),
        CardCarouselIndicator(
          count: cards.length,
          selectedIndex: selectedIndex,
        ),
        const SizedBox(height: PulseSpacing.sectionGap),
        PulseFadeIn(
          delay: const Duration(milliseconds: 120),
          child: CardDetailsPanel(card: selectedCard),
        ),
        const SizedBox(height: PulseSpacing.sectionGap),
        PulseFadeIn(
          delay: const Duration(milliseconds: 180),
          child: CardActions(card: selectedCard),
        ),
        const SizedBox(height: PulseSpacing.sectionGap),
        _CardActivity(card: selectedCard),
      ],
    );
  }

  static void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

/// The last few movements on the selected card, linking through to the feed.
class _CardActivity extends ConsumerWidget {
  const _CardActivity({required this.card});

  final PaymentCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref
        .watch(transactionsForCardProvider(card.id))
        .take(3)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PulseSectionHeader(
          title: 'Card Activity',
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
                title: 'Nothing on this card yet',
                message: 'Spend with it and activity shows up here.',
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
                  trailingCaption: transaction.shortWhenLabel(DateTime.now()),
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

class _CardsSkeleton extends StatelessWidget {
  const _CardsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PulseSpacing.screenGutter,
        PulseSpacing.xl,
        PulseSpacing.screenGutter,
        PulseSpacing.bottomNavClearance,
      ),
      children: const [
        PulseSkeleton.text(width: 130, height: 20),
        SizedBox(height: PulseSpacing.xl),
        PulseSkeleton.card(height: 190),
        SizedBox(height: PulseSpacing.sectionGap),
        PulseSkeleton.text(width: 110),
        SizedBox(height: PulseSpacing.lg),
        PulseSkeleton(height: 56, radius: PulseRadii.input),
        SizedBox(height: PulseSpacing.sm),
        PulseSkeleton(height: 56, radius: PulseRadii.input),
      ],
    );
  }
}

class _NoCards extends StatelessWidget {
  const _NoCards();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: PulseEmptyState(
        title: 'No cards yet',
        message: 'Your Pulse cards will appear here once issued.',
        icon: Icons.credit_card_rounded,
      ),
    );
  }
}
