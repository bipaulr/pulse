import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';

/// One bar's worth of data.
///
/// Deliberately primitive so the chart has no dependency on any feature's
/// models — anything that can produce a label and a value can plot here.
@immutable
class PulseChartBar {
  const PulseChartBar({required this.label, required this.value});

  /// Short axis label, e.g. `Aug`, `Q3`, `2026`.
  final String label;

  /// Magnitude. Negative values are treated as zero.
  final double value;
}

/// Pulse's bar chart: a dark panel with lime bars and one citron selection.
///
/// Hand-built from widgets plus a very small [CustomPainter] for the baseline
/// grid — no charting package. Bars animate up on first build and tween
/// between datasets when the data changes.
class PulseSpendingChart extends StatefulWidget {
  const PulseSpendingChart({
    super.key,
    required this.bars,
    required this.selectedIndex,
    required this.onBarSelected,
    this.currencySymbol = '₹',
    this.height = 168,
  });

  final List<PulseChartBar> bars;

  /// Index of the highlighted bar. Out-of-range values highlight nothing.
  final int selectedIndex;

  final ValueChanged<int> onBarSelected;

  final String currencySymbol;

  /// Height of the plotting area, excluding the axis labels beneath it.
  final double height;

  static const _animationDuration = Duration(milliseconds: 320);

  @override
  State<PulseSpendingChart> createState() => _PulseSpendingChartState();
}

class _PulseSpendingChartState extends State<PulseSpendingChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PulseSpendingChart._animationDuration,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  /// Values the current animation is tweening away from, so a period change
  /// morphs the bars rather than dropping them to zero and regrowing.
  late List<double> _from = List.filled(widget.bars.length, 0);
  late List<double> _to = _valuesOf(widget.bars);

  double _fromMax = 0;
  late double _toMax = _maxOf(_to);

  static List<double> _valuesOf(List<PulseChartBar> bars) =>
      [for (final bar in bars) math.max(0, bar.value)];

  static double _maxOf(List<double> values) =>
      values.isEmpty ? 0 : values.reduce(math.max);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(PulseSpendingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _valuesOf(widget.bars);
    if (_sameValues(next, _to)) return;

    // Start the new tween from whatever is currently on screen.
    _from = _currentValues();
    _fromMax = _currentMax();
    _to = next;
    _toMax = _maxOf(next);
    _controller.forward(from: 0);
  }

  bool _sameValues(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<double> _currentValues() {
    final t = _curve.value;
    return [
      for (var i = 0; i < _to.length; i++)
        _lerp(i < _from.length ? _from[i] : 0, _to[i], t),
    ];
  }

  double _currentMax() => _lerp(_fromMax, _toMax, _curve.value);

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Axis ticks: four evenly spaced levels up to a rounded ceiling.
  List<double> _ticks(double max) {
    if (max <= 0) return const [0, 0, 0, 0];
    return [max, max * 2 / 3, max / 3, 0];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final axisColor = colors.onInverse.withValues(alpha: 0.45);

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final values = _currentValues();
        final max = _currentMax();
        // Headroom so the tallest bar never touches the top gridline.
        final ceiling = max <= 0 ? 1.0 : max * 1.12;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AxisLabels(
                    ticks: _ticks(ceiling),
                    color: axisColor,
                    currencySymbol: widget.currencySymbol,
                  ),
                  const SizedBox(width: PulseSpacing.sm),
                  Expanded(
                    child: CustomPaint(
                      // The only painting the chart does: three hairlines.
                      painter: _GridPainter(
                        color: colors.onInverse.withValues(alpha: 0.08),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < widget.bars.length; i++)
                            Expanded(
                              child: _Bar(
                                heightFactor: (values[i] / ceiling).clamp(
                                  0.0,
                                  1.0,
                                ),
                                selected: i == widget.selectedIndex,
                                onTap: () => widget.onBarSelected(i),
                                semanticLabel: widget.bars[i].label,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PulseSpacing.sm),
            Row(
              children: [
                // Keeps the labels aligned under their bars.
                const SizedBox(width: _AxisLabels.width + PulseSpacing.sm),
                for (var i = 0; i < widget.bars.length; i++)
                  Expanded(
                    child: Text(
                      widget.bars[i].label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: PulseTypography.caption.copyWith(
                        color: i == widget.selectedIndex
                            ? colors.accentAlt
                            : axisColor,
                        fontWeight: i == widget.selectedIndex
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AxisLabels extends StatelessWidget {
  const _AxisLabels({
    required this.ticks,
    required this.color,
    required this.currencySymbol,
  });

  final List<double> ticks;
  final Color color;
  final String currencySymbol;

  static const width = 34.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final tick in ticks)
            Text(
              compactAmount(tick, currencySymbol),
              maxLines: 1,
              style: PulseTypography.caption.copyWith(color: color),
            ),
        ],
      ),
    );
  }
}

/// `₹0` · `₹8k` · `₹1.2L` — short enough for a chart axis.
String compactAmount(double value, String symbol) {
  final magnitude = value.abs();
  if (magnitude < 1000) return '$symbol${magnitude.round()}';
  if (magnitude < 100000) return '$symbol${(magnitude / 1000).round()}k';
  return '$symbol${(magnitude / 100000).toStringAsFixed(1)}L';
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.heightFactor,
    required this.selected,
    required this.onTap,
    required this.semanticLabel,
  });

  final double heightFactor;
  final bool selected;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        // Opaque so the whole column height is tappable, not just the bar.
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PulseSpacing.xs),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              // A hairline of bar always shows, so empty buckets read as
              // "nothing here" rather than as a rendering gap.
              heightFactor: math.max(heightFactor, 0.012),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  // Both states are fully opaque: lime at reduced alpha over
                  // the ink panel turns a muddy olive. The selection reads by
                  // hue instead, which is also how the reference does it.
                  color: selected ? colors.accentAlt : colors.accent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three faint horizontal rules. No vertical gridlines, no axis spine.
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var i = 0; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
