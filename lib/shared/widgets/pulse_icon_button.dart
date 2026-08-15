import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

enum PulseIconButtonTone { surface, muted, accent, inverse, outline }

enum PulseIconButtonShape { circle, squircle }

enum PulseIconButtonSize { small, medium, large }

/// A compact, self-contained icon action.
///
/// Used for the small circular controls that sit in card notches, app bars and
/// quick-action rows throughout Pulse. Press feedback is a small scale, the
/// same technique [PulseButton] and the payment card use — kept consistent
/// rather than mixing in a Material ripple here and scale everywhere else.
class PulseIconButton extends StatefulWidget {
  const PulseIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tone = PulseIconButtonTone.muted,
    this.shape = PulseIconButtonShape.circle,
    this.size = PulseIconButtonSize.medium,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final PulseIconButtonTone tone;
  final PulseIconButtonShape shape;
  final PulseIconButtonSize size;
  final String? tooltip;

  @override
  State<PulseIconButton> createState() => _PulseIconButtonState();
}

class _PulseIconButtonState extends State<PulseIconButton> {
  bool _pressed = false;

  double get _extent => switch (widget.size) {
    PulseIconButtonSize.small => 36,
    PulseIconButtonSize.medium => 44,
    PulseIconButtonSize.large => 54,
  };

  double get _iconSize => switch (widget.size) {
    PulseIconButtonSize.small => 16,
    PulseIconButtonSize.medium => 20,
    PulseIconButtonSize.large => 24,
  };

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    final (Color background, Color foreground, BorderSide side) =
        switch (widget.tone) {
          PulseIconButtonTone.surface => (
            colors.surface,
            colors.textPrimary,
            BorderSide.none,
          ),
          PulseIconButtonTone.muted => (
            colors.surfaceMuted,
            colors.textPrimary,
            BorderSide.none,
          ),
          PulseIconButtonTone.accent => (
            colors.accent,
            colors.onAccent,
            BorderSide.none,
          ),
          PulseIconButtonTone.inverse => (
            colors.surfaceInverse,
            colors.onInverse,
            BorderSide.none,
          ),
          PulseIconButtonTone.outline => (
            Colors.transparent,
            colors.textPrimary,
            BorderSide(color: colors.border),
          ),
        };

    final borderShape = RoundedRectangleBorder(
      borderRadius: widget.shape == PulseIconButtonShape.circle
          ? PulseRadii.chipRadius
          : PulseRadii.iconRadius,
      side: side,
    );

    Widget button = GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: PulseMotion.fast,
        curve: PulseMotion.curve,
        child: Container(
          width: _extent,
          height: _extent,
          alignment: Alignment.center,
          decoration: ShapeDecoration(color: background, shape: borderShape),
          child: Icon(widget.icon, size: _iconSize, color: foreground),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return Semantics(button: true, label: widget.tooltip, child: button);
  }
}
