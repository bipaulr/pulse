import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/pulse_theme.dart';
import 'package:pulse/shared/widgets/widgets.dart';

/// Wraps a component in the real Pulse theme so tests exercise the same
/// token plumbing the app uses.
Widget host(Widget child) {
  return MaterialApp(
    theme: PulseTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('theme', () {
    testWidgets('exposes PulseColors to descendants', (tester) async {
      late PulseColors colors;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              colors = context.pulseColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors.accent, PulseBrand.lime);
      expect(colors.background, PulseBrand.offWhite);
    });

    testWidgets('falls back to the light palette without the extension', (
      tester,
    ) async {
      late PulseColors colors;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              colors = context.pulseColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors, PulseColors.light);
    });

    test('lerp interpolates every role', () {
      final mid = PulseColors.light.lerp(
        PulseColors.light.copyWith(accent: const Color(0xFF000000)),
        1,
      );
      expect(mid.accent, const Color(0xFF000000));
      expect(mid.background, PulseColors.light.background);
    });
  });

  group('PulseAmount', () {
    test('groups thousands and pads decimals', () {
      expect(PulseAmount.formatMagnitude(1376.9, 2), '1,376.90');
      expect(PulseAmount.formatMagnitude(0, 2), '0.00');
      expect(PulseAmount.formatMagnitude(-1234567.5, 2), '1,234,567.50');
      expect(PulseAmount.formatMagnitude(999, 0), '999');
    });

    testWidgets('renders a signed, coloured negative amount', (tester) async {
      await tester.pumpWidget(
        host(
          const PulseAmount(
            value: -128.08,
            sign: PulseAmountSign.signedColoured,
          ),
        ),
      );

      expect(find.text(r'- $128.08'), findsOneWidget);
      final text = tester.widget<Text>(find.text(r'- $128.08'));
      expect(text.style?.color, PulseColors.light.negative);
    });

    testWidgets('renders an unsigned balance', (tester) async {
      await tester.pumpWidget(
        host(const PulseAmount(value: 1376.9, size: PulseAmountSize.xl)),
      );

      expect(find.text(r'$1,376.90'), findsOneWidget);
    });
  });

  group('PulseCard', () {
    testWidgets('renders each tone', (tester) async {
      for (final tone in PulseCardTone.values) {
        await tester.pumpWidget(
          host(PulseCard(tone: tone, child: Text(tone.name))),
        );
        expect(find.text(tone.name), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('carves a notch and hosts its action', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 320,
            height: 200,
            child: PulseCard(
              tone: PulseCardTone.accent,
              notchAction: PulseIconButton(icon: Icons.more_horiz_rounded),
              child: Text('Balance'),
            ),
          ),
        ),
      );

      expect(find.text('Balance'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is tappable', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          PulseCard(
            onTap: () => taps++,
            child: const Text('Tap me'),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      expect(taps, 1);
    });
  });

  group('PulseButton', () {
    testWidgets('fires onPressed when enabled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(PulseButton(label: 'Save', onPressed: () => taps++)),
      );

      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });

    testWidgets('ignores taps while disabled', (tester) async {
      await tester.pumpWidget(host(const PulseButton(label: 'Save')));

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a spinner instead of the label when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(PulseButton(label: 'Save', loading: true, onPressed: () {})),
      );

      expect(find.text('Save'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders every variant and size', (tester) async {
      for (final variant in PulseButtonVariant.values) {
        for (final size in PulseButtonSize.values) {
          await tester.pumpWidget(
            host(
              PulseButton(
                label: '${variant.name}/${size.name}',
                variant: variant,
                size: size,
                onPressed: () {},
              ),
            ),
          );
        }
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('PulseChip', () {
    testWidgets('dropdown variant shows a chevron', (tester) async {
      await tester.pumpWidget(host(const PulseChip.dropdown(label: 'Today')));

      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets('selected chips use the accent tone', (tester) async {
      await tester.pumpWidget(
        host(const PulseChip(label: 'Week', selected: true)),
      );

      // The animated colour now lives on the AnimatedContainer wrapping the
      // chip's Material (which stays transparent so it doesn't paint under
      // the animated background) — see PulseChip's motion pass.
      final container = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text('Week'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final decoration = container.decoration as ShapeDecoration;
      expect(decoration.color, PulseColors.light.accent);
    });
  });

  group('lists and headers', () {
    testWidgets('PulseTransactionTile shows title, subtitle and amount', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PulseTransactionTile(
            title: 'Gym',
            subtitle: 'Payment',
            amount: -30.08,
            trailingCaption: '9:41',
          ),
        ),
      );

      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text(r'- $30.08'), findsOneWidget);
      expect(find.text('9:41'), findsOneWidget);
    });

    testWidgets('PulseSectionHeader renders its trailing action', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PulseSectionHeader(
            title: 'All Transactions',
            trailing: PulseChip.dropdown(label: 'Today'),
          ),
        ),
      );

      expect(find.text('All Transactions'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('PulseSkeleton animates without error', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseSkeleton.circle(),
              PulseSkeleton.text(width: 120),
              PulseSkeleton.card(width: 200),
            ],
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      // Unmount to prove the controller is disposed cleanly.
      await tester.pumpWidget(host(const SizedBox.shrink()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('PulseEmptyState renders its action', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          PulseEmptyState(
            title: 'No transactions',
            message: 'Once money moves, it shows up here.',
            actionLabel: 'Add one',
            onAction: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Add one'));
      expect(taps, 1);
    });

    testWidgets('PulseErrorState retries', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        host(PulseErrorState(onRetry: () => retries++)),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });
  });

  group('PulseBottomNavigation', () {
    testWidgets('labels only the selected destination and reports taps', (
      tester,
    ) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.light,
          home: Scaffold(
            bottomNavigationBar: PulseBottomNavigation(
              currentIndex: 0,
              onDestinationSelected: (index) => selected = index,
              destinations: const [
                PulseNavigationDestination(
                  icon: Icons.grid_view_rounded,
                  label: 'Home',
                ),
                PulseNavigationDestination(
                  icon: Icons.credit_card_rounded,
                  label: 'Cards',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cards'), findsNothing);

      await tester.tap(find.byIcon(Icons.credit_card_rounded));
      expect(selected, 1);
    });
  });
}
