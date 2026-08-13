import 'package:flutter/material.dart';

/// Fades and lifts its child into place once, on first build.
///
/// Staggering a screen's sections with increasing [delay] is what makes Pulse
/// feel composed rather than dumped on screen. Kept short (260ms) and small
/// (a few pixels of travel) — motion here is for perceived quality, not
/// decoration.
class PulseFadeIn extends StatefulWidget {
  const PulseFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 260),
    this.offset = 14,
  });

  final Widget child;

  /// How long to wait before starting. Use ~60ms steps to stagger a screen.
  final Duration delay;

  final Duration duration;

  /// Vertical travel, in logical pixels.
  final double offset;

  @override
  State<PulseFadeIn> createState() => _PulseFadeInState();
}

class _PulseFadeInState extends State<PulseFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - _curve.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
