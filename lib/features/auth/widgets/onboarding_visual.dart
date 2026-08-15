import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';

/// Which existing screen's visual language an onboarding page echoes.
enum OnboardingVisualStyle { home, activity, cardsAndTransactions }

/// A small, self-contained illustration built from the same tokens and shapes
/// as the real screens — never the real feature widgets, since onboarding has
/// no data and shouldn't depend on Home/Cards/Activity's providers.
class OnboardingVisual extends StatelessWidget {
  const OnboardingVisual({super.key, required this.style});

  final OnboardingVisualStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: switch (style) {
        OnboardingVisualStyle.home => const _HomeVisual(),
        OnboardingVisualStyle.activity => const _ActivityVisual(),
        OnboardingVisualStyle.cardsAndTransactions =>
          const _CardsAndTransactionsVisual(),
      },
    );
  }
}

/// Echoes the notched lime hero card and its masked-number field pair.
class _HomeVisual extends StatelessWidget {
  const _HomeVisual();

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return PulseCard(
      tone: PulseCardTone.accent,
      radius: PulseRadii.cardLarge,
      notchAction: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: colors.surfaceInverse,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_outward_rounded,
          size: 16,
          color: colors.accent,
        ),
      ),
      notchSize: const Size(52, 46),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Bar(width: 70, height: 12, color: colors.onAccent),
          _MaskedNumberRow(color: colors.onAccent),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Bar(width: 44, height: 8, color: colors.onAccent, faint: true),
                    const SizedBox(height: PulseSpacing.xs),
                    _Bar(width: 80, height: 12, color: colors.onAccent),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Bar(width: 36, height: 8, color: colors.onAccent, faint: true),
                  const SizedBox(height: PulseSpacing.xs),
                  _Bar(width: 40, height: 12, color: colors.onAccent),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Echoes the dark chart panel and its lime/citron bars.
class _ActivityVisual extends StatelessWidget {
  const _ActivityVisual();

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    const heights = [0.4, 0.65, 0.5, 0.85, 0.7, 1.0];

    return PulseCard(
      tone: PulseCardTone.inverse,
      radius: PulseRadii.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: 90, height: 12, color: colors.onInverse),
          const SizedBox(height: PulseSpacing.xs),
          _Bar(width: 60, height: 20, color: colors.accentAlt),
          const SizedBox(height: PulseSpacing.lg),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < heights.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PulseSpacing.xs,
                      ),
                      child: FractionallySizedBox(
                        heightFactor: heights[i],
                        alignment: Alignment.bottomCenter,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: i == heights.length - 1
                                ? colors.accentAlt
                                : colors.accent,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Echoes the lime card (with a small citron network badge) above a couple of
/// transaction-tile rows.
class _CardsAndTransactionsVisual extends StatelessWidget {
  const _CardsAndTransactionsVisual();

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            PulseCard(
              tone: PulseCardTone.accent,
              radius: PulseRadii.card,
              padding: const EdgeInsets.all(PulseSpacing.md),
              child: _MaskedNumberRow(color: colors.onAccent, compact: true),
            ),
            // A small badge peeking past the corner — enough to suggest
            // "more than one card" without the risk of two full cards
            // overlapping awkwardly at this scale.
            Positioned(
              top: -10,
              right: 24,
              child: Container(
                height: 26,
                width: 42,
                decoration: BoxDecoration(
                  color: colors.accentAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PulseSpacing.lg),
        for (final tone in [colors.accentSoft, colors.surfaceMuted])
          Padding(
            padding: const EdgeInsets.only(bottom: PulseSpacing.xs),
            child: PulseCard(
              tone: PulseCardTone.surface,
              radius: PulseRadii.button,
              padding: const EdgeInsets.symmetric(
                horizontal: PulseSpacing.md,
                vertical: PulseSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: tone,
                      borderRadius: PulseRadii.iconRadius,
                    ),
                  ),
                  const SizedBox(width: PulseSpacing.sm),
                  Expanded(
                    child: _Bar(
                      width: double.infinity,
                      height: 9,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: PulseSpacing.sm),
                  _Bar(width: 30, height: 9, color: colors.textSecondary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MaskedNumberRow extends StatelessWidget {
  const _MaskedNumberRow({required this.color, this.compact = false});

  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.only(right: compact ? 4 : 6),
            child: _Dots(color: color),
          ),
        _Bar(width: compact ? 26 : 34, height: compact ? 10 : 14, color: color),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Container(
            height: 4,
            width: 4,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded bar standing in for a line of text or a numeral — the same
/// wireframe-block technique the design-system preview used during Phase 1.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.width,
    required this.height,
    required this.color,
    this.faint = false,
  });

  final double width;
  final double height;
  final Color color;
  final bool faint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: faint ? 0.35 : 0.9),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
