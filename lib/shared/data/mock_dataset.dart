import '../models/models.dart';

/// The single source of sample data for the pre-backend phases.
///
/// Home, Cards and Transactions all read from here so they can never disagree
/// about the same record. Timestamps are relative to [now], which tests pin.
class MockDataset {
  MockDataset({DateTime? now}) : now = now ?? DateTime.now();

  final DateTime now;

  late final DateTime _today = DateTime(now.year, now.month, now.day);

  DateTime _at(int daysAgo, int hour, int minute) =>
      _today.subtract(Duration(days: daysAgo)).add(
        Duration(hours: hour, minutes: minute),
      );

  static const primaryCardId = 'card_lime';
  static const platinumCardId = 'card_ink';
  static const savingsCardId = 'card_citron';

  static const user = UserProfile(firstName: 'Aarav', lastName: 'Sharma');

  static const balance = BalanceSummary(total: 42850, changePercent: 12.4);

  static const cards = <PaymentCard>[
    PaymentCard(
      id: primaryCardId,
      holderName: 'Aarav Sharma',
      last4: '4921',
      expiry: '02/28',
      availableBalance: 42850,
      productName: 'Virtual Debit',
      style: PaymentCardStyle.lime,
    ),
    PaymentCard(
      id: platinumCardId,
      holderName: 'Aarav Sharma',
      last4: '7734',
      expiry: '11/27',
      availableBalance: 128400,
      productName: 'Platinum Credit',
      style: PaymentCardStyle.ink,
    ),
    PaymentCard(
      id: savingsCardId,
      holderName: 'Aarav Sharma',
      last4: '3056',
      expiry: '07/29',
      availableBalance: 15230,
      productName: 'Savings Debit',
      style: PaymentCardStyle.citron,
    ),
  ];

  static PaymentCard cardById(String id) =>
      cards.firstWhere((card) => card.id == id, orElse: () => cards.first);

  /// Newest first — the order every feed in the app expects.
  late final List<PulseTransaction> transactions = [
    _txn('txn_01', 'Swiggy', TransactionCategory.food, -420, _at(0, 13, 12),
        description: 'Lunch order · 2 items'),
    _txn('txn_02', 'Amazon', TransactionCategory.shopping, -1299, _at(0, 10, 5),
        description: 'Order #402-8871934'),
    _txn('txn_03', 'Uber', TransactionCategory.transport, -280, _at(1, 18, 40),
        description: 'Trip to Indiranagar'),
    _txn('txn_04', 'Netflix', TransactionCategory.entertainment, -649,
        _at(2, 21, 5),
        description: 'Premium plan · monthly'),
    _txn('txn_05', 'Salary', TransactionCategory.income, 45000, _at(4, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_06', 'Blinkit', TransactionCategory.food, -845, _at(5, 19, 20),
        description: 'Groceries · 11 items'),
    _txn('txn_07', 'Starbucks', TransactionCategory.food, -390, _at(5, 11, 15),
        card: platinumCardId),
    _txn('txn_08', 'Electricity Bill', TransactionCategory.bills, -2150,
        _at(5, 8, 30),
        description: 'BESCOM · August'),
    _txn('txn_09', 'Zara', TransactionCategory.shopping, -3499, _at(6, 16, 20),
        card: platinumCardId),
    _txn('txn_10', 'Metro Card', TransactionCategory.transport, -200,
        _at(6, 8, 10)),
    _txn('txn_11', 'Rent Transfer', TransactionCategory.transfer, -18000,
        _at(7, 10, 0),
        description: 'To Meera Nair'),
    _txn('txn_12', 'BookMyShow', TransactionCategory.entertainment, -900,
        _at(7, 19, 30),
        description: '2 tickets'),
    _txn('txn_13', 'Spotify', TransactionCategory.entertainment, -199,
        _at(8, 12, 0),
        status: TransactionStatus.pending),
    _txn('txn_14', 'Big Bazaar', TransactionCategory.shopping, -2340,
        _at(8, 17, 45),
        card: savingsCardId),
    _txn('txn_15', 'Ola', TransactionCategory.transport, -310, _at(9, 7, 55)),
    _txn('txn_16', 'Freelance Payout', TransactionCategory.income, 12500,
        _at(9, 14, 20),
        card: savingsCardId, description: 'Design retainer'),
    _txn('txn_17', 'Internet Bill', TransactionCategory.bills, -1099,
        _at(10, 11, 0),
        description: 'ACT Fibernet · August'),
    _txn('txn_18', "Domino's", TransactionCategory.food, -560, _at(10, 20, 15),
        status: TransactionStatus.failed),
    _txn('txn_19', 'Croma', TransactionCategory.shopping, -8990, _at(12, 15, 0),
        card: platinumCardId, description: 'Headphones'),
  ];

  /// What Home shows under "Recent Activity".
  List<PulseTransaction> get recentTransactions =>
      transactions.take(5).toList(growable: false);

  List<PulseTransaction> transactionsForCard(String cardId) => transactions
      .where((txn) => txn.cardId == cardId)
      .toList(growable: false);

  PulseTransaction _txn(
    String id,
    String merchant,
    TransactionCategory category,
    double amount,
    DateTime occurredAt, {
    String card = primaryCardId,
    String? description,
    TransactionStatus status = TransactionStatus.completed,
  }) {
    return PulseTransaction(
      id: id,
      merchant: merchant,
      category: category,
      amount: amount,
      occurredAt: occurredAt,
      cardId: card,
      paymentMethod: cardById(card).paymentMethodLabel,
      description: description,
      status: status,
    );
  }
}
