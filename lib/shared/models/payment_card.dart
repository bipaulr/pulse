import 'package:flutter/foundation.dart';

import 'pulse_transaction.dart' show kDefaultCurrencySymbol;

/// The face a card is issued in.
///
/// A product attribute rather than a UI decision — the user picks this when
/// they order the card — so it belongs on the model.
enum PaymentCardStyle { lime, ink, citron }

/// A payment card belonging to the user.
///
/// Only the last four digits are ever modelled — the full PAN is never held
/// by the client, which is both the correct thing to do and what a real
/// issuer API would return. The PIN likewise is not stored here; it is
/// fetched on demand through the repository.
@immutable
class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.holderName,
    required this.last4,
    required this.expiry,
    required this.availableBalance,
    this.productName = 'Virtual Debit',
    this.network = 'Pulse Network',
    this.style = PaymentCardStyle.lime,
    this.currencySymbol = kDefaultCurrencySymbol,
  });

  final String id;
  final String holderName;

  /// The only digits the client ever sees.
  final String last4;

  /// `MM/YY`.
  final String expiry;

  final double availableBalance;

  /// Card type as shown on the face, e.g. "Virtual Debit".
  final String productName;

  /// Fictional scheme name — Pulse issues on its own rails.
  final String network;

  final PaymentCardStyle style;

  final String currencySymbol;

  /// Display form: three masked groups plus the real last four.
  String get maskedNumber => '••••  ••••  ••••  $last4';

  /// Used to overlay the signed-in user's name onto mock cards — the card
  /// itself (number, balance, network, ...) stays untouched; only the printed
  /// holder name follows whoever is actually logged in.
  PaymentCard copyWith({String? holderName}) => PaymentCard(
    id: id,
    holderName: holderName ?? this.holderName,
    last4: last4,
    expiry: expiry,
    availableBalance: availableBalance,
    productName: productName,
    network: network,
    style: style,
    currencySymbol: currencySymbol,
  );

  /// How this card names itself inside a transaction record.
  String get paymentMethodLabel => 'Pulse $productName •••• $last4';

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] as String,
      holderName: json['holderName'] as String,
      last4: json['last4'] as String,
      expiry: json['expiry'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
      productName: json['productName'] as String? ?? 'Virtual Debit',
      network: json['network'] as String? ?? 'Pulse Network',
      style: PaymentCardStyle.values.byName(json['style'] as String? ?? 'lime'),
      currencySymbol:
          json['currencySymbol'] as String? ?? kDefaultCurrencySymbol,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PaymentCard && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
