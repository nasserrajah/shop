# Eight Shop

A Flutter storefront application built with **Clean Architecture**,
**Feature-First** structure and a deliberate split between **BLoC** and
**Riverpod** for state management.

The catalogue is remote (HTTP API), while the cart, favorites, orders, profile
and theme are persisted locally with `shared_preferences`.

## Architecture

Each feature is self-contained under `lib/features/<feature>/` and follows the
same three layers:

| Layer | Responsibility |
| --- | --- |
| `domain/` | Entities, repository contracts and use cases. Pure Dart, no Flutter or package dependencies. |
| `data/` | Models, data sources and repository implementations. Converts API/local payloads into domain entities and maps exceptions to failures. |
| `presentation/` | Pages, widgets, providers (Riverpod) and blocs (BLoC). |

Shared code lives in `lib/core/`:

- `constants/` – API endpoints and app/business constants.
- `di/` – Riverpod providers for infrastructure (`SharedPreferences`, HTTP client).
- `entities/` – cross-feature entities such as `PaymentMethod`.
- `error/` – exceptions, domain failures and the exception-to-failure mapper.
- `network/` – the small `ApiClient` wrapper around `package:http`.
- `result/` – dependency-free `Result<T>` (`Success` / `ResultFailure`).
- `routing/` – named routes and navigation helpers.
- `theme/` – colors, light/dark themes and the persisted theme-mode provider.
- `utils/` – formatters, validators, string helpers and readable error messages.
- `widgets/` – shared presentational widgets (loading, error, empty, buttons, etc.).

## Folder layout

```text
lib/
├── app.dart                  # MaterialApp + app-scoped bloc providers
├── main.dart                 # ProviderScope + SharedPreferences override
├── core/
│   ├── constants/  di/  entities/  error/  network/
│   ├── result/  routing/  theme/  utils/  widgets/
└── features/
    ├── products/             # remote catalogue, search, filtering, sorting
    │   ├── data/  domain/  presentation/
    ├── cart/                 # local cart with per-size line items
    ├── checkout/             # summary calculation + order submission
    ├── orders/               # order history and status lifecycle
    ├── favorites/            # locally persisted wish list
    ├── profile/              # profile, edit profile, settings, help
    └── shell/                # bottom navigation shell
```

## State management

The two libraries are used where they fit best, and they share the same
repositories so data is never duplicated.

### BLoC (event-driven workflows)

- `CatalogBloc` – load/refresh, search, category filter, sorting and retry.
- `OrdersBloc` – load orders, cancel and complete them. App-scoped so the home
  badge, orders page and order details stay in sync.
- `CheckoutBloc` – payment selection, submit lifecycle and duplicate-submit guard.
- `NavigationBloc` – bottom tab selection and back-button behavior.

BLoCs are created once through Riverpod providers (`catalogBlocProvider`,
`ordersBlocProvider`, `navigationBlocProvider`) and exposed to the widget tree
with `BlocProvider.value` in `lib/app.dart`.

### Riverpod (reactive/persisted state and dependency injection)

- `cartControllerProvider` – `AsyncNotifier<Cart>` with add/increment/decrement/
  remove/clear operations, plus derived `cartItemCountProvider`,
  `cartSubtotalProvider` and `cartIsEmptyProvider`.
- `favoritesControllerProvider` – `AsyncNotifier<List<Product>>` with toggle.
- `profileControllerProvider` – profile loading, saving and sign-out.
- `themeModeProvider` – light/dark/system theme persisted across launches.
- `productDetailsProvider` – `FutureProvider.family` for product details.
- `checkoutSummaryProvider` – derived totals from the cart.
- Repository, data source and use-case providers for every feature.

## Data and persistence

- Remote catalogue: `https://backend-course-6tuu.onrender.com`
  - `/api/products`
  - `/api/products/featured`
  - `/api/Categories`
- The product repository caches the catalogue in memory; a forced refresh is
  used by pull-to-refresh.
- Local storage keys are defined in `lib/core/constants/app_constants.dart`:
  favorites, cart, orders, profile and theme.
- Errors are represented with a sealed `Failure` hierarchy
  (`ServerFailure`, `NetworkFailure`, `CacheFailure`, `NotFoundFailure`,
  `ValidationFailure`, `UnknownFailure`).

## Checkout rules

- Discount: `$4.00`, capped at the subtotal.
- Delivery fee: `$2.00`.
- Orders are persisted before the cart is cleared; clearing the cart is
  best-effort so a cache hiccup cannot hide a successful purchase.

## Getting started

```bash
flutter pub get
flutter run
```

Requirements: Flutter 3.8.1+ / Dart 3.8.1+ (developed on Flutter 3.41.6).

## Quality checks

```bash
flutter analyze
flutter test
```

The test suite covers:

- `Result`, error mapping and readable error messages.
- Product filtering/sorting and checkout summary rules.
- Cart, favorites, orders and product repository persistence/caching.
- `SubmitOrder` orchestration and failure handling.
- Catalogue, orders, checkout and navigation blocs.
- An end-to-end widget smoke test that boots the app against fake repositories
  and navigates all four tabs.

## Assets

Banner images are declared in `pubspec.yaml`:

- `assets/images/winter.png`
- `assets/images/summer.png`
- `assets/images/short.png`
- `assets/images/flash sale.png`
