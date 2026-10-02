class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String membershipTier;
  final String memberSince;
  final String gender;
  final String dateOfBirth;
  final int points;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.membershipTier = 'VIP Gold Member',
    this.memberSince = 'October 2023',
    this.gender = 'Not specified',
    this.dateOfBirth = '15 Aug 1996',
    this.points = 1250,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? membershipTier,
    String? memberSince,
    String? gender,
    String? dateOfBirth,
    int? points,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      membershipTier: membershipTier ?? this.membershipTier,
      memberSince: memberSince ?? this.memberSince,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      points: points ?? this.points,
    );
  }

  factory UserProfile.defaultDemo() {
    return const UserProfile(
      id: 'usr_demo_001',
      name: 'Demo Shopper',
      email: 'demo@shopsphere.com',
      phone: '+91 98765 43210',
      avatarUrl: null,
      membershipTier: 'VIP Gold Member',
      memberSince: 'October 2023',
      gender: 'Male',
      dateOfBirth: '15 Aug 1996',
      points: 1250,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'membershipTier': membershipTier,
    'memberSince': memberSince,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'points': points,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'usr_demo_001',
      name: json['name'] as String? ?? 'Demo Shopper',
      email: json['email'] as String? ?? 'demo@shopsphere.com',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      avatarUrl: json['avatarUrl'] as String?,
      membershipTier: json['membershipTier'] as String? ?? 'VIP Gold Member',
      memberSince: json['memberSince'] as String? ?? 'October 2023',
      gender: json['gender'] as String? ?? 'Not specified',
      dateOfBirth: json['dateOfBirth'] as String? ?? '15 Aug 1996',
      points: (json['points'] as num?)?.toInt() ?? 1250,
    );
  }
}
