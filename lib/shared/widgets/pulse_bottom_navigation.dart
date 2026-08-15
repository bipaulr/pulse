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
/// A dark capsule that hovers above the canvas. A single lime blob travels
/// behind the icons to the selected destination — the bar itself no longer
/// paints a background per item, so there is exactly one thing moving rather
/// than four things each reacting independently. Nothing about it is a
/// Material [NavigationBar] — that widget is disabled in the theme.
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
            // Measured here, outside the Stack, and handed to the blob as a
            // plain number — a LayoutBuilder inside a Stack can't measure the
            // Stack's own size for one of its Positioned children to consume,
            // since that child's constraints are derived from the position
            // it's still trying to compute.
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _NavBlob(
                      index: currentIndex,
                      count: destinations.length,
                      barWidth: constraints.maxWidth,
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < destinations.length; i++)
                          Expanded(
                            child: _NavigationItem(
                              destination: destinations[i],
                              selected: i == currentIndex,
                              onTap: () => onDestinationSelected(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The travelling lime pill.
///
/// Tracks its left and right edges as two independently-eased values rather
/// than one rectangle sliding as a block. On a transition, the edge in the
/// direction of travel arrives first (using [_leadInterval]) while the
/// trailing edge is still catching up (using [_lagInterval]) — for a few
/// frames the pill is wider than its resting size, then it compresses back to
/// normal as the trailing edge lands. That stretch-then-settle is what reads
/// as a soft blob moving through the bar rather than a rectangle sliding.
class _NavBlob extends StatefulWidget {
  const _NavBlob({
    required this.index,
    required this.count,
    required this.barWidth,
  });

  final int index;
  final int count;

  /// Measured by the caller, outside the Stack — see the note at the call
  /// site for why this can't be measured from in here.
  final double barWidth;

  @override
  State<_NavBlob> createState() => _NavBlobState();
}

class _NavBlobState extends State<_NavBlob> with SingleTickerProviderStateMixin {
  static const _pillHeight = 46.0;
  static const _inset = 2.0;
  static const _leadInterval = Interval(0.0, 0.82, curve: PulseMotion.emphasizedCurve);
  static const _lagInterval = Interval(0.18, 1.0, curve: PulseMotion.emphasizedCurve);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PulseMotion.emphasis,
  )..value = 1;

  late double _fromLeft = widget.index.toDouble();
  late double _toLeft = widget.index.toDouble();
  bool _movingRight = true;

  @override
  void didUpdateWidget(covariant _NavBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;

    // Capture wherever the blob visually is right now — including mid-flight
    // — so a second tap during a transition redirects smoothly instead of
    // snapping back to start first.
    _fromLeft = _currentLeft(_controller.value);
    _toLeft = widget.index.toDouble();
    _movingRight = widget.index > oldWidget.index;

    if (PulseMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _currentLeft(double t) {
    final curve = _movingRight ? _lagInterval : _leadInterval;
    return _fromLeft + (_toLeft - _fromLeft) * curve.transform(t);
  }

  double _currentRight(double t) {
    final curve = _movingRight ? _leadInterval : _lagInterval;
    final fromRight = _fromLeft + 1;
    final toRight = _toLeft + 1;
    return fromRight + (toRight - fromRight) * curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final slotWidth = widget.barWidth / widget.count;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final left = _currentLeft(_controller.value) * slotWidth + _inset;
        final right = _currentRight(_controller.value) * slotWidth - _inset;
        return Positioned(
          left: left,
          width: (right - left).clamp(0.0, widget.barWidth),
          height: _pillHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: PulseRadii.chipRadius,
            ),
          ),
        );
      },
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
        child: SizedBox(
          height: 46,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The blob sits behind this, so only the icon itself needs to
                // react — a small scale-up plus the colour swap is enough to
                // read as "selected" without duplicating the pill.
                AnimatedScale(
                  scale: selected ? 1.08 : 1.0,
                  duration: PulseMotion.fast,
                  curve: PulseMotion.curve,
                  child: AnimatedDefaultTextStyle(
                    duration: PulseMotion.standard,
                    curve: PulseMotion.curve,
                    style: const TextStyle(),
                    child: Icon(destination.icon, size: 22, color: foreground),
                  ),
                ),
                // The label only exists for the active destination, which is
                // what gives the bar its expanding-pill motion.
                Flexible(
                  child: AnimatedSize(
                    duration: PulseMotion.standard,
                    curve: PulseMotion.curve,
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
      ),
    );
  }
}
