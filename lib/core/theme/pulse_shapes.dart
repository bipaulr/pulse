import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pulse_radii.dart';

/// A rounded rectangle with a concave "bite" carved out of its top-right
/// corner — the Pulse signature card shape.
///
/// The carved region is where a floating action (an overflow pill, a filter
/// chip) sits so it reads as part of the card without covering its content.
/// With a zero [notchSize] this degrades to a plain rounded rectangle, so the
/// same shape can back every card in the app.
@immutable
class PulseNotchedBorder extends OutlinedBorder {
  const PulseNotchedBorder({
    this.radius = PulseRadii.cardLarge,
    this.notchSize = Size.zero,
    this.notchRadius = PulseRadii.notch,
    super.side = BorderSide.none,
  });

  /// Corner radius of the card itself.
  final double radius;

  /// Size of the region removed from the top-right corner.
  final Size notchSize;

  /// Radius of the three fillets that make the notch read as carved rather
  /// than cut.
  final double notchRadius;

  bool get _hasNotch => notchSize.width > 0 && notchSize.height > 0;

  Path _buildPath(Rect rect) {
    final r = math.min(radius, math.min(rect.width, rect.height) / 2);

    if (!_hasNotch) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
    }

    // Keep the geometry valid on very small cards.
    final nw = math.min(notchSize.width, rect.width - r - 1);
    final nh = math.min(notchSize.height, rect.height - r - 1);
    final nr = math.min(
      notchRadius,
      math.min(nw, math.min(nh, rect.width - nw - r)),
    );

    final l = rect.left;
    final t = rect.top;
    final rr = rect.right;
    final b = rect.bottom;
    final nrRadius = Radius.circular(nr);
    final cornerRadius = Radius.circular(r);

    return Path()
      ..moveTo(l + r, t)
      // Top edge, stopping short of the notch.
      ..lineTo(rr - nw - nr, t)
      // Turn down into the notch (convex).
      ..arcToPoint(Offset(rr - nw, t + nr), radius: nrRadius)
      ..lineTo(rr - nw, t + nh - nr)
      // Inner corner of the notch (concave).
      ..arcToPoint(
        Offset(rr - nw + nr, t + nh),
        radius: nrRadius,
        clockwise: false,
      )
      ..lineTo(rr - nr, t + nh)
      // Turn back down the card's right edge (convex).
      ..arcToPoint(Offset(rr, t + nh + nr), radius: nrRadius)
      ..lineTo(rr, b - r)
      ..arcToPoint(Offset(rr - r, b), radius: cornerRadius)
      ..lineTo(l + r, b)
      ..arcToPoint(Offset(l, b - r), radius: cornerRadius)
      ..lineTo(l, t + r)
      ..arcToPoint(Offset(l + r, t), radius: cornerRadius)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect.deflate(side.strokeInset));

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(
      _buildPath(rect.deflate(side.strokeOffset / 2)),
      side.toPaint(),
    );
  }

  @override
  PulseNotchedBorder copyWith({
    BorderSide? side,
    double? radius,
    Size? notchSize,
    double? notchRadius,
  }) {
    return PulseNotchedBorder(
      side: side ?? this.side,
      radius: radius ?? this.radius,
      notchSize: notchSize ?? this.notchSize,
      notchRadius: notchRadius ?? this.notchRadius,
    );
  }

  @override
  ShapeBorder scale(double t) => PulseNotchedBorder(
    side: side.scale(t),
    radius: radius * t,
    notchSize: notchSize * t,
    notchRadius: notchRadius * t,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PulseNotchedBorder &&
          other.side == side &&
          other.radius == radius &&
          other.notchSize == notchSize &&
          other.notchRadius == notchRadius;

  @override
  int get hashCode => Object.hash(side, radius, notchSize, notchRadius);
}
