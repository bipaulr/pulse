import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';

/// Shared chrome for every auth screen except Splash.
///
/// Centres content in the same width-constrained column the rest of the app
/// uses on a wide window, and optionally shows a back control — Login and
/// Sign Up swap places by replacing the route (no way back is expected), so
/// only screens reached by pushing (Forgot Password) pass [onBack].
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.onBack});

  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: PulseSpacing.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (onBack != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PulseSpacing.screenGutter,
                      PulseSpacing.md,
                      PulseSpacing.screenGutter,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: PulseIconButton(
                        icon: Icons.arrow_back_rounded,
                        tone: PulseIconButtonTone.surface,
                        tooltip: 'Back',
                        onPressed: onBack,
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      PulseSpacing.screenGutter,
                      PulseSpacing.xl,
                      PulseSpacing.screenGutter,
                      PulseSpacing.xxl,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
