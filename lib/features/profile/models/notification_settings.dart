class NotificationSettings {
  final bool orderUpdates;
  final bool deliveryAlerts;
  final bool promotionalOffers;
  final bool priceDropAlerts;
  final bool exclusiveDeals;
  final bool newsletter;
  final bool smsUpdates;
  final bool whatsappAlerts;

  const NotificationSettings({
    this.orderUpdates = true,
    this.deliveryAlerts = true,
    this.promotionalOffers = true,
    this.priceDropAlerts = true,
    this.exclusiveDeals = true,
    this.newsletter = false,
    this.smsUpdates = true,
    this.whatsappAlerts = true,
  });

  NotificationSettings copyWith({
    bool? orderUpdates,
    bool? deliveryAlerts,
    bool? promotionalOffers,
    bool? priceDropAlerts,
    bool? exclusiveDeals,
    bool? newsletter,
    bool? smsUpdates,
    bool? whatsappAlerts,
  }) {
    return NotificationSettings(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      deliveryAlerts: deliveryAlerts ?? this.deliveryAlerts,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      priceDropAlerts: priceDropAlerts ?? this.priceDropAlerts,
      exclusiveDeals: exclusiveDeals ?? this.exclusiveDeals,
      newsletter: newsletter ?? this.newsletter,
      smsUpdates: smsUpdates ?? this.smsUpdates,
      whatsappAlerts: whatsappAlerts ?? this.whatsappAlerts,
    );
  }

  Map<String, dynamic> toJson() => {
    'orderUpdates': orderUpdates,
    'deliveryAlerts': deliveryAlerts,
    'promotionalOffers': promotionalOffers,
    'priceDropAlerts': priceDropAlerts,
    'exclusiveDeals': exclusiveDeals,
    'newsletter': newsletter,
    'smsUpdates': smsUpdates,
    'whatsappAlerts': whatsappAlerts,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        orderUpdates: json['orderUpdates'] as bool? ?? true,
        deliveryAlerts: json['deliveryAlerts'] as bool? ?? true,
        promotionalOffers: json['promotionalOffers'] as bool? ?? true,
        priceDropAlerts: json['priceDropAlerts'] as bool? ?? true,
        exclusiveDeals: json['exclusiveDeals'] as bool? ?? true,
        newsletter: json['newsletter'] as bool? ?? false,
        smsUpdates: json['smsUpdates'] as bool? ?? true,
        whatsappAlerts: json['whatsappAlerts'] as bool? ?? true,
      );
}
