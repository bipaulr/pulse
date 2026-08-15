# Pulse

Pulse is a premium personal-finance app built in Flutter — a mobile-first
fintech experience covering onboarding, authentication, a financial
dashboard, card management, transaction tracking, and spending analytics,
all wrapped in a custom design system with a hand-built motion language.

It runs entirely on local mock data behind a real repository/state
architecture, so the UI, state management, and interaction design can be
evaluated end to end without a backend.

---

## ✨ Features

### Dashboard
- Balance summary with a trend indicator
- Animated, notched virtual-card widget
- Quick actions (Deposit, Transfer, Withdraw, More)
- Recent-activity feed with a staggered entrance

### Cards
- Swipeable card carousel with smooth, physical settling
- Per-card details (masked number, network, balance)
- Freeze / unfreeze with visual feedback
- Masked PIN reveal with an auto-hide timer
- Replace-card confirmation sheet

### Transactions
- Searchable, debounced transaction feed
- Category and income/expense filter chips
- Date-grouped list (Today / Yesterday / by date)
- Dedicated transaction details screen

### Activity & Analytics
- Total spending with period-over-period change
- Income vs. expense summary
- Custom-painted spending chart (Week / Month / Quarter / Year)
- Category breakdown
- Recent transfers

### Authentication
- Branded splash screen
- Three-page onboarding carousel (shown once)
- Login, Sign Up, and Forgot Password flows
- Logout, with centrally enforced route protection
- Mock, local-only authentication (see [Demo Account](#demo-account))

### Motion
- Custom animated bottom navigation with a lime "blob" indicator that
  travels between destinations and settles into place
- Icon-only navigation items with a subtle scale-up on selection
- Card carousel and payment-card tap feedback
- Chart entrance and selected-bar animations
- A small reusable motion system (durations + curves) applied consistently
  across chips, buttons, form validation, and loading transitions

---

## 🧠 Technical Highlights

**State management with Riverpod** — Every feature (Home, Cards,
Transactions, Activity, Auth) is backed by a repository interface and
exposed through Riverpod providers. Screens `watch` derived state; mutations
go through notifiers. This keeps UI, business logic, and data sources
cleanly separated and easy to test in isolation.

**Custom-built chart** — The spending visualization
(`PulseSpendingChart`) is not a charting library. It's built from plain
Flutter widgets plus a small `CustomPainter` for the axis gridlines, with
its own tween-based animation for bar entrance and period transitions.

**A small, reusable motion system** — Rather than ad hoc animation
durations scattered across widgets, Pulse defines a `PulseMotion` token set
(three durations, two curves) used consistently for press feedback, chip
selection, loading-state transitions, and form validation. The bottom
navigation's travelling "blob" indicator is a hand-built animation — two
independently-eased edges that stretch toward the destination and settle
back down — built entirely on Flutter's own `AnimationController` and
`Positioned` APIs, no animation package involved.

**Responsive by construction** — The layout is verified in Chrome at
320×640, 360×800, 390×844, 412×915, and a desktop width, with a maximum
content width applied on wide viewports so the UI reads as an intentional
phone-first layout rather than a stretched mobile page.

**Test coverage** — 182 automated tests (`flutter test`) covering the
design-system components, screen behavior, analytics calculations,
authentication and route-guard logic, and personalization, alongside a
clean `flutter analyze`.

---

## 🏗️ Architecture

```
Flutter UI  (screens + the Pulse component library)
     │  ref.watch
     ▼
Riverpod providers  (per-feature state: selection, filters, period, auth)
     │
     ▼
Analytics layer  (pure functions, no Flutter dependency)
     │
     ▼
Repositories  (HomeRepository, CardsRepository, TransactionsRepository,
               AuthRepository — interfaces, backed by mock implementations)
     │
     ▼
Mock / local data  (a shared in-memory dataset + two persisted flags
                     via shared_preferences: onboarding seen, mock session)
```

Every repository is an interface with a mock implementation behind it, so
swapping in a REST-backed implementation later is a binding change, not a
rewrite — none of the UI or state layer depends on the data being local.

```
lib/
  main.dart, app.dart     Entry point, MaterialApp.router + theme wiring
  core/
    theme/                Design tokens — colors, type scale, spacing,
                           radii, shadows, motion durations/curves
    routing/               GoRouter config, the auth redirect guard,
                           the shared app shell + bottom navigation
    persistence/            The app's entire local storage surface
  shared/
    data/                  The shared mock dataset
    models/                 Domain models (transactions, cards, users, ...)
    widgets/                The Pulse component library (PulseCard,
                             PulseButton, PulseChip, PulseTextField, ...)
  features/
    auth/                  Splash, onboarding, login, sign-up, forgot
                            password, auth state
    home/  cards/  transactions/  activity/
                            One folder per screen, each with its own
                            data/ (repository + providers) and widgets/
```

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) & Dart |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Navigation | [go_router](https://pub.dev/packages/go_router) (declarative, shell-based, with a redirect-based auth guard) |
| Local persistence | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Data visualization | Hand-built with `CustomPainter` — no charting package |
| Testing | `flutter_test` (unit + widget tests) |

No backend, database, or networking package is used — Pulse is intentionally
a local, UI/UX-focused build.

---

## 📸 Screenshots

Screenshots aren't included in this repository yet. To generate your own:

```sh
flutter run -d chrome --web-browser-flag="--window-size=412,915"
```

then capture the onboarding flow and each of the four tabs (Home, Cards,
Transactions, Activity).

---

## 🔑 Demo Account

Authentication is **mock and local-only** — included for demonstration
purposes. There is no backend, and no credentials are transmitted or
verified against a real service.

```text
Email:    demo@pulse.app
Password: pulse1234
```

Signing up with any other name, a valid-looking email, and an 8+ character
password also works and is treated as a fresh mock session — nothing is
sent anywhere.

---

## 🚀 Running Locally

Chrome is the current, verified runtime target for this project.

```sh
git clone https://github.com/bipaulr/pulse.git
cd pulse
flutter pub get
flutter run -d chrome
```

On first launch you'll see onboarding — skip it or step through, then sign
in with the demo account above (or sign up with anything else).

---

## ✅ Testing

```sh
flutter analyze   # no issues
flutter test      # 182 passed
```

The app has been manually verified in Chrome at the following viewport
widths, with no layout overflow:

- 320 × 640
- 360 × 800
- 390 × 844
- 412 × 915
- Desktop width

---

## 📦 Project Scope

Pulse is an MVP focused on interface, interaction, and state-management
design. The current version intentionally uses:

- Mock, local-only authentication (no real account system)
- Mock financial data (balances, cards, transactions)
- Local persistence limited to two flags (onboarding seen, mock session)
- No production backend or REST API
- No real payment processing

These are deliberate boundaries for this stage of the project, not gaps —
the architecture (repository interfaces behind every feature) is already
shaped for a backend to be introduced without restructuring the UI.

---

## 🎨 Design Philosophy

Pulse is built around a minimal, high-contrast fintech aesthetic — an
off-white canvas, near-black typography, and an electric lime accent used
deliberately rather than everywhere. Financial figures get the strongest
typographic weight on any given screen, corners are generously rounded, and
motion is restrained and consistent: small, purposeful transitions rather
than decoration for its own sake.
