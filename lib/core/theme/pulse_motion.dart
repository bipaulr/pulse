import 'package:flutter/widgets.dart';

/// Pulse's motion tokens.
///
/// Three durations and two curves are the entire system — every animation in
/// the app should use one of these rather than inventing its own numbers, so
/// motion reads as one consistent language instead of a pile of unrelated
/// tweaks. When in doubt, use [standard] and [curve].
abstract final class PulseMotion {
  /// Micro-interactions: press feedback, icon colour swaps.
  static const fast = Duration(milliseconds: 140);

  /// The default for most transitions: chip selection, sheet content,
  /// skeleton-to-content swaps.
  static const standard = Duration(milliseconds: 220);

  /// Reserved for the few motions that are the visual focus of a moment —
  /// the nav blob's travel, a page entrance. Used sparingly on purpose.
  static const emphasis = Duration(milliseconds: 360);

  /// The default easing: decelerates smoothly with no overshoot. Matches what
  /// most of Pulse already used before this system existed.
  static const curve = Curves.easeOutCubic;

  /// A slightly more pronounced deceleration for [emphasis]-length motion —
  /// still no bounce or overshoot, just a touch more organic than [curve].
  static const emphasizedCurve = Cubic(0.16, 1.0, 0.3, 1.0);

  /// True when the platform has asked for reduced motion. Long or purely
  /// decorative animations should check this and skip straight to their end
  /// state; motion that carries information (a loading spinner, a page
  /// transition) can still play — reduced motion means "less", not "none".
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
