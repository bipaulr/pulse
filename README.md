# Pulse

Pulse is a premium personal-finance app concept built in Flutter — a home
dashboard, card wallet, transaction feed, and a spending-analytics screen with
a hand-built chart, all sharing one custom design system. It runs entirely on
local mock data, so the whole app is explorable without a backend.

## Features

- **Home dashboard** — balance summary, a notched virtual-card widget, quick
  actions, and a recent-activity feed
- **Card wallet** — a swipeable card carousel with per-card details, freeze /
  unfreeze, a masked PIN reveal, and a replace-card confirmation flow
- **Transactions** — a searchable, filterable, date-grouped transaction feed
  with a dedicated details screen
- **Activity & analytics** — total spending, a Week/Month/Quarter/Year period
  selector, an interactive custom-painted bar chart, income vs. expense
  totals, and a category breakdown
- **Custom spending visualization** — `PulseSpendingChart`, built from plain
  widgets and a small `CustomPainter`, with no charting package
- **Riverpod state management** throughout, including a small pure-Dart
  analytics layer decoupled from the UI
- **Responsive layout** — tuned for common phone widths and gracefully
  constrained on desktop-width browser windows
- **A component library** (`PulseCard`, `PulseButton`, `PulseChip`,
  `PulseAmount`, `PulseTransactionTile`, `PulseBottomNavigation`, and more)
  that keeps every screen visually consistent
- **Unit and widget test coverage** across the design system, screens, and
  analytics logic

## Not included

This is a UI/UX-focused MVP. There is no backend, no REST API, no real
authentication, no payment processing, no offline sync, and no persisted
storage — all data is generated locally each run. Android has not been
tested; Chrome is the supported and verified target.

## Tech stack

- [Flutter](https://flutter.dev) & Dart (Material 3, custom theme)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) for state
  management
- [go_router](https://pub.dev/packages/go_router) for declarative,
  shell-based navigation
- `flutter_test` for unit and widget tests

No charting, networking, or persistence packages are used — the chart is
hand-built and the data layer is local by design.

## Architecture

```
Flutter UI  (screens + the Pulse component library)
     │  ref.watch
     ▼
Riverpod providers  (per-feature state: selection, filters, period)
     │
     ▼
Analytics layer  (ActivityAnalytics — pure functions, no Flutter import)
     │
     ▼
Mock data layer  (MockDataset — one shared source of sample transactions,
                  cards, and balances)
```

Every screen reads through a repository interface (`HomeRepository`,
`CardsRepository`, `TransactionsRepository`), so the mock implementations are
a swappable seam rather than something baked into the UI — a REST-backed
implementation is a binding change, not a rewrite.

```
lib/
  main.dart, app.dart       entry point, MaterialApp.router + theme wiring
  core/
    theme/                  design tokens: colors, type scale, spacing,
                             radii, shadows, the signature notched card shape
    routing/                GoRouter config and the shared app shell
    clock.dart               the app's single "now" — overridable in tests
  shared/
    data/                   MockDataset — the one source of sample data
    models/                 domain models (transactions, cards, etc.)
    widgets/                the Pulse component library
  features/
    home/ cards/ transactions/ activity/
                             one folder per screen, each with its own
                             data/ (repositories, providers) and widgets/
```

## Testing

**100 tests, all passing** — unit tests for the analytics and model logic,
and widget tests covering every screen, its interactions, and its layout at
five viewport widths (320, 360, 390, 412, and a desktop width) with zero
overflow.

```sh
flutter analyze   # no issues
flutter test      # 100 passed
```

## Screenshots

Not yet included. To capture your own:

```sh
flutter run -d chrome --web-browser-flag="--window-size=412,915"
```

then screenshot each tab (Home, Cards, Transactions, Activity) and drop the
images under a `screenshots/` folder, linked here.

## Running locally

Chrome is the primary and verified target.

```sh
flutter pub get
flutter run -d chrome
```

To check a specific phone width, launch with a fixed window size, e.g.:

```sh
flutter run -d chrome --web-browser-flag="--window-size=390,844"
```
