import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/app_preferences.dart';

/// Whether the user has ever finished (or skipped) onboarding.
///
/// Kept separate from [AuthState] on purpose: onboarding is a one-time,
/// permanent flag, while auth can flip back to unauthenticated on logout —
/// a returning, logged-out user should land on Login, never back on
/// onboarding.
class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.watch(appPreferencesProvider).onboardingComplete;

  Future<void> complete() async {
    await ref.read(appPreferencesProvider).setOnboardingComplete(true);
    state = true;
  }
}

final onboardingCompleteProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
