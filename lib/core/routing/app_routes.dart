/// Every route path in Pulse, in one place.
///
/// Kept as plain constants — the app is small enough that code generation
/// would cost more than it saves.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const cards = '/cards';
  static const transactions = '/transactions';
  static const activity = '/activity';

  /// Path segment of the transaction details route, relative to
  /// [transactions].
  static const transactionDetailsSegment = ':id';

  static String transactionDetails(String id) => '$transactions/$id';

  /// The four tabs behind the bottom navigation — the routes that require an
  /// authenticated session.
  static const protected = {home, cards, transactions, activity};

  static const initial = splash;
}
