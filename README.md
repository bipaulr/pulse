# Pulse

Pulse is a premium personal-finance app concept built in Flutter — a full
onboarding and mock-login flow leading into a home dashboard, card wallet,
transaction feed, and a spending-analytics screen with a hand-built chart, all
sharing one custom design system. It runs entirely on local mock data, so the
whole app is explorable without a backend.

## Features

- **Splash, onboarding & auth flow** — a branded launch screen, a three-page
  onboarding carousel (shown once), and mock Login / Sign Up / Forgot Password
  screens gating the rest of the app
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
  analytics layer decoupled from the UI, and a centralized auth state
  (`Unauthenticated` / `Authenticating` / `Authenticated`)
- **Responsive layout** — tuned for common phone widths and gracefully
  constrained on desktop-width browser windows
- **A component library** (`PulseCard`, `PulseButton`, `PulseChip`,
  `PulseAmount`, `PulseTextField`, `PulseTransactionTile`,
  `PulseBottomNavigation`, and more) that keeps every screen visually
  consistent
- **Unit and widget test coverage** across the design system, screens,
  analytics logic, and the auth/routing flow

## Authentication is mock and local-only

There is no backend, no server, and no real account system. "Signing in" and
"signing up" are simulated by a small in-memory repository with a short,
artificial delay standing in for a network call. **No password is ever
transmitted or hashed anywhere** — this is a UI/UX demonstration, not a
security implementation, and must not be treated as one.

What *is* real: a session is persisted locally via
[`shared_preferences`](https://pub.dev/packages/shared_preferences) (Chrome's
`localStorage` under the hood), so a signed-in session and "onboarding seen"
survive a page reload. That is the entire persistence layer in the app — no
transactions, cards, or other data are stored locally; they regenerate from
the mock dataset each run.

**Demo account** — use this to log in without signing up:

```
Email:    demo@pulse.app
Password: pulse1234
```

Signing up with any other well-formed name, email and password (minimum 8
characters) also works and is treated as a fresh mock account — nothing is
sent anywhere, and no data is validated against a real record. Forgot
Password always shows the same neutral confirmation, whether or not the email
is "known," which is the standard, safer behavior even for a mock.

## Not included

This is a UI/UX-focused MVP. There is no backend, no REST API, no real
authentication (see above), no payment processing, no offline sync, and no
persisted storage beyond the two auth/onboarding flags described above.
Android has not been tested; Chrome is the supported and verified target.

## Tech stack

- [Flutter](https://flutter.dev) & Dart (Material 3, custom theme)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) for state
  management
- [go_router](https://pub.dev/packages/go_router) for declarative,
  shell-based navigation, including the auth redirect guard
- [shared_preferences](https://pub.dev/packages/shared_preferences) for the
  two persisted flags (onboarding seen, mock session)
- `flutter_test` for unit and widget tests

No charting or networking packages are used — the chart is hand-built and the
data layer is local by design.

## Architecture

```
Flutter UI  (screens + the Pulse component library)
     │  ref.watch
     ▼
Riverpod providers  (per-feature state: selection, filters, period, auth)
     │
     ▼
Analytics layer  (ActivityAnalytics — pure functions, no Flutter import)
     │
     ▼
Mock data layer  (MockDataset for transactions/cards/balances;
                  MockAuthRepository for login/sign-up/reset)
     │
     ▼
Local persistence  (AppPreferences — onboarding flag + mock session only)
```

Every screen reads through a repository interface (`HomeRepository`,
`CardsRepository`, `TransactionsRepository`, `AuthRepository`), so the mock
implementations are a swappable seam rather than something baked into the UI —
a REST-backed implementation is a binding change, not a rewrite.

```
lib/
  main.dart, app.dart       entry point (awaits SharedPreferences once),
                             MaterialApp.router + theme wiring
  core/
    theme/                  design tokens: colors, type scale, spacing,
                             radii, shadows, the signature notched card shape
    routing/                GoRouter config, the auth redirect guard, and the
                             shared app shell
    persistence/            AppPreferences — the app's entire local storage
    clock.dart               the app's single "now" — overridable in tests
  shared/
    data/                   MockDataset — the one source of sample data
    models/                 domain models (transactions, cards, etc.)
    widgets/                the Pulse component library
  features/
    auth/                   splash, onboarding, login, sign-up, forgot
                             password, and the auth controller/state
    home/ cards/ transactions/ activity/
                             one folder per screen, each with its own
                             data/ (repositories, providers) and widgets/
```

## Navigation & route protection

```
Splash → Onboarding (first run only) → Login ⇄ Sign Up
                                          │
                                          ▼
                                        Home ⇄ Cards ⇄ Transactions ⇄ Activity
                                          │
                                          ▼
                                       Log Out (from the avatar on Home)
                                          │
                                          ▼
                                        Login
```

Home, Cards, Transactions, Activity and transaction details are all protected
routes: visiting one while unauthenticated redirects to Login (or Onboarding,
for a first-time visitor); visiting Login, Sign Up or Onboarding while already
authenticated redirects to Home. This is enforced centrally in GoRouter's
`redirect`, not by scattered `isLoggedIn` checks in individual screens.

## Testing

**166 tests, all passing** — unit tests for the analytics, model, and
validation logic; widget tests covering every screen (including the full
splash → onboarding → login/sign-up → home → logout flow) and its layout at
five viewport widths (320, 360, 390, 412, and a desktop width) with zero
overflow; and route-guard tests confirming protected routes actually redirect.

```sh
flutter analyze   # no issues
flutter test      # 166 passed
```

## Screenshots

Not yet included. To capture your own:

```sh
flutter run -d chrome --web-browser-flag="--window-size=412,915"
```

then screenshot the auth flow and each tab (Home, Cards, Transactions,
Activity) and drop the images under a `screenshots/` folder, linked here.

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

On first launch you'll see onboarding; skip it or step through, then log in
with the demo account above (or sign up with anything else).
