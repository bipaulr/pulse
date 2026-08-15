import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/pulse_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'data/onboarding_controller.dart';
import 'widgets/onboarding_visual.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.style,
    required this.headline,
    required this.body,
  });

  final OnboardingVisualStyle style;
  final String headline;
  final String body;
}

const _pages = [
  _OnboardingPage(
    style: OnboardingVisualStyle.home,
    headline: 'Your money, at a glance.',
    body:
        'Balance, cards and recent activity — all on one calm screen the '
        'moment you open Pulse.',
  ),
  _OnboardingPage(
    style: OnboardingVisualStyle.activity,
    headline: 'Understand where it goes.',
    body:
        'A spending picture that actually makes sense, not a spreadsheet '
        'you have to decode.',
  ),
  _OnboardingPage(
    style: OnboardingVisualStyle.cardsAndTransactions,
    headline: 'Everything in one place.',
    body:
        'Every card and every transaction, tracked together and easy to '
        'find again.',
  ),
];

/// Three short, swipeable screens shown once, before the first login.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLastPage => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (mounted) context.go(AppRoutes.login);
  }

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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PulseSpacing.md,
                    vertical: PulseSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: _page > 0
                            ? PulseIconButton(
                                icon: Icons.arrow_back_rounded,
                                tone: PulseIconButtonTone.surface,
                                tooltip: 'Back',
                                onPressed: () => _goToPage(_page - 1),
                              )
                            : null,
                      ),
                      const Spacer(),
                      if (!_isLastPage)
                        PulseButton(
                          label: 'Skip',
                          variant: PulseButtonVariant.ghost,
                          size: PulseButtonSize.small,
                          onPressed: _finish,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _page = index),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PulseSpacing.screenGutter,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OnboardingVisual(style: page.style),
                            const SizedBox(height: PulseSpacing.xxxl),
                            Text(
                              page.headline,
                              style: PulseTypography.displayLg.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: PulseSpacing.sm),
                            Text(
                              page.body,
                              style: PulseTypography.bodyLg.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _Dots(count: _pages.length, index: _page),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PulseSpacing.screenGutter,
                    PulseSpacing.xl,
                    PulseSpacing.screenGutter,
                    PulseSpacing.lg,
                  ),
                  child: PulseButton(
                    label: _isLastPage ? 'Get Started' : 'Next',
                    expand: true,
                    size: PulseButtonSize.large,
                    onPressed: _isLastPage ? _finish : () => _goToPage(_page + 1),
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

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: PulseSpacing.xs),
            height: 6,
            width: i == index ? 22 : 6,
            decoration: BoxDecoration(
              color: i == index ? colors.accent : colors.border,
              borderRadius: PulseRadii.chipRadius,
            ),
          ),
      ],
    );
  }
}
