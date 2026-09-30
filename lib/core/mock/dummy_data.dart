import 'dart:convert';
import 'package:shopsphere/features/products/models/category.dart';
import 'package:shopsphere/features/products/models/product.dart';

/// Class containing dummy datasets for development, testing, and UI preview.
abstract final class DummyData {
  /// Realistic dummy product catalog with diverse categories and high-res images in Indian Rupees (INR).
  static final List<Product> products = [
    const Product(
      id: '1',
      title: 'Sony WH-1000XM5 Noise Cancelling Headphones',
      description:
          'Industry-leading wireless noise-canceling headphones with 2 processors, 8 microphones, and up to 30 hours of battery life with ultra-fast charging.',
      price: 29999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
      category: 'electronics',
    ),
    const Product(
      id: '2',
      title: 'Minimalist Chrono Smartwatch',
      description:
          'Sleek aerospace-grade aluminum casing with always-on AMOLED display, comprehensive heart rate & SpO2 tracking, and 7-day battery endurance.',
      price: 4999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80',
      category: 'accessories',
    ),
    const Product(
      id: '3',
      title: 'Nike Air Max Performance Runners',
      description:
          'Engineered mesh upper with responsive Air cushioning for maximum comfort, stability, and high performance on track and asphalt.',
      price: 7999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
      category: 'footwear',
    ),
    const Product(
      id: '4',
      title: 'Handcrafted Vintage Leather Backpack',
      description:
          'Premium full-grain leather backpack featuring a padded 15-inch laptop compartment, water-resistant interior lining, and antiqued brass hardware.',
      price: 3499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&q=80',
      category: 'fashion',
    ),
    const Product(
      id: '5',
      title: 'Keychron K2 Wireless Mechanical Keyboard',
      description:
          'Compact 75% layout mechanical keyboard with hot-swappable Gateron switches, RGB backlighting, and cross-platform Bluetooth & USB-C connectivity.',
      price: 6499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800&q=80',
      category: 'electronics',
    ),
    const Product(
      id: '6',
      title: 'Heavyweight Organic Cotton Hoodie',
      description:
          'Ultra-soft 450 GSM French Terry cotton hoodie with tailored drop shoulders, double-layered hood, and durable ribbed cuffs.',
      price: 2499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&q=80',
      category: 'fashion',
    ),
    const Product(
      id: '7',
      title: 'Polarized Aviator Sunglasses',
      description:
          'Classic lightweight titanium aviators with UV400 anti-reflective polarized lenses and comfortable silicone nose pads.',
      price: 1999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800&q=80',
      category: 'accessories',
    ),
    const Product(
      id: '8',
      title: 'Vacuum Insulated Stainless Water Bottle 750ml',
      description:
          'Double-wall insulated bottle that keeps beverages cold for up to 24 hours or piping hot for 12 hours. BPA-free with leakproof flex cap.',
      price: 899.00,
      imageUrl:
          'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800&q=80',
      category: 'lifestyle',
    ),
    const Product(
      id: '9',
      title: 'Pro ANC Wireless Earbuds with Spatial Audio',
      description:
          'Crystal-clear audio with custom high-excursion drivers, active noise cancellation with transparency mode, and wireless charging case.',
      price: 4499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800&q=80',
      category: 'electronics',
    ),
    const Product(
      id: '10',
      title: 'Minimalist Architectural LED Desk Lamp',
      description:
          'Dimmable touch-sensitive aluminum task lamp with 5 color temperatures, wireless charging base, and auto-timer function.',
      price: 1799.00,
      imageUrl:
          'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da?w=800&q=80',
      category: 'lifestyle',
    ),
  ];

  /// Find product by ID from dummy catalog.
  static Product? findProductById(String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filter products by category ID ('all' returns all products).
  static List<Product> findProductsByCategory(String categoryId) {
    if (categoryId.toLowerCase() == 'all') {
      return List.unmodifiable(products);
    }
    return products
        .where((p) => p.category.toLowerCase() == categoryId.toLowerCase())
        .toList();
  }

  /// Categories for home screen filtering & discovery.
  static const List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'All', 'icon': 'grid_view_rounded'},
    {'id': 'electronics', 'name': 'Electronics', 'icon': 'devices_rounded'},
    {'id': 'fashion', 'name': 'Fashion', 'icon': 'checkroom_rounded'},
    {'id': 'footwear', 'name': 'Footwear', 'icon': 'roller_skating_rounded'},
    {'id': 'accessories', 'name': 'Accessories', 'icon': 'watch_rounded'},
    {'id': 'lifestyle', 'name': 'Lifestyle', 'icon': 'local_cafe_rounded'},
  ];

  /// Typed categories list.
  static const List<Category> categoryList = Category.standardCategories;

  /// Promotional hero banners for the Home page.
  static const List<Map<String, dynamic>> promoBanners = [
    {
      'title': 'Spring Tech Mega Sale',
      'subtitle': 'Up to 40% OFF on flagship audio & wearables',
      'code': 'TECH40',
      'badge': 'Limited Time',
    },
    {
      'title': 'Urban Lifestyle Essentials',
      'subtitle': 'Curated minimalist gear built to last a lifetime',
      'code': 'STYLE20',
      'badge': 'New Arrival',
    },
    {
      'title': 'Free Express Delivery',
      'subtitle': 'On all orders above ₹999 with express doorstep tracking',
      'code': 'FREESHIP',
      'badge': 'Special Perk',
    },
  ];

  /// Pre-generated valid JWT token (expires in 2036) for seamless offline demo login.
  static String generateMockJwt({
    String email = 'demo@shopsphere.com',
    String name = 'Demo Shopper',
  }) {
    final header = base64Url.encode(
      utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})),
    );
    final payload = base64Url.encode(
      utf8.encode(
        jsonEncode({
          'sub': 'mock_user_${email.hashCode.abs()}',
          'name': name,
          'email': email,
          // Expiry timestamp: Year 2036
          'exp': 2082758400,
        }),
      ),
    );
    // Remove padding '=' characters to adhere to strict JWT format
    final cleanHeader = header.replaceAll('=', '');
    final cleanPayload = payload.replaceAll('=', '');
    return '$cleanHeader.$cleanPayload.shopsphere_mock_signature';
  }
}
