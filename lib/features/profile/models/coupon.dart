class Coupon {
  final String code;
  final String title;
  final String description;
  final int discountPercent;
  final double minOrderAmount;
  final double maxDiscountAmount;
  final String validUntil;
  final List<String> terms;
  final bool isApplied;

  const Coupon({
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.minOrderAmount = 0.0,
    this.maxDiscountAmount = 5000.0,
    required this.validUntil,
    this.terms = const [],
    this.isApplied = false,
  });

  Coupon copyWith({
    String? code,
    String? title,
    String? description,
    int? discountPercent,
    double? minOrderAmount,
    double? maxDiscountAmount,
    String? validUntil,
    List<String>? terms,
    bool? isApplied,
  }) {
    return Coupon(
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      validUntil: validUntil ?? this.validUntil,
      terms: terms ?? this.terms,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  static List<Coupon> dummyCoupons() {
    return const [
      Coupon(
        code: 'TECH40',
        title: 'Tech Fest Exclusive 40% OFF',
        description:
            'Get massive 40% instant discount across all audio, wearables, and electronics gadgets.',
        discountPercent: 40,
        minOrderAmount: 2999.0,
        maxDiscountAmount: 4000.0,
        validUntil: 'Nov 30, 2026',
        terms: [
          'Applicable only on Electronics category items',
          'Maximum discount capped at ₹4,000',
          'Cannot be clubbed with other promotional bank codes',
        ],
      ),
      Coupon(
        code: 'STYLE20',
        title: 'Spring Fashion 20% OFF',
        description:
            'Save 20% flat on all apparel, footwear, hoodies, and luxury accessories.',
        discountPercent: 20,
        minOrderAmount: 1499.0,
        maxDiscountAmount: 2000.0,
        validUntil: 'Dec 15, 2026',
        terms: [
          'Valid on Fashion, Footwear and Accessories collections',
          'Applicable on cart total of ₹1,499 and above',
        ],
      ),
      Coupon(
        code: 'FREESHIP',
        title: 'Free Express Doorstep Delivery',
        description:
            'Zero shipping charges on any cart value with priority dispatch.',
        discountPercent: 100,
        minOrderAmount: 499.0,
        maxDiscountAmount: 150.0,
        validUntil: 'Dec 31, 2026',
        terms: [
          'Valid across all pincodes in India',
          'Eligible for standard and express delivery options',
        ],
      ),
      Coupon(
        code: 'VIPGOLD50',
        title: 'VIP Gold Member Perk 50% OFF',
        description:
            'Special half-price anniversary coupon exclusive for VIP Gold tier shoppers.',
        discountPercent: 50,
        minOrderAmount: 4999.0,
        maxDiscountAmount: 5000.0,
        validUntil: 'Jan 31, 2027',
        terms: [
          'Requires active VIP Gold membership status',
          'One-time redemption per customer account',
        ],
      ),
    ];
  }
}
