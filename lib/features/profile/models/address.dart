import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';

enum AddressType {
  home,
  work,
  other;

  String get displayName {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case AddressType.home:
        return Icons.home_rounded;
      case AddressType.work:
        return Icons.business_rounded;
      case AddressType.other:
        return Icons.location_on_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AddressType.home:
        return AppColors.primary;
      case AddressType.work:
        return AppColors.accent;
      case AddressType.other:
        return AppColors.secondary;
    }
  }
}

class Address {
  final String id;
  final String fullName;
  final String phone;
  final String streetAddress;
  final String apartment;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final AddressType type;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.streetAddress,
    this.apartment = '',
    this.landmark = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.type = AddressType.home,
    this.isDefault = false,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  String get coordinatesDisplay => hasCoordinates
      ? '${latitude!.toStringAsFixed(4)}° N, ${longitude!.toStringAsFixed(4)}° E'
      : '';

  String get fullFormatted {
    final apt = apartment.isNotEmpty ? '$apartment, ' : '';
    final lmark = landmark.isNotEmpty ? ' (Near $landmark)' : '';
    return '$apt$streetAddress$lmark, $city, $state - $pincode';
  }

  Address copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? streetAddress,
    String? apartment,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    AddressType? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'streetAddress': streetAddress,
    'apartment': apartment,
    'landmark': landmark,
    'city': city,
    'state': state,
    'pincode': pincode,
    'type': type.name,
    'isDefault': isDefault,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    phone: json['phone'] as String,
    streetAddress: json['streetAddress'] as String,
    apartment: json['apartment'] as String? ?? '',
    landmark: json['landmark'] as String? ?? '',
    city: json['city'] as String,
    state: json['state'] as String,
    pincode: json['pincode'] as String,
    type: AddressType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => AddressType.home,
    ),
    isDefault: json['isDefault'] as bool? ?? false,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    locationName: json['locationName'] as String?,
  );

  static List<Address> dummyAddresses() {
    return const [
      Address(
        id: 'addr_1',
        fullName: 'Demo Shopper',
        phone: '+91 98765 43210',
        apartment: 'Flat 402, Signature Towers',
        streetAddress: 'Indiranagar 100ft Road',
        landmark: 'Near Indiranagar Metro Station',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560038',
        type: AddressType.home,
        isDefault: true,
        latitude: 12.9784,
        longitude: 77.6408,
        locationName: 'Indiranagar, Bengaluru',
      ),
      Address(
        id: 'addr_2',
        fullName: 'Demo Shopper',
        phone: '+91 98765 43210',
        apartment: 'Office 5B, Tech Vista Park',
        streetAddress: 'Whitefield Main Road',
        landmark: 'Behind Inorbit Mall',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560066',
        type: AddressType.work,
        isDefault: false,
        latitude: 12.9698,
        longitude: 77.7499,
        locationName: 'Whitefield, Bengaluru',
      ),
    ];
  }
}
