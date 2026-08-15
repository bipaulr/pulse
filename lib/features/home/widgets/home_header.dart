import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Greeting, avatar and notifications.
///
/// Deliberately light: the balance below it is the screen's headline, so the
/// header stays at heading rather than display weight.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.user,
    this.onNotificationsTap,
    this.onAvatarTap,
  });

  final UserProfile user;
  final VoidCallback? onNotificationsTap;

  /// Opens the profile sheet — the avatar is the one existing element that
  /// can carry this without adding any new chrome to the header.
  final VoidCallback? onAvatarTap;

  static String greetingFor(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.screenGutter,
      ),
      child: Row(
        children: [
          Semantics(
            button: onAvatarTap != null,
            label: 'Profile',
            child: GestureDetector(
              onTap: onAvatarTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 46,
                width: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  user.initials,
                  style: PulseTypography.labelSm.copyWith(
                    color: colors.onAccent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: PulseSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greetingFor(DateTime.now()),
                  style: PulseTypography.metadata.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: PulseSpacing.xxs),
                Text(
                  'Hi, ${user.firstName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PulseTypography.headingLg.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PulseSpacing.sm),
          _NotificationButton(onTap: onNotificationsTap),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PulseIconButton(
          icon: Icons.notifications_none_rounded,
          tone: PulseIconButtonTone.surface,
          onPressed: onTap,
          tooltip: 'Notifications',
        ),
        // Unread marker — a lime dot is enough; a count would pull focus away
        // from the balance.
        Positioned(
          top: 10,
          right: 11,
          child: Container(
            height: 9,
            width: 9,
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: colors.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
