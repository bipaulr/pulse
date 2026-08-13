import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

enum PulseIconButtonTone { surface, muted, accent, inverse, outline }

enum PulseIconButtonShape { circle, squircle }

enum PulseIconButtonSize { small, medium, large }

/// A compact, self-contained icon action.
///
/// Used for the small circular controls that sit in card notches, app bars and
/// quick-action rows throughout Pulse.
class PulseIconButton extends StatelessWidget {
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

  double get _extent => switch (size) {
    PulseIconButtonSize.small => 36,
    PulseIconButtonSize.medium => 44,
    PulseIconButtonSize.large => 54,
  };

  double get _iconSize => switch (size) {
    PulseIconButtonSize.small => 16,
    PulseIconButtonSize.medium => 20,
    PulseIconButtonSize.large => 24,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    final (Color background, Color foreground, BorderSide side) =
        switch (tone) {
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
      borderRadius: shape == PulseIconButtonShape.circle
          ? PulseRadii.chipRadius
          : PulseRadii.iconRadius,
      side: side,
    );

    Widget button = SizedBox(
      width: _extent,
      height: _extent,
      child: Material(
        color: background,
        shape: borderShape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: borderShape,
          child: Center(
            child: Icon(icon, size: _iconSize, color: foreground),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Semantics(button: true, label: tooltip, child: button);
  }
}
