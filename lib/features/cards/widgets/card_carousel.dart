import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Swipeable stack of cards.
///
/// Neighbours stay partly visible through a fractional viewport and scale down
/// as they move off-centre, so the selected card reads as the focus without
/// any extra chrome. Height is derived from the measured width — never
/// hardcoded — so the proportions hold on any device.
class CardCarousel extends StatefulWidget {
  const CardCarousel({
    super.key,
    required this.cards,
    required this.selectedIndex,
    required this.onSelected,
    required this.frozenCardIds,
    this.onMoreTap,
  });

  final List<PaymentCard> cards;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Set<String> frozenCardIds;
  final void Function(PaymentCard card)? onMoreTap;

  static const _viewportFraction = 0.86;
  static const _itemGutter = PulseSpacing.sm;

  /// How far a neighbouring card shrinks, per page of separation.
  static const _scaleFalloff = 0.08;

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel> {
  late final PageController _controller = PageController(
    initialPage: widget.selectedIndex,
    viewportFraction: CardCarousel._viewportFraction,
  );

  @override
  void didUpdateWidget(CardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the view in step when selection changes from outside (e.g. a dot).
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        _controller.hasClients &&
        (_controller.page?.round() ?? widget.selectedIndex) !=
            widget.selectedIndex) {
      _controller.animateToPage(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Distance of [index] from the centre of the viewport, in pages.
  double _offsetFromCentre(int index) {
    if (_controller.hasClients &&
        _controller.position.hasContentDimensions &&
        _controller.page != null) {
      return _controller.page! - index;
    }
    return (widget.selectedIndex - index).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            constraints.maxWidth * CardCarousel._viewportFraction -
            CardCarousel._itemGutter * 2;
        final cardHeight = cardWidth / PulsePaymentCard.aspectRatio;

        return SizedBox(
          // A little slack so the elevated card's shadow isn't clipped.
          height: cardHeight + PulseSpacing.lg,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.cards.length,
            onPageChanged: widget.onSelected,
            padEnds: true,
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delta = _offsetFromCentre(index).abs();
                  final scale = (1 - delta * CardCarousel._scaleFalloff).clamp(
                    0.88,
                    1.0,
                  );
                  return Transform.scale(scale: scale, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CardCarousel._itemGutter,
                  ),
                  child: Center(
                    child: PulsePaymentCard(
                      card: card,
                      frozen: widget.frozenCardIds.contains(card.id),
                      onMoreTap: () => widget.onMoreTap?.call(card),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Page dots. The active one stretches into a lime pill.
class CardCarouselIndicator extends StatelessWidget {
  const CardCarouselIndicator({
    super.key,
    required this.count,
    required this.selectedIndex,
  });

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: PulseSpacing.xs),
            height: 6,
            width: i == selectedIndex ? 22 : 6,
            decoration: BoxDecoration(
              color: i == selectedIndex ? colors.accent : colors.border,
              borderRadius: PulseRadii.chipRadius,
            ),
          ),
      ],
    );
  }
}
