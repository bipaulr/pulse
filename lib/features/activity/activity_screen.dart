import 'package:flutter/material.dart';

import '../../core/routing/placeholder_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Activity',
      icon: Icons.bar_chart_rounded,
      description: 'Spending charts and category breakdowns will live here.',
    );
  }
}
