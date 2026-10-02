import 'package:flutter/material.dart';

enum CardBrand {
  visa,
  mastercard,
  rupay,
  amex;

  String get displayName {
    switch (this) {
      case CardBrand.visa:
        return 'VISA';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.rupay:
        return 'RuPay';
      case CardBrand.amex:
        return 'American Express';
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case CardBrand.visa:
        return const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardBrand.mastercard:
        return const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardBrand.rupay:
        return const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CardBrand.amex:
        return const LinearGradient(
          colors: [Color(0xFF78350F), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData get icon => Icons.credit_card_rounded;
}

class PaymentCard {
  final String id;
  final String cardHolder;
  final String cardNumberLast4;
  final CardBrand brand;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.cardHolder,
    required this.cardNumberLast4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  String get formattedExpiry => '$expiryMonth/$expiryYear';
  String get maskedNumber => '•••• •••• •••• $cardNumberLast4';

  PaymentCard copyWith({
    String? id,
    String? cardHolder,
    String? cardNumberLast4,
    CardBrand? brand,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      cardHolder: cardHolder ?? this.cardHolder,
      cardNumberLast4: cardNumberLast4 ?? this.cardNumberLast4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static List<PaymentCard> dummyCards() {
    return const [
      PaymentCard(
        id: 'card_1',
        cardHolder: 'DEMO SHOPPER',
        cardNumberLast4: '4242',
        brand: CardBrand.visa,
        expiryMonth: '12',
        expiryYear: '28',
        isDefault: true,
      ),
      PaymentCard(
        id: 'card_2',
        cardHolder: 'DEMO SHOPPER',
        cardNumberLast4: '8819',
        brand: CardBrand.mastercard,
        expiryMonth: '09',
        expiryYear: '27',
        isDefault: false,
      ),
      PaymentCard(
        id: 'card_3',
        cardHolder: 'DEMO SHOPPER',
        cardNumberLast4: '1092',
        brand: CardBrand.rupay,
        expiryMonth: '04',
        expiryYear: '29',
        isDefault: false,
      ),
    ];
  }
}

class UpiPayment {
  final String id;
  final String upiId;
  final String providerName;
  final bool isDefault;

  const UpiPayment({
    required this.id,
    required this.upiId,
    required this.providerName,
    this.isDefault = false,
  });

  UpiPayment copyWith({
    String? id,
    String? upiId,
    String? providerName,
    bool? isDefault,
  }) {
    return UpiPayment(
      id: id ?? this.id,
      upiId: upiId ?? this.upiId,
      providerName: providerName ?? this.providerName,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static List<UpiPayment> dummyUpi() {
    return const [
      UpiPayment(
        id: 'upi_1',
        upiId: 'kanha@okaxis',
        providerName: 'Google Pay',
        isDefault: true,
      ),
      UpiPayment(
        id: 'upi_2',
        upiId: 'shopper@ybl',
        providerName: 'PhonePe',
        isDefault: false,
      ),
      UpiPayment(
        id: 'upi_3',
        upiId: 'demoshopper@paytm',
        providerName: 'Paytm UPI',
        isDefault: false,
      ),
    ];
  }
}
