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

    // Older history, so the Activity charts have several months to plot.
    // Offsets are in days rather than calendar months, which keeps this list
    // strictly newest-first whatever today's date happens to be.
    _txn('txn_20', 'Salary', TransactionCategory.income, 45000, _at(34, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_21', 'Apollo Pharmacy', TransactionCategory.health, -1240,
        _at(21, 11, 30)),
    _txn('txn_22', 'IndiGo', TransactionCategory.travel, -7480, _at(23, 8, 45),
        card: platinumCardId, description: 'BLR to GOI'),
    _txn('txn_23', 'Swiggy Instamart', TransactionCategory.food, -1130,
        _at(25, 18, 10)),
    _txn('txn_24', 'Index Fund SIP', TransactionCategory.investments, -10000,
        _at(27, 10, 0), description: 'Monthly SIP'),
    _txn('txn_25', 'Electricity Bill', TransactionCategory.bills, -1980,
        _at(29, 8, 30)),
    _txn('txn_26', 'Decathlon', TransactionCategory.shopping, -4260,
        _at(31, 16, 0), card: savingsCardId),

    _txn('txn_27', 'Salary', TransactionCategory.income, 45000, _at(64, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_28', 'Index Fund SIP', TransactionCategory.investments, -10000,
        _at(57, 10, 0), description: 'Monthly SIP'),
    _txn('txn_29', 'Cult Fit', TransactionCategory.health, -2400, _at(48, 7, 20),
        description: 'Quarterly membership'),
    _txn('txn_30', 'Third Wave Coffee', TransactionCategory.food, -680,
        _at(52, 17, 40), card: platinumCardId),
    _txn('txn_31', 'Rent Transfer', TransactionCategory.transfer, -18000,
        _at(38, 10, 0), description: 'To Meera Nair'),
    _txn('txn_32', 'PVR Cinemas', TransactionCategory.entertainment, -1450,
        _at(44, 20, 15)),
    _txn('txn_33', 'Rapido', TransactionCategory.transport, -190,
        _at(60, 9, 5)),

    _txn('txn_34', 'Salary', TransactionCategory.income, 43500, _at(94, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_35', 'Index Fund SIP', TransactionCategory.investments, -10000,
        _at(87, 10, 0), description: 'Monthly SIP'),
    _txn('txn_36', 'Goibibo', TransactionCategory.travel, -12900,
        _at(78, 14, 25), card: platinumCardId, description: 'Hotel · 3 nights'),
    _txn('txn_37', 'Rent Transfer', TransactionCategory.transfer, -18000,
        _at(68, 10, 0), description: 'To Meera Nair'),
    _txn('txn_38', 'Nykaa', TransactionCategory.shopping, -2870, _at(72, 15, 50),
        card: savingsCardId),
    _txn('txn_39', 'Gas Bill', TransactionCategory.bills, -890, _at(83, 8, 15)),
    _txn('txn_40', 'Bonus', TransactionCategory.income, 22000, _at(90, 12, 0),
        description: 'Half-yearly bonus'),

    _txn('txn_41', 'Salary', TransactionCategory.income, 43500, _at(124, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_42', 'Index Fund SIP', TransactionCategory.investments, -8000,
        _at(117, 10, 0), description: 'Monthly SIP'),
    _txn('txn_43', 'Rent Transfer', TransactionCategory.transfer, -17500,
        _at(98, 10, 0), description: 'To Meera Nair'),
    _txn('txn_44', 'Practo', TransactionCategory.health, -1600, _at(105, 13, 0),
        description: 'Consultation'),
    _txn('txn_45', 'Uber Eats', TransactionCategory.food, -740,
        _at(112, 19, 45)),
    _txn('txn_46', 'Water Bill', TransactionCategory.bills, -430,
        _at(120, 8, 40)),

    _txn('txn_47', 'Salary', TransactionCategory.income, 43500, _at(154, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_48', 'Index Fund SIP', TransactionCategory.investments, -8000,
        _at(147, 10, 0), description: 'Monthly SIP'),
    _txn('txn_49', 'Rent Transfer', TransactionCategory.transfer, -17500,
        _at(128, 10, 0), description: 'To Meera Nair'),
    _txn('txn_50', 'MakeMyTrip', TransactionCategory.travel, -5320,
        _at(136, 11, 10), card: platinumCardId),
    _txn('txn_51', 'Lifestyle', TransactionCategory.shopping, -3180,
        _at(142, 17, 0), card: savingsCardId),
    _txn('txn_52', 'Namma Metro', TransactionCategory.transport, -260,
        _at(150, 8, 25)),

    _txn('txn_53', 'Salary', TransactionCategory.income, 41000, _at(184, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_54', 'Index Fund SIP', TransactionCategory.investments, -8000,
        _at(177, 10, 0), description: 'Monthly SIP'),
    _txn('txn_55', 'Rent Transfer', TransactionCategory.transfer, -17500,
        _at(158, 10, 0), description: 'To Meera Nair'),
    _txn('txn_56', 'Barbeque Nation', TransactionCategory.food, -2260,
        _at(166, 20, 30), card: platinumCardId),
    _txn('txn_57', 'Broadband Bill', TransactionCategory.bills, -1099,
        _at(172, 11, 0)),
    _txn('txn_58', 'Sony LIV', TransactionCategory.entertainment, -299,
        _at(180, 21, 40)),

    _txn('txn_59', 'Salary', TransactionCategory.income, 41000, _at(214, 9, 0),
        description: 'Monthly payroll credit'),
    _txn('txn_60', 'Rent Transfer', TransactionCategory.transfer, -17500,
        _at(188, 10, 0), description: 'To Meera Nair'),
    _txn('txn_61', 'Reliance Digital', TransactionCategory.shopping, -6450,
        _at(196, 16, 30), card: platinumCardId),
    _txn('txn_62', 'Blue Dart', TransactionCategory.transport, -350,
        _at(204, 12, 15)),
    _txn('txn_63', 'Health Insurance', TransactionCategory.health, -4800,
        _at(210, 9, 30), description: 'Annual premium'),
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
