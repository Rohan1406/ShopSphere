# ShopSphere

A modern, robust e-commerce mobile application built with **Flutter**, **Riverpod**, and **Feature-First MVC Architecture**.

For the complete in-depth documentation covering architecture, features, API specs, state management, and test suites, see **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)**.

---

## 🚀 Key Features

- **Feature-First MVC Architecture**: Cleanly partitioned `models/`, `views/`, and `controllers/` per feature module.
- **State Management**: Riverpod `Notifier` & `NotifierProvider.family` powering reactive controllers with sealed state unions.
- **Authentication & Secure Storage**: JWT session management, hardware-backed secure storage (`flutter_secure_storage`), token validity decoding (`jwt_decoder`), silent session restoration, and offline demo support.
- **Advanced Networking**: Dio HTTP client configured with automatic Bearer token injection, queued 401 interception with concurrency-safe single-flight token refresh (`AuthRefreshCoordinator`), and typed domain error mapping.
- **Declarative Navigation**: GoRouter with `StatefulShellRoute.indexedStack` persistent bottom navigation tabs (Home, Explore, Cart, Profile) and reactive auth redirect guards.
- **Product Catalog & Details**: Browse products, view item details with collapsible sliver app bar, rating badge, price highlights, and dynamic quantity selector.
- **Cart & Promo Engine**: Dedicated `CartController` supporting real-time calculations, quantity modifications, item removals, and promo code discounts.
- **Material 3 Theming**: Consistent color system and component styling.
- **Automated Test Suite**: 83 unit and widget tests covering all critical paths.

---

## 🛠️ Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Static Analysis
```bash
flutter analyze
```

### 3. Run Tests
```bash
flutter test
```

### 4. Run the App

#### Via CLI:
```bash
# Development
flutter run --dart-define-from-file=config/development.json

# Staging
flutter run --dart-define-from-file=config/staging.json

# Production
flutter run --dart-define-from-file=config/production.json
```

#### Via VS Code / Antigravity IDE (Run & Debug):
Press `F5` or open the **Run and Debug** panel (`Ctrl+Shift+D` / `Cmd+Shift+D`) and select:
- **ShopSphere (Development - Debug)**
- **ShopSphere (Staging - Debug)**
- **ShopSphere (Production - Debug)**
- **ShopSphere (Development/Staging/Production - Profile / Release)**
- **ShopSphere (Run All Tests)**


---

## 📚 Documentation
For complete technical details, consult **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)**.
