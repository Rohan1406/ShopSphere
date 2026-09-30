# ShopSphere - Project Overview & Technical Documentation (MVC Architecture)

> **Comprehensive guide to the architecture, features, data flow, API integrations, state management, and test suites developed in ShopSphere.**

---

## 1. Executive Summary

**ShopSphere** is a production-grade, modular e-commerce mobile application developed with **Flutter** (Dart 3) and **Material 3**. The codebase is structured using **Feature-First Model-View-Controller (MVC) Architecture**, powered by **Riverpod 3.x** for controller state management, **GoRouter 14.x** with `StatefulShellRoute.indexedStack` persistent bottom navigation tabs (Home, Explore, Cart, Profile), and **Dio 5.x** for networking with concurrent token refresh coordination.

### Key Highlights
- **Architecture**: Feature-First MVC (`models/`, `views/`, `controllers/` per feature).
- **State Management**: Flutter Riverpod (`Notifier` & `NotifierProvider.family` with sealed state unions for controllers).
- **Routing**: GoRouter with `StatefulShellRoute.indexedStack` persistent bottom navigation tabs (Home, Explore, Cart, Profile), auth guards, and fullscreen routes.
- **Resilient Networking**: Dio HTTP client with automatic JWT bearer injection, queued 401 interceptor, and single-flight token refresh coordinator (`AuthRefreshCoordinator`).
- **Secure Persistence**: Hardware-backed secure storage via `flutter_secure_storage` with automated JWT expiration checks (`jwt_decoder`).
- **Design System**: Material 3 theming with custom color tokens and responsive UI components.
- **Offline Mock & Dummy Data**: Out-of-the-box rich mock data catalog, promo banners, categories, cart management, and offline demo authentication.
- **Test Coverage**: 69 automated unit and widget tests covering controllers, models, views, router redirects, dummy datasets, bottom navigation shell, and UI flows.

---

## 2. Technology Stack & Dependencies

| Category | Package / Tool | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Framework** | Flutter SDK | `>=3.11.4` | Cross-platform UI toolkit |
| **Language** | Dart SDK | `3.x` | Strongly typed object-oriented language |
| **Architecture** | Feature-First MVC | N/A | High velocity, pragmatic, low-boilerplate structure |
| **State Management** | `flutter_riverpod` | `^3.3.2` | Reactive, compile-safe state management & DI for controllers |
| **Routing** | `go_router` | `^14.0.0` | Declarative routing with tabbed shell & auth redirect guards |
| **HTTP Client** | `dio` | `^5.11.1` | Network communication & interceptor pipeline |
| **Secure Storage** | `flutter_secure_storage` | `^11.2.0` | Keychain (iOS/macOS) & Keystore (Android) access |
| **JWT Utilities** | `jwt_decoder` | `^2.0.1` | Token payload decoding & expiry verification |
| **Icons** | `cupertino_icons` | `^1.0.8` | iOS style iconography |
| **Linting** | `flutter_lints` | `^6.0.0` | Standard Flutter static analysis rules |
| **Testing** | `flutter_test`, `mocktail` | `^1.0.5` | Unit, widget, and mocking test frameworks |

---

## 3. Project Architecture & Directory Structure

ShopSphere adopts a **Feature-First MVC (Model-View-Controller)** pattern. This eliminates unnecessary layer boilerplate (such as duplicate entity/model definitions and multiple repository interface/implementation files) while maintaining clean separation of concerns and high testability.

```
shopsphere/
├── config/                               # Multi-environment configuration files
│   ├── development.json                  # Dev environment endpoints and flags
│   ├── staging.json                      # Staging environment configuration
│   └── production.json                   # Production environment configuration
├── lib/
│   ├── main.dart                         # Application entry point (ProviderScope root)
│   ├── app/                              # Top-level app configuration & composition
│   │   ├── app.dart                      # ShopSphereApp root widget & theme binding
│   │   ├── di/
│   │   │   └── app_dependencies.dart     # Dio client + AuthInterceptor DI wiring
│   │   ├── router/
│   │   │   ├── app_router.dart           # GoRouter route definitions & auth redirects
│   │   │   ├── auth_router_refresh.dart  # ChangeNotifier linking Riverpod auth state to GoRouter
│   │   │   └── scaffold_with_nav_bar.dart# Persistent bottom navigation shell
│   │   ├── startup/
│   │   │   └── auth_startup_screen.dart  # Initial splash / session restoration screen
│   │   └── theme/
│   │       ├── app_colors.dart           # Centralized color tokens
│   │       └── app_theme.dart            # Material 3 ThemeData configuration
│   ├── core/                             # Core cross-cutting infrastructure
│   │   ├── config/
│   │   │   ├── app_config.dart           # Compile-time environment resolution
│   │   │   └── app_environment.dart      # Environment enum (dev, staging, prod)
│   │   ├── errors/
│   │   │   ├── app_exception.dart        # Domain exception hierarchy
│   │   │   └── failure.dart              # Standardized failure value objects
│   │   ├── mock/
│   │   │   └── dummy_data.dart           # Realistic catalog, promos, categories & mock JWTs
│   │   ├── network/
│   │   │   ├── api_endpoints.dart        # Central API URI definitions
│   │   │   ├── auth_refresh_coordinator.dart # Deduplicated concurrency-safe token refresher
│   │   │   ├── dio_client.dart           # Base Dio client configuration
│   │   │   ├── dio_error_mapper.dart     # Maps DioException to AppException
│   │   │   ├── network_providers.dart    # Dio & DioClient Riverpod providers
│   │   │   └── interceptors/
│   │   │       └── auth_interceptor.dart # QueuedInterceptor for token injection & 401 retry
│   │   ├── result/
│   │   │   └── result.dart               # Sealed Result<T> (Success / Error) Monad
│   │   └── storage/
│   │       ├── secure_token_storage.dart # FlutterSecureStorage implementation
│   │       ├── storage_providers.dart    # Storage & TokenManager providers
│   │       ├── token_manager.dart        # JWT expiry logic & token lifecycle helper
│   │       └── token_storage.dart        # TokenStorage abstract interface
│   └── features/                         # Modular Feature Packages (MVC)
│       ├── auth/                         # Authentication Feature
│       │   ├── controllers/
│       │   │   └── auth_controller.dart  # AuthController & AuthState
│       │   ├── models/
│       │   │   └── auth_session.dart     # AuthSession data model
│       │   └── views/
│       │       └── pages/
│       │           └── login_page.dart   # Login screen UI
│       ├── cart/                         # Cart & Checkout Feature
│       │   ├── controllers/
│       │   │   └── cart_controller.dart  # CartController & CartState
│       │   ├── models/
│       │   │   └── cart_item.dart        # CartItem data model
│       │   └── views/
│       │       └── pages/
│       │           └── cart_page.dart    # Cart & Promo screen UI
│       ├── home/                         # Home & Discovery Feature
│       │   └── views/
│       │       └── pages/
│       │           └── home_page.dart    # Banners, categories & featured items UI
│       ├── products/                     # Products & Catalog Feature
│       │   ├── controllers/
│       │   │   └── product_controller.dart # ProductController, ProductDetailsController & States
│       │   ├── models/
│       │   │   └── product.dart          # Unified Product data model
│       │   └── views/
│       │       ├── pages/
│       │       │   ├── product_details_page.dart # Fullscreen product details
│       │       │   └── products_page.dart        # Catalog list view
│       │       └── widgets/
│       │           └── product_card.dart         # Product card component
│       └── profile/                      # User Profile Feature
│           └── views/
│               └── pages/
│                   └── profile_page.dart # Account settings & menu UI
└── test/                                 # Complete automated test suite (69 tests)
    ├── app/
    │   └── router/app_router_test.dart
    ├── core/
    │   ├── config/app_config_test.dart
    │   ├── mock/dummy_data_test.dart
    │   ├── network/
    │   │   ├── auth_interceptor_test.dart
    │   │   ├── auth_refresh_coordinator_test.dart
    │   │   └── dio_error_mapper_test.dart
    │   ├── result/result_test.dart
    │   └── storage/
    │       ├── secure_token_storage_test.dart
    │       ├── token_manager_test.dart
    │       └── storage_providers_test.dart
    └── features/
        ├── auth/
        │   ├── auth_controller_test.dart
        │   ├── auth_logout_test.dart
        │   └── login_page_test.dart
        ├── cart/
        │   └── cart_page_test.dart
        ├── home/
        │   ├── home_page_test.dart
        │   └── logout_navigation_test.dart
        ├── products/
        │   ├── product_controller_test.dart
        │   └── product_details_page_test.dart
        └── profile/
            └── profile_page_test.dart
```

---

## 4. MVC Component Design & Data Flow

```mermaid
flowchart TD
    subgraph View ["View (UI Layer)"]
        V1[Pages: HomePage, ProductsPage, CartPage, ProfilePage, LoginPage]
        V2[Widgets: ProductCard, QuantitySelector, NavBar]
    end

    subgraph Controller ["Controller (State & Business Logic)"]
        C1[AuthController]
        C2[ProductController & ProductDetailsController]
        C3[CartController]
    end

    subgraph Model ["Model (Data & Serialization)"]
        M1[Product]
        M2[AuthSession]
        M3[CartItem]
    end

    subgraph Services ["Core Infrastructure & Services"]
        S1[DioClient / HTTP API]
        S2[TokenManager / SecureStorage]
        S3[DummyData Mock Fallback]
    end

    View -->|User Action / Event| Controller
    Controller -->|Fetch / Mutate| Services
    Services -->|JSON Response / Payload| Model
    Model -->|Instantiated Objects| Controller
    Controller -->|Emit Reactive State (Riverpod)| View
```

---

## 5. Detailed Feature Breakdown

### 5.1. Authentication (`lib/features/auth/`)
- **Model (`AuthSession`)**:
  - Encapsulates `accessToken` and `refreshToken` with `fromJson` and `toJson`.
- **Controller (`AuthController`)**:
  - Manages `AuthState` (`AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`).
  - Methods: `restoreSession()`, `login({email, password})`, `refreshSession({refreshToken})`, `logout()`.
  - Offline demo mode support: Automatically validates and accepts demo credentials when offline.
- **View (`LoginPage`)**:
  - Responsive layout, email and password validators, loading indicators, SnackBar error banners.

### 5.2. Products & Catalog (`lib/features/products/`)
- **Model (`Product`)**:
  - Unified data model (`id`, `title`, `description`, `price`, `imageUrl`) with JSON conversion.
- **Controller (`ProductController` & `ProductDetailsController`)**:
  - `ProductController`: Manages `ProductState` (`ProductInitial`, `ProductLoading`, `ProductLoaded`, `ProductError`).
  - `ProductDetailsController`: Manages `ProductDetailsState` keyed by `productId`.
  - Network-first fetching with seamless offline fallback to `DummyData`.
- **Views**:
  - `ProductsPage`: Catalog list with loading indicator, error retry button, empty state.
  - `ProductDetailsPage`: Collapsible sliver header, rating badge, price tag, quantity selector, add to cart trigger.
  - `ProductCard`: Card widget with network image placeholder and product summary.

### 5.3. Cart & Promo Engine (`lib/features/cart/`)
- **Model (`CartItem`)**:
  - Holds `id`, `title`, `price`, `imageUrl`, `quantity`, and calculated `subtotal`.
- **Controller (`CartController`)**:
  - Manages `CartState` (items list, promo codes, discount percentages, subtotal, discount amount, grand total).
  - Methods: `addProduct(product, {quantity})`, `updateQuantity(id, quantity)`, `incrementQuantity(id)`, `decrementQuantity(id)`, `removeItem(id)`, `clearCart()`, `applyPromo(code)`, `removePromo()`.
  - Supports promo codes: `TECH40` (40% OFF), `STYLE20` (20% OFF).
- **View (`CartPage`)**:
  - Interactive cart items, quantity modifiers, promo code input, summary calculation card, empty cart state.

### 5.4. Home & Discovery (`lib/features/home/`)
- **View (`HomePage`)**:
  - Search trigger bar leading to catalog.
  - Horizontal promotional banners (`DummyData.promoBanners`).
  - Horizontal category chips (`All`, `Electronics`, `Fashion`, `Footwear`, `Accessories`, `Lifestyle`).
  - Featured products grid with fast navigation.

### 5.5. Profile & Settings (`lib/features/profile/`)
- **View (`ProfilePage`)**:
  - User avatar, name, email, membership status badge (`VIP Member`).
  - Account statistics (Orders, Wishlist, Coupons).
  - Categorized menu tiles (My Orders, Saved Addresses, Payment Methods, Push Notifications, Support, Privacy).
  - Logout action with confirmation and state reset.

---

## 6. Testing & Quality Assurance Summary

The test suite consists of **69 automated tests** verifying all controllers, models, views, and core infrastructure:

```
00:07 +69: All tests passed!
```

### Test Coverage Breakdown:
- **Controllers & State**:
  - `auth_controller_test.dart`: Login, offline fallback, token saving, restoreSession, logout.
  - `auth_logout_test.dart`: Logout state transitions and storage clearing.
  - `product_controller_test.dart`: Catalog fetching, offline dummy fallback, product details fetching.
  - `cart_page_test.dart`: CartController state transitions, quantity updates, promo calculations, clearing.
- **Views & UI Flow Widgets**:
  - `login_page_test.dart`: Validation triggers, button loading state, form submission.
  - `home_page_test.dart`: UI rendering, logout actions, button states.
  - `logout_navigation_test.dart`: End-to-end router navigation on logout.
  - `product_details_page_test.dart`: Details rendering, image loading, add to cart actions.
  - `cart_page_test.dart`: Cart items list, summary calculations, promo code application.
  - `profile_page_test.dart`: User profile details, menu items, logout button.
- **Core Infrastructure**:
  - `app_router_test.dart`: Route guards, unauthenticated/authenticated redirects.
  - `dummy_data_test.dart`: Catalog validity, mock JWT generation, categories, promos.
  - `auth_interceptor_test.dart`: Bearer header injection, 401 interception, retry logic.
  - `auth_refresh_coordinator_test.dart`: Concurrency deduplication.
  - `dio_error_mapper_test.dart`: HTTP status code and exception mappings.
  - `token_storage_test.dart` & `token_manager_test.dart`: Token storage, expiry decoding, clearing.
  - `result_test.dart` & `app_config_test.dart`: Monadic Result handling and environment resolution.

---

## 7. Running & Testing Instructions

```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analysis (0 errors, 0 warnings)
flutter analyze

# 3. Execute test suite (69 tests passing)
flutter test

# 4. Run application in development
flutter run --dart-define=APP_ENV=development --dart-define=BASE_URL=https://api.example.com
```

---

*Documentation updated following successful migration to MVC architecture.*
