import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

/// Surface treatments a [PulseCard] can take.
enum PulseCardTone {
  /// White card on the off-white canvas. The default.
  surface,

  /// Quiet neutral fill — for grouped tiles and secondary information.
  muted,

  /// Electric lime. Reserve this for the one thing that matters most on a
  /// screen; it loses all its power if repeated.
  accent,

  /// Warm yellow — a second, softer emphasis next to [accent].
  accentAlt,

  /// Deep ink panel, used for charts and hero content.
  inverse,
}

/// The base surface for everything in Pulse.
///
/// Deliberately not a Material [Card]: it owns its own radius, tone and (very
/// light) shadow, and it can carve a notch out of its top-right corner for a
/// floating action — the shape that gives Pulse cards their identity.
class PulseCard extends StatelessWidget {
  const PulseCard({
    super.key,
    required this.child,
    this.tone = PulseCardTone.surface,
    this.padding = const EdgeInsets.all(PulseSpacing.xl),
    this.radius = PulseRadii.card,
    this.onTap,
    this.elevated = false,
    this.bordered = false,
    this.width,
    this.height,
    this.notchAction,
    this.notchSize = const Size(64, 58),
  });

  final Widget child;
  final PulseCardTone tone;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  /// Adds the soft "floating" shadow. Off by default — Pulse separates
  /// surfaces with colour first.
  final bool elevated;

  /// Hairline outline, for cards that need definition without a shadow.
  final bool bordered;

  final double? width;
  final double? height;

  /// Optional action rendered inside a notch carved from the top-right corner.
  ///
  /// It is laid out at its natural size, anchored to the corner.
  final Widget? notchAction;

  /// Size of the carved region. Only used when [notchAction] is set.
  ///
  /// Should be a little larger than the action so the concave edges keep some
  /// clearance around it.
  final Size notchSize;

  Color _background(PulseColors colors) => switch (tone) {
    PulseCardTone.surface => colors.surface,
    PulseCardTone.muted => colors.surfaceMuted,
    PulseCardTone.accent => colors.accent,
    PulseCardTone.accentAlt => colors.accentAlt,
    PulseCardTone.inverse => colors.surfaceInverse,
  };

  /// The colour text and icons inside this card should default to.
  static Color foregroundOf(PulseColors colors, PulseCardTone tone) =>
      switch (tone) {
        PulseCardTone.surface ||
        PulseCardTone.muted => colors.textPrimary,
        PulseCardTone.accent || PulseCardTone.accentAlt => colors.onAccent,
        PulseCardTone.inverse => colors.onInverse,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final foreground = foregroundOf(colors, tone);
    final hasNotch = notchAction != null;

    final shape = PulseNotchedBorder(
      radius: radius,
      notchSize: hasNotch ? notchSize : Size.zero,
      side: bordered ? BorderSide(color: colors.border) : BorderSide.none,
    );

    final Widget content = Padding(padding: padding, child: child);

    Widget card = Material(
      color: _background(colors),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              customBorder: shape,
              splashColor: foreground.withValues(alpha: 0.06),
              highlightColor: foreground.withValues(alpha: 0.03),
              child: content,
            ),
    );

    card = DefaultTextStyle.merge(
      style: TextStyle(color: foreground),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: card,
      ),
    );

    if (elevated) {
      card = DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          color: _background(colors),
          shadows: PulseShadows.lifted(colors.shadow),
        ),
        child: card,
      );
    }

    if (hasNotch) {
      // The action has to sit *outside* the Material — it occupies the region
      // the shape carves away, so anything inside the clip would be erased.
      // It sizes itself; [notchSize] only describes the carve, so a mismatch
      // never forces the child into an overflowing box.
      card = Stack(
        clipBehavior: Clip.none,
        children: [card, Positioned(top: 0, right: 0, child: notchAction!)],
      );
    }

    if (width != null || height != null) {
      card = SizedBox(width: width, height: height, child: card);
    }

    return card;
  }
}
