import 'package:flutter/material.dart';

import '../../shared/widgets/widgets.dart';
import '../theme/pulse_theme.dart';

/// Temporary stand-in for a feature screen.
///
/// Phase 1 ships the foundation only; each tab renders this until its real
/// screen is built. It uses the Pulse component library rather than stock
/// Material so the design system is exercised end to end from day one.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: PulseSpacing.sm,
            bottom: PulseSpacing.bottomNavClearance,
          ),
          children: [
            PulseSectionHeader(
              title: title,
              subtitle: 'Coming in the next phase',
              trailing: const PulseChip.dropdown(label: 'Today'),
            ),
            const SizedBox(height: PulseSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PulseSpacing.screenGutter,
              ),
              child: PulseCard(
                padding: EdgeInsets.zero,
                child: PulseEmptyState(
                  title: title,
                  message: description,
                  icon: icon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
