import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

enum PulseButtonVariant {
  /// Lime pill — the single primary action on a screen.
  primary,

  /// Solid ink. Used when lime is already carrying something else nearby.
  dark,

  /// Quiet neutral fill for secondary actions.
  soft,

  /// Outline only.
  outline,

  /// Text only, no container.
  ghost,
}

enum PulseButtonSize { small, medium, large }

/// The Pulse button.
///
/// Pill-shaped, flat, with a slight press-scale instead of a Material ripple —
/// the goal is that it never reads as a stock Flutter button.
class PulseButton extends StatefulWidget {
  const PulseButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PulseButtonVariant.primary,
    this.size = PulseButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PulseButtonVariant variant;
  final PulseButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Stretch to the available width.
  final bool expand;

  final bool loading;

  bool get _enabled => onPressed != null && !loading;

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton> {
  bool _pressed = false;

  double get _height => switch (widget.size) {
    PulseButtonSize.small => 40,
    PulseButtonSize.medium => 52,
    PulseButtonSize.large => 60,
  };

  double get _horizontalPadding => switch (widget.size) {
    PulseButtonSize.small => PulseSpacing.lg,
    PulseButtonSize.medium => PulseSpacing.xxl,
    PulseButtonSize.large => PulseSpacing.xxxl,
  };

  TextStyle get _textStyle => switch (widget.size) {
    PulseButtonSize.small => PulseTypography.labelSm,
    PulseButtonSize.medium => PulseTypography.label,
    PulseButtonSize.large => PulseTypography.label.copyWith(fontSize: 16),
  };

  double get _iconSize => widget.size == PulseButtonSize.small ? 16 : 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final enabled = widget._enabled;

    final (Color background, Color foreground, BorderSide side) =
        switch (widget.variant) {
          PulseButtonVariant.primary => (
            _pressed ? colors.accentPressed : colors.accent,
            colors.onAccent,
            BorderSide.none,
          ),
          PulseButtonVariant.dark => (
            colors.textPrimary,
            colors.onInverse,
            BorderSide.none,
          ),
          PulseButtonVariant.soft => (
            colors.surfaceMuted,
            colors.textPrimary,
            BorderSide.none,
          ),
          PulseButtonVariant.outline => (
            Colors.transparent,
            colors.textPrimary,
            BorderSide(color: colors.border),
          ),
          PulseButtonVariant.ghost => (
            Colors.transparent,
            colors.textPrimary,
            BorderSide.none,
          ),
        };

    Widget content;
    if (widget.loading) {
      content = SizedBox(
        height: _iconSize,
        width: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(foreground),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: _iconSize, color: foreground),
            const SizedBox(width: PulseSpacing.sm),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _textStyle.copyWith(color: foreground),
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: PulseSpacing.sm),
            Icon(widget.trailingIcon, size: _iconSize, color: foreground),
          ],
        ],
      );
    }

    final button = AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: enabled ? 1 : 0.4,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: _height,
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          decoration: ShapeDecoration(
            color: background,
            shape: RoundedRectangleBorder(
              borderRadius: PulseRadii.chipRadius,
              side: side,
            ),
          ),
          // `widthFactor: 1` keeps the button hugging its label under loose
          // constraints; when [expand] is set the outer SizedBox makes the
          // constraints tight and this simply centres the content.
          child: Center(widthFactor: 1, child: content),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: widget.expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}
