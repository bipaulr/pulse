import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import 'data/auth_controller.dart';
import 'data/onboarding_controller.dart';

/// How long Splash's entrance plays before it navigates away.
///
/// The fade/scale animation runs for exactly this long, so there is nothing
/// else to keep in sync. Overridden to near-zero in tests, the same idiom as
/// `nowProvider`, so the suite never pays the real animation's wall-clock cost.
final splashDurationProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 850),
);

/// The app's first frame: a branded moment, then a decision.
///
/// Deliberately exempt from the router's redirect guard (see `app_router.dart`)
/// so it owns its own timing instead of being pre-empted mid-animation — it
/// reads auth/onboarding state once, when its entrance finishes, and picks
/// exactly one destination.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: ref.read(splashDurationProvider),
  );

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(_navigate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() {
    if (!mounted) return;

    final auth = ref.read(authControllerProvider);
    final onboarded = ref.read(onboardingCompleteProvider);

    final destination = auth.isAuthenticated
        ? AppRoutes.home
        : onboarded
        ? AppRoutes.login
        : AppRoutes.onboarding;

    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Scaffold(
      backgroundColor: colors.accent,
      body: Center(
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) {
            return Opacity(
              opacity: _scale.value,
              child: Transform.scale(
                scale: 0.85 + (0.15 * _scale.value),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pulse',
                style: PulseTypography.amountXl.copyWith(
                  color: colors.onAccent,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: PulseSpacing.sm),
              Text(
                'Clarity for your money',
                style: PulseTypography.bodyLg.copyWith(
                  color: colors.onAccent.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
