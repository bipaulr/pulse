import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';

/// The small lime "P" mark used to give Login, Sign Up and Forgot Password a
/// consistent brand presence without repeating Splash's full-screen treatment.
class PulseBrandMark extends StatelessWidget {
  const PulseBrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
      child: Text(
        'P',
        style: PulseTypography.headingMd.copyWith(
          color: colors.onAccent,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}
