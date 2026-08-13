import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

/// A shimmering placeholder block used while content loads.
///
/// Kept intentionally plain — a slow, low-contrast sweep rather than an
/// attention-grabbing animation.
class PulseSkeleton extends StatefulWidget {
  const PulseSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = PulseSpacing.sm,
    this.shape = BoxShape.rectangle,
  });

  /// A single line of placeholder text.
  const PulseSkeleton.text({Key? key, double? width, double height = 14})
    : this(key: key, width: width, height: height, radius: PulseSpacing.xs + 2);

  /// A circular placeholder — avatars, icon wells.
  const PulseSkeleton.circle({Key? key, double size = 44})
    : this(key: key, width: size, height: size, shape: BoxShape.circle);

  /// A full card-sized placeholder.
  const PulseSkeleton.card({Key? key, double? width, double height = 140})
    : this(
        key: key,
        width: width,
        height: height,
        radius: PulseRadii.card,
      );

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  State<PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<PulseSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final isCircle = widget.shape == BoxShape.circle;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Sweep the highlight from off-screen left to off-screen right.
          final t = _controller.value * 2 - 1;
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: widget.shape,
              borderRadius: isCircle
                  ? null
                  : BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(t - 1, 0),
                end: Alignment(t + 1, 0),
                colors: [
                  colors.skeletonBase,
                  colors.skeletonHighlight,
                  colors.skeletonBase,
                ],
                stops: const [0.1, 0.5, 0.9],
              ),
            ),
          );
        },
      ),
    );
  }
}
