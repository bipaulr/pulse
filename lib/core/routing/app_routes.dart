/// Every route path in Pulse, in one place.
///
/// Kept as plain constants — the app is small enough that code generation
/// would cost more than it saves.
abstract final class AppRoutes {
  static const home = '/home';
  static const cards = '/cards';
  static const transactions = '/transactions';
  static const activity = '/activity';

  /// Path segment of the transaction details route, relative to
  /// [transactions].
  static const transactionDetailsSegment = ':id';

  static String transactionDetails(String id) => '$transactions/$id';

  static const initial = home;
}
