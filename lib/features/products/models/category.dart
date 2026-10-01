import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String iconKey;

  const Category({
    required this.id,
    required this.name,
    this.iconKey = 'grid_view_rounded',
  });

  IconData get iconData => switch (iconKey) {
    'devices_rounded' => Icons.devices_rounded,
    'checkroom_rounded' => Icons.checkroom_rounded,
    'roller_skating_rounded' ||
    'directions_run_rounded' => Icons.directions_run_rounded,
    'watch_rounded' => Icons.watch_rounded,
    'local_cafe_rounded' => Icons.local_cafe_rounded,
    _ => Icons.grid_view_rounded,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey:
          json['icon'] as String? ??
          json['iconKey'] as String? ??
          'grid_view_rounded',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': iconKey};
  }

  Category copyWith({String? id, String? name, String? iconKey}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          iconKey == other.iconKey;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ iconKey.hashCode;

  static const all = Category(
    id: 'all',
    name: 'All Products',
    iconKey: 'grid_view_rounded',
  );

  static const List<Category> standardCategories = [
    Category(id: 'all', name: 'All', iconKey: 'grid_view_rounded'),
    Category(
      id: 'electronics',
      name: 'Electronics',
      iconKey: 'devices_rounded',
    ),
    Category(id: 'fashion', name: 'Fashion', iconKey: 'checkroom_rounded'),
    Category(
      id: 'footwear',
      name: 'Footwear',
      iconKey: 'roller_skating_rounded',
    ),
    Category(id: 'accessories', name: 'Accessories', iconKey: 'watch_rounded'),
    Category(id: 'lifestyle', name: 'Lifestyle', iconKey: 'local_cafe_rounded'),
  ];
}
