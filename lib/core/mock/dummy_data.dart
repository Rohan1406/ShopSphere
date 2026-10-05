import 'dart:convert';
import 'package:shopsphere/features/products/models/category.dart';
import 'package:shopsphere/features/products/models/product.dart';

/// Class containing dummy datasets for development, testing, and UI preview.
abstract final class DummyData {
  /// Realistic dummy product catalog with diverse categories, brands and high-res images in Indian Rupees (INR).
  static final List<Product> products = [
    Product(
      id: '1',
      title: 'Sony WH-1000XM5 Noise Cancelling Headphones',
      description:
          'Industry-leading wireless noise-canceling headphones with 2 processors, 8 microphones, and up to 30 hours of battery life with ultra-fast charging.',
      price: 29999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
      category: 'electronics',
      brand: 'Sony',
      rating: 4.8,
      reviewsCount: 2450,
      inStock: true,
      isNewArrival: false,
      createdAt: DateTime(2025, 8, 10),
    ),
    Product(
      id: '2',
      title: 'Apple Watch Ultra 2 Titanium GPS + Cellular',
      description:
          'Rugged and capable smartwatch with 3000 nits display, precision dual-frequency GPS, and up to 36 hours of battery life for outdoor adventures.',
      price: 49999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80',
      category: 'accessories',
      brand: 'Apple',
      rating: 4.9,
      reviewsCount: 1840,
      inStock: true,
      isNewArrival: true,
      createdAt: DateTime(2026, 2, 15),
    ),
    Product(
      id: '3',
      title: 'Nike Air Max Performance Runners',
      description:
          'Engineered mesh upper with responsive Air cushioning for maximum comfort, stability, and high performance on track and asphalt.',
      price: 7999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
      category: 'footwear',
      brand: 'Nike',
      rating: 4.7,
      reviewsCount: 920,
      inStock: true,
      isNewArrival: true,
      createdAt: DateTime(2026, 1, 20),
    ),
    Product(
      id: '4',
      title: 'Zara Handcrafted Vintage Leather Backpack',
      description:
          'Premium full-grain leather backpack featuring a padded 15-inch laptop compartment, water-resistant interior lining, and antiqued brass hardware.',
      price: 3499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&q=80',
      category: 'fashion',
      brand: 'Zara',
      rating: 4.4,
      reviewsCount: 310,
      inStock: true,
      isNewArrival: false,
      createdAt: DateTime(2025, 11, 5),
    ),
    Product(
      id: '5',
      title: 'Keychron K2 Wireless Mechanical Keyboard',
      description:
          'Compact 75% layout mechanical keyboard with hot-swappable Gateron switches, RGB backlighting, and cross-platform Bluetooth & USB-C connectivity.',
      price: 6499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800&q=80',
      category: 'electronics',
      brand: 'Keychron',
      rating: 4.9,
      reviewsCount: 1210,
      inStock: true,
      isNewArrival: true,
      createdAt: DateTime(2026, 2, 1),
    ),
    Product(
      id: '6',
      title: 'Zara Heavyweight Organic Cotton Hoodie',
      description:
          'Ultra-soft 450 GSM French Terry cotton hoodie with tailored drop shoulders, double-layered hood, and durable ribbed cuffs.',
      price: 2499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&q=80',
      category: 'fashion',
      brand: 'Zara',
      rating: 4.3,
      reviewsCount: 480,
      inStock: true,
      isNewArrival: false,
      createdAt: DateTime(2025, 10, 12),
    ),
    Product(
      id: '7',
      title: 'Ray-Ban Polarized Aviator Sunglasses',
      description:
          'Classic lightweight titanium aviators with UV400 anti-reflective polarized lenses and comfortable silicone nose pads.',
      price: 5999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800&q=80',
      category: 'accessories',
      brand: 'Ray-Ban',
      rating: 4.6,
      reviewsCount: 670,
      inStock: true,
      isNewArrival: false,
      createdAt: DateTime(2025, 9, 18),
    ),
    Product(
      id: '8',
      title: 'Hydro Flask Stainless Steel Water Bottle 750ml',
      description:
          'Double-wall insulated bottle that keeps beverages cold for up to 24 hours or piping hot for 12 hours. BPA-free with leakproof flex cap.',
      price: 899.00,
      imageUrl:
          'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800&q=80',
      category: 'lifestyle',
      brand: 'Hydro Flask',
      rating: 4.8,
      reviewsCount: 1540,
      inStock: true,
      isNewArrival: false,
      createdAt: DateTime(2025, 7, 22),
    ),
    Product(
      id: '9',
      title: 'Apple AirPods Pro (2nd Gen) with MagSafe',
      description:
          'Crystal-clear audio with custom high-excursion drivers, active noise cancellation with transparency mode, and USB-C wireless charging case.',
      price: 24900.00,
      imageUrl:
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800&q=80',
      category: 'electronics',
      brand: 'Apple',
      rating: 4.9,
      reviewsCount: 3820,
      inStock: true,
      isNewArrival: true,
      createdAt: DateTime(2026, 2, 10),
    ),
    Product(
      id: '10',
      title: 'Lumina Minimalist Architectural LED Desk Lamp',
      description:
          'Dimmable touch-sensitive aluminum task lamp with 5 color temperatures, wireless charging base, and auto-timer function.',
      price: 1799.00,
      imageUrl:
          'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da?w=800&q=80',
      category: 'lifestyle',
      brand: 'Lumina',
      rating: 4.2,
      reviewsCount: 290,
      inStock: true,
      isNewArrival: false,
      createdAt: DateTime(2025, 12, 1),
    ),
    Product(
      id: '11',
      title: 'Nike Tech Fleece Slim Fit Joggers',
      description:
          'Premium lightweight warmth with tailored athletic silhouette, zippered bonded utility pockets, and ribbed ankle cuffs.',
      price: 4499.00,
      imageUrl:
          'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=800&q=80',
      category: 'fashion',
      brand: 'Nike',
      rating: 4.6,
      reviewsCount: 780,
      inStock: true,
      isNewArrival: true,
      createdAt: DateTime(2026, 1, 15),
    ),
    Product(
      id: '12',
      title: 'Canon EOS R5 Full-Frame Mirrorless Camera',
      description:
          '45MP full-frame CMOS sensor with DIGIC X processor, 8K raw video recording, and 5-axis in-body image stabilization.',
      price: 89999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80',
      category: 'electronics',
      brand: 'Canon',
      rating: 4.9,
      reviewsCount: 540,
      inStock: false, // Out of stock to test inStock toggle
      isNewArrival: true,
      createdAt: DateTime(2026, 2, 20),
    ),
    Product(
      id: '13',
      title: 'Levi\'s 511 Slim Fit All-Day Flex Jeans',
      description:
          'Modern slim-cut denim jeans with added stretch for all-day mobility and iconic leather patch detailing on back waist.',
      price: 3299.00,
      imageUrl:
          'https://images.unsplash.com/photo-1542272604-780c96856592?w=800&q=80',
      category: 'fashion',
      brand: 'Levi\'s',
      rating: 4.5,
      reviewsCount: 890,
      inStock: true,
      isNewArrival: false,
      createdAt: DateTime(2025, 10, 1),
    ),
    Product(
      id: '14',
      title: 'Samsung Galaxy Tab S9 Ultra AMOLED Display',
      description:
          'Massive 14.6-inch Dynamic AMOLED 2X display with S Pen included, IP68 water resistance, and Snapdragon 8 Gen 2 processor.',
      price: 45999.00,
      imageUrl:
          'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&q=80',
      category: 'electronics',
      brand: 'Samsung',
      rating: 4.7,
      reviewsCount: 620,
      inStock: false, // Out of stock to test inStock toggle
      isNewArrival: false,
      createdAt: DateTime(2025, 11, 20),
    ),
  ];

  /// List of unique brands available across the catalog
  static List<String> get allBrands {
    final brandsSet = products.map((p) => p.brand).toSet();
    final list = brandsSet.toList()..sort();
    return list;
  }

  /// Curated trending search keywords for instant discovery
  static const List<String> trendingSearches = [
    'Sony Headphones',
    'Nike Air Max',
    'Apple Watch',
    'Mechanical Keyboard',
    'Leather Backpack',
    'Polarized Sunglasses',
    'Organic Hoodie',
    'Hydro Flask',
  ];

  /// Simulated voice search phrases and transcription suggestions
  static const List<String> voiceSearchPrompts = [
    'Sony noise cancelling headphones',
    'Nike running shoes',
    'Apple Watch Ultra',
    'Keychron mechanical keyboard',
    'Zara cotton hoodie',
    'Polarized sunglasses',
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
