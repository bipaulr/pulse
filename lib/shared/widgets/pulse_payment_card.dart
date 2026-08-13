import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';
import '../models/models.dart';
import 'pulse_card.dart';
import 'pulse_chip.dart';
import 'pulse_icon_button.dart';

/// The Pulse card face, shared by Home's hero card and the Cards carousel.
///
/// Built on [PulseCard]'s notched shape rather than a Material card, and sized
/// by aspect ratio so it keeps card-like proportions at any width instead of a
/// hardcoded height.
class PulsePaymentCard extends StatefulWidget {
  const PulsePaymentCard({
    super.key,
    required this.card,
    this.onMoreTap,
    this.onTap,
    this.frozen = false,
    this.interactive = true,
    this.showMoreAction = true,
  });

  final PaymentCard card;
  final VoidCallback? onMoreTap;
  final VoidCallback? onTap;

  /// Renders the face desaturated with a "Frozen" marker.
  final bool frozen;

  /// Whether the card responds to press with a scale.
  final bool interactive;

  final bool showMoreAction;

  /// Close to a real card's 1.586, nudged slightly wider so the notch has room.
  static const double aspectRatio = 1.62;

  static PulseCardTone toneFor(PaymentCardStyle style) => switch (style) {
    PaymentCardStyle.lime => PulseCardTone.accent,
    PaymentCardStyle.ink => PulseCardTone.inverse,
    PaymentCardStyle.citron => PulseCardTone.accentAlt,
  };

  @override
  State<PulsePaymentCard> createState() => _PulsePaymentCardState();
}

class _PulsePaymentCardState extends State<PulsePaymentCard> {
  bool _pressed = false;

  /// Luminance-weighted desaturation, for the frozen state.
  static const _greyscale = <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final card = widget.card;
    final tone = PulsePaymentCard.toneFor(card.style);
    final foreground = PulseCard.foregroundOf(colors, tone);
    final subtle = foreground.withValues(alpha: 0.55);

    Widget face = AspectRatio(
      aspectRatio: PulsePaymentCard.aspectRatio,
      child: PulseCard(
        tone: tone,
        radius: PulseRadii.cardLarge,
        elevated: true,
        padding: EdgeInsets.zero,
        notchAction: widget.showMoreAction
            ? PulseIconButton(
                // Ink, not white: the button sits over the off-white canvas in
                // the carved corner, where a white pill would disappear.
                icon: Icons.more_horiz_rounded,
                tone: tone == PulseCardTone.inverse
                    ? PulseIconButtonTone.accent
                    : PulseIconButtonTone.inverse,
                onPressed: widget.onMoreTap,
                tooltip: 'Card options',
              )
            : null,
        child: Stack(
          children: [
            Positioned.fill(child: _CardDecoration(color: foreground)),
            Padding(
              padding: const EdgeInsets.all(PulseSpacing.xl),
              child: _CardContent(
                card: card,
                foreground: foreground,
                subtle: subtle,
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.frozen) {
      face = Stack(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(_greyscale),
            child: face,
          ),
          // A frost scrim plus the marker, both outside the filter so they
          // keep their colour. The scrim is what makes the badge read as an
          // intentional overlay rather than something sitting on the digits.
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PulseRadii.cardLarge),
                child: ColoredBox(
                  color: colors.background.withValues(alpha: 0.45),
                  child: Center(
                    child: PulseChip(
                      label: 'Frozen',
                      icon: Icons.ac_unit_rounded,
                      tone: PulseChipTone.inverse,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!widget.interactive) return face;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: face,
      ),
    );
  }
}

/// Two soft discs bleeding off the edge — enough to stop the face reading as a
/// flat rectangle, faint enough not to compete with the numbers.
class _CardDecoration extends StatelessWidget {
  const _CardDecoration({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -70,
            child: _Disc(size: 190, color: color.withValues(alpha: 0.045)),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: _Disc(size: 110, color: color.withValues(alpha: 0.035)),
          ),
        ],
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.card,
    required this.foreground,
    required this.subtle,
  });

  final PaymentCard card;
  final Color foreground;
  final Color subtle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pulse',
              style: PulseTypography.headingMd.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              card.productName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PulseTypography.caption.copyWith(
                color: subtle,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  card.maskedNumber,
                  style: PulseTypography.amountMd.copyWith(
                    color: foreground,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: PulseSpacing.sm),
            // Contactless mark — the waves point right, as on a physical card.
            Transform.rotate(
              angle: math.pi / 2,
              child: Icon(Icons.wifi_rounded, size: 20, color: subtle),
            ),
          ],
        ),
        const SizedBox(height: PulseSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _CardField(
                label: 'Card Holder',
                value: card.holderName,
                foreground: foreground,
                labelColor: subtle,
              ),
            ),
            const SizedBox(width: PulseSpacing.md),
            _CardField(
              label: 'Expires',
              value: card.expiry,
              foreground: foreground,
              labelColor: subtle,
            ),
          ],
        ),
      ],
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.value,
    required this.foreground,
    required this.labelColor,
  });

  final String label;
  final String value;
  final Color foreground;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: PulseTypography.caption.copyWith(color: labelColor)),
        const SizedBox(height: PulseSpacing.xxs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PulseTypography.titleSm.copyWith(color: foreground),
        ),
      ],
    );
  }
}
