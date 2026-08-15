import 'package:flutter/material.dart';

/// Softens the trailing edge of a horizontally scrolling row.
///
/// Without it a row that runs past the screen edge reads as an accidental
/// overflow — a chip sliced in half by the viewport. Fading the last few
/// pixels makes "there is more this way" the obvious reading instead.
class PulseHorizontalFade extends StatelessWidget {
  const PulseHorizontalFade({
    super.key,
    required this.child,
    this.fadeWidth = 28,
  });

  final Widget child;

  /// Width of the fade, in logical pixels.
  final double fadeWidth;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        // Opaque until the last [fadeWidth] pixels, then out to transparent.
        final solidUntil = bounds.width <= fadeWidth
            ? 0.0
            : 1 - fadeWidth / bounds.width;
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [Colors.black, Colors.black, Colors.transparent],
          stops: [0, solidUntil, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
