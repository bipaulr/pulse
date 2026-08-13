import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

/// One entry in the [PulseBottomNavigation] bar.
@immutable
class PulseNavigationDestination {
  const PulseNavigationDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The floating pill navigation bar.
///
/// A dark capsule that hovers above the canvas; the active destination expands
/// into a lime pill with its label. Nothing about it is a Material
/// [NavigationBar] — that widget is disabled in the theme.
class PulseBottomNavigation extends StatelessWidget {
  const PulseBottomNavigation({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final List<PulseNavigationDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const double _barHeight = 68;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        PulseSpacing.screenGutter,
        0,
        PulseSpacing.screenGutter,
        bottomInset > 0 ? bottomInset * 0.5 + PulseSpacing.sm : PulseSpacing.lg,
      ),
      // Matches the content column, so on a wide window the bar sits under the
      // content instead of stretching the whole viewport. No effect on phones.
      // heightFactor pins the height to the bar itself; without it Center
      // fills the loose height the Scaffold offers and the bar floats.
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PulseSpacing.maxContentWidth,
          ),
          child: Container(
        height: _barHeight,
        padding: const EdgeInsets.symmetric(horizontal: PulseSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceInverse,
          borderRadius: PulseRadii.navigationRadius,
          boxShadow: PulseShadows.navigation(colors.shadow),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < destinations.length; i++)
              // Only the selected pill carries a label, so only it can grow
              // past its share. Letting it flex keeps a long destination name
              // — or a large accessibility text scale — from overflowing the
              // bar.
              if (i == currentIndex)
                Flexible(
                  child: _NavigationItem(
                    destination: destinations[i],
                    selected: true,
                    onTap: () => onDestinationSelected(i),
                  ),
                )
              else
                _NavigationItem(
                  destination: destinations[i],
                  selected: false,
                  onTap: () => onDestinationSelected(i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final PulseNavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final foreground = selected
        ? colors.onAccent
        : colors.onInverse.withValues(alpha: 0.55);

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 46,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? PulseSpacing.lg : PulseSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.accent : Colors.transparent,
            borderRadius: PulseRadii.chipRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(destination.icon, size: 22, color: foreground),
              // The label only exists for the active destination, which is what
              // gives the bar its expanding-pill motion.
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: PulseSpacing.sm),
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: PulseTypography.labelSm.copyWith(
                              color: foreground,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
