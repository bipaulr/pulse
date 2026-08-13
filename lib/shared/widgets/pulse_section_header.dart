import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

/// A bold section title with an optional action on the right.
///
/// This is the rhythm marker for Pulse screens — heavy title on the left,
/// quiet chip or link on the right.
class PulseSectionHeader extends StatelessWidget {
  const PulseSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PulseSpacing.screenGutter,
    ),
  });

  final String title;
  final String? subtitle;

  /// Typically a `PulseChip.dropdown` or a small text button.
  final Widget? trailing;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: PulseTypography.headingMd.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: PulseSpacing.xxs),
                  Text(
                    subtitle!,
                    style: PulseTypography.metadata.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: PulseSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}
