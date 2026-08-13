import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

enum PulseChipTone { muted, accent, accentSoft, inverse, outline }

/// A small pill for filters, period selectors and status labels.
///
/// The reference language uses these constantly — "Today ⌄", "Month ⌄",
/// "Expense ⌄" — so a trailing chevron is a first-class option via
/// [trailingIcon].
class PulseChip extends StatelessWidget {
  const PulseChip({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.tone = PulseChipTone.muted,
    this.onTap,
    this.selected = false,
    this.dense = false,
  });

  /// Convenience constructor for the dropdown-style chips used in section
  /// headers.
  const PulseChip.dropdown({
    Key? key,
    required String label,
    VoidCallback? onTap,
    PulseChipTone tone = PulseChipTone.muted,
    bool dense = false,
  }) : this(
         key: key,
         label: label,
         onTap: onTap,
         tone: tone,
         dense: dense,
         trailingIcon: Icons.keyboard_arrow_down_rounded,
       );

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final PulseChipTone tone;
  final VoidCallback? onTap;

  /// Selected chips promote themselves to the accent tone.
  final bool selected;

  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final effectiveTone = selected ? PulseChipTone.accent : tone;

    final (Color background, Color foreground, BorderSide side) =
        switch (effectiveTone) {
          PulseChipTone.muted => (
            colors.surfaceMuted,
            colors.textPrimary,
            BorderSide.none,
          ),
          PulseChipTone.accent => (
            colors.accent,
            colors.onAccent,
            BorderSide.none,
          ),
          PulseChipTone.accentSoft => (
            colors.accentSoft,
            colors.onAccent,
            BorderSide.none,
          ),
          PulseChipTone.inverse => (
            colors.surfaceInverse,
            colors.onInverse,
            BorderSide.none,
          ),
          PulseChipTone.outline => (
            Colors.transparent,
            colors.textPrimary,
            BorderSide(color: colors.border),
          ),
        };

    final iconSize = dense ? 14.0 : 16.0;
    final shape = RoundedRectangleBorder(
      borderRadius: PulseRadii.chipRadius,
      side: side,
    );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? PulseSpacing.md : PulseSpacing.lg,
        vertical: dense ? PulseSpacing.xs + 2 : PulseSpacing.sm + 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: foreground),
            const SizedBox(width: PulseSpacing.xs + 2),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (dense ? PulseTypography.caption : PulseTypography.labelSm)
                  .copyWith(color: foreground),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: PulseSpacing.xs),
            Icon(trailingIcon, size: iconSize + 2, color: foreground),
          ],
        ],
      ),
    );

    return Material(
      color: background,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, customBorder: shape, child: content),
    );
  }
}
