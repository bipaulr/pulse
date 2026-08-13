# Pulse

A premium personal-finance app built with Flutter.

**Status: Phase 1 — foundation and design system.** The four tabs exist and are
navigable, but each renders a placeholder; no feature screens, data or backend
yet.

## Getting started

```sh
flutter pub get
flutter run
```

## Layout

```
lib/
  main.dart              entry point — wraps the app in a ProviderScope
  app.dart               MaterialApp.router + theme wiring
  core/
    theme/               design tokens and ThemeData
    routing/             GoRouter config and the tabbed app shell
  shared/widgets/        the Pulse component library
  features/              one folder per tab
```

## Design system

All tokens live in `lib/core/theme/`:

| File                   | Contains                                        |
| ---------------------- | ----------------------------------------------- |
| `pulse_colors.dart`    | brand values + semantic roles (`ThemeExtension`) |
| `pulse_typography.dart`| the type scale and its `TextTheme` mapping       |
| `pulse_spacing.dart`   | the 4pt spacing scale                           |
| `pulse_radii.dart`     | corner radii per surface kind                   |
| `pulse_shadows.dart`   | three deliberately subtle elevations            |
| `pulse_shapes.dart`    | `PulseNotchedBorder`, the signature card shape   |

Widgets never reference raw colours — they read `context.pulseColors`, so
adding a dark palette means defining `PulseColors.dark` and passing it to
`PulseTheme`, with no changes to component code.

## Checks

```sh
flutter analyze
flutter test
```
