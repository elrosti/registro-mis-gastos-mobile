# Registro Mis Gastos - Mobile App Specification

## 1. Project Overview

**Project Name:** Registro Mis Gastos Mobile  
**Project Type:** Cross-platform mobile application (Android & iOS)  
**Core Functionality:** Personal expense tracking app that allows users to register, track, and manage their expenses with multi-currency support, connecting to an existing REST API backend.  
**Target Users:** Individual users who want to track personal expenses on-the-go  
**Minimum Versions:** iOS 12.0+, Android API 21+ (Android 5.0)

---

## 2. Technology Stack

### Framework & Language
- **Framework:** Flutter 3.x (latest stable)
- **Language:** Dart 3.x
- **State Management:** flutter_bloc (BLoC pattern) with Hydrated BLoC for persistence
- **Dependency Injection:** get_it + injectable

### Key Dependencies
```yaml
# State & Data
flutter_bloc: ^8.1.3
hydrated_bloc: ^9.1.2
equatable: ^2.0.5

# Networking
dio: ^5.3.3
pretty_dio_logger: ^1.1.1

# Local Storage (Offline Cache)
sqflite: ^2.3.0
shared_preferences: ^2.2.2
path_provider: ^2.1.1

# Authentication
google_sign_in: ^6.1.4
flutter_appauth: ^6.0.1
secure_storage: ^1.1.1

# UI Components
flutter_slidable: ^3.0.1
intl: ^0.18.1
cached_network_image: ^3.3.0
shimmer: ^3.0.0

# Forms & Validation
formz: ^0.6.1
formz_input: ^0.4.0

# Utils
uuid: ^4.2.1
connectivity_plus: ^5.0.2
```

### Architecture Pattern
**Clean Architecture** with 3 layers:
```
lib/
├── core/                    # Shared utilities, constants, errors
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/                # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── transactions/
│   │   └── ... (same structure)
│   └── home/
│       └── ... (same structure)
├── injection_container.dart
└── main.dart
```

---

## 3. API Integration

### Base Configuration
- **Base URL:** `http://localhost:8080/api` (configurable via environment)
- **Content-Type:** `application/json`
- **Authentication:** Bearer JWT token

### API Endpoints to Use

#### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register with email/password |
| POST | `/auth/login` | Login with credentials |
| GET | `/auth/me` | Get current user profile |
| GET | `/auth/oauth/url/google` | Get Google OAuth URL |
| POST | `/auth/oauth/token/google` | Exchange Google code for token |

#### Transactions
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/transactions?page=0&size=20&startDate=&endDate=&categoryId=&type=` | List transactions with filters |
| GET | `/transactions/{id}` | Get transaction details |
| POST | `/transactions` | Create transaction |
| PUT | `/transactions/{id}` | Update transaction |
| DELETE | `/transactions/{id}` | Soft delete transaction |

#### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/categories` | List all categories |
| GET | `/categories/most-used` | Get most used categories |

#### Reports
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/reports/monthly?year=&month=` | Get monthly summary |

### Offline Cache Strategy
- **Transactions:** Cache last 100 transactions locally in SQLite
- **Categories:** Cache all categories locally
- **Sync Strategy:** On app start, show cached data immediately, then fetch fresh data in background
- **Conflict Resolution:** Server data wins; local changes queued for retry when online

---

## 4. UI/UX Specification

### Design System

#### Color Palette (Matching Web Frontend)
```dart
// Primary Colors
primaryMain: #2563EB    // Main actions, FAB
primaryLight: #3B82F6   // Highlights
primaryDark: #1D4ED8    // Pressed states

// Background Colors
backgroundDefault: #F5F7FA  // Screen background
backgroundPaper: #FFFFFF   // Cards, sheets

// Status Colors
success: #22C55E   // Income, positive amounts
error: #EF4444     // Expenses, negative amounts, errors
warning: #F59E0B   // Warnings

// Text Colors (never use pure black)
textPrimary: #111827   // Headings, primary text
textSecondary: #6B7280 // Subtitles, hints
textDisabled: #9CA3AF  // Disabled text

// Border Colors
borderMain: #E5E7EB
borderLight: #F3F4F6
```

#### Typography
```dart
fontFamily: 'Inter' // Primary font

// Scale
headlineLarge: 32px / 600  // Screen titles
headlineMedium: 24px / 600 // Section headers
titleLarge: 20px / 600     // Card titles
titleMedium: 16px / 500    // List item titles
bodyLarge: 16px / 400      // Primary body text
bodyMedium: 14px / 400     // Secondary body text
labelLarge: 14px / 500     // Button text
labelSmall: 12px / 400    // Captions, timestamps
```

#### Spacing System (8pt grid)
```dart
spacing-xs: 4px
spacing-sm: 8px
spacing-md: 16px
spacing-lg: 24px
spacing-xl: 32px
spacing-xxl: 48px
```

#### Border Radius
```dart
radiusSmall: 10px   // Input fields
radiusMedium: 12px  // Buttons, chips
radiusLarge: 16px   // Cards, modals
radiusXl: 24px      // Bottom sheets
radiusPill: 9999px  // FAB, round buttons
```

#### Shadows
```dart
shadowSmall: 0 1px 2px rgba(0,0,0,0.05)
shadowMedium: 0 4px 6px rgba(0,0,0,0.07)
shadowLarge: 0 10px 15px rgba(0,0,0,0.1)
shadowCard: 0 4px 12px rgba(0,0,0,0.05)
```

### Navigation Structure

**Bottom Navigation Bar** with 4 tabs:

```
┌─────────────────────────────────────┐
│           App Content               │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  [Home]   [Add]   [Summary]  [More] │
│   Tab      FAB     Tab       Tab   │
└─────────────────────────────────────┘
```

1. **Home (Gastos)** - Transaction list with filters
2. **Add (Agregar)** - Add/Edit transaction (centered FAB style)
3. **Summary (Resumen)** - Monthly summary and charts
4. **More (Más)** - Profile, settings, logout

### Screen Specifications

#### 1. Splash Screen
- App logo centered
- Background: primaryMain (#2563EB)
- Auto-navigate to Login (if not authenticated) or Home (if authenticated)

#### 2. Login Screen
- **Layout:** Single scrollable column, centered content
- **Elements:**
  - App logo (80x80dp) at top
  - Title: "Registro Mis Gastos" (headlineLarge)
  - Subtitle: "Gestiona tus finanzas" (bodyLarge, textSecondary)
  - Email input field (if email login)
  - OR divider with "O"
  - Google Sign-In button (primary style)
- **Background:** backgroundDefault
- **Spacing:** 32px between major elements

#### 3. Register Screen
- **Layout:** Single scrollable column
- **Fields:**
  - Name input
  - Email input
  - Password input (with visibility toggle)
  - Confirm Password input
- **Validation:** Real-time validation with error messages below fields
- **Button:** "Crear Cuenta" (full width, primary)

#### 4. Home Screen (Transaction List)
- **AppBar:**
  - Title: "Mis Gastos" (headlineMedium)
  - Right action: Filter icon button
- **Summary Card** (sticky at top):
  - Shows current month balance
  - Total income (green) / Total expenses (red)
  - Compact horizontal layout
- **Filter Chips:**
  - Horizontal scrollable row below summary
  - Chips: "Todos", "Ingresos", "Gastos", Category chips
  - Selected chip: primaryMain background
- **Transaction List:**
  - Grouped by date (section headers: "Hoy", "Ayer", "Fecha")
  - Each item shows:
    - Category icon (colored circle, 40x40dp)
    - Transaction name (titleMedium)
    - Category name (bodyMedium, textSecondary)
    - Amount (titleMedium, green for income/red for expense)
    - Swipe left: Delete (red background)
    - Swipe right: Edit (primary background)
  - Pull-to-refresh enabled
  - Infinite scroll pagination (20 items per page)
  - Empty state: Illustration + "No hay transacciones" message
- **FAB:** Add button (center bottom nav, primaryMain, + icon)

#### 5. Add/Edit Transaction Screen
- **Entry Point:** Tap FAB or swipe-to-edit
- **Layout:** Bottom sheet (can be full screen on small devices)
- **Fields:**
  - Type toggle: Ingreso / Gasto (segmented control, top)
  - Amount input (large numeric keyboard, prominent)
    - Currency selector (UYU/USD dropdown)
  - Short name input (required, max 50 chars)
  - Description input (optional, multiline)
  - Category selector (grid of icons, required)
  - Date picker (defaults to today)
  - Tags input (autocomplete chips)
- **Actions:**
  - Save button (full width, bottom)
  - Cancel button (text button, top left)
- **Animations:**
  - Amount field pulses subtly on focus
  - Success: Sheet dismisses with check animation

#### 6. Category Selector
- **Layout:** Grid of category cards (3 columns)
- **Each Card:**
  - Icon (24x24dp) with category color background circle
  - Category name below (caption)
- **Search:** Top search bar to filter categories
- **Recently used:** First row shows 3 most used categories

#### 7. Summary Screen
- **AppBar:** Title: "Resumen" (headlineMedium)
- **Month Selector:** Horizontal arrow navigation + month/year display
- **KPIs Cards:**
  - Total Income (green background tint)
  - Total Expenses (red background tint)
  - Balance (blue background tint)
  - All cards use shadowCard, radiusLarge
- **Category Breakdown:**
  - Horizontal bar chart or pie chart
  - Top 5 categories by spending
  - Tap category to see percentage and amount
- **Loading State:** Shimmer placeholders
- **Error State:** Retry button with error message

#### 8. Profile/More Screen
- **Layout:** List-based settings
- **Sections:**
  - **Profile Card:**
    - User avatar (64x64dp, circular)
    - User name (titleLarge)
    - Email (bodyMedium, textSecondary)
    - Edit profile button
  - **Preferences:**
    - Default currency (UYU/USD)
    - Default transaction type
  - **Account:**
    - Change password
    - Logout (red text)
- **App Info:** Version number at bottom

### Widget Library

#### Core Widgets
1. **PrimaryButton** - Main action buttons
   - States: default, pressed (primaryDark), disabled (50% opacity), loading (spinner)
   - Height: 48dp, full width, radiusMedium

2. **SecondaryButton** - Secondary actions
   - Outlined style, primaryMain border

3. **TextInputField** - Text inputs
   - States: default, focused (primaryMain border), error (errorMain border), disabled
   - Label above, error message below
   - radiusSmall (10px)

4. **AmountInput** - Currency amount input
   - Large font size (32px)
   - Currency symbol prefix
   - Numeric keyboard

5. **TransactionListItem** - Transaction row
   - Swipeable with Slidable
   - Color-coded left border (income/expense)

6. **CategoryChip** - Category selector chip
   - Icon + label
   - Selected/unselected states

7. **SummaryCard** - KPI display card
   - Icon, label, value
   - Colored background tint

8. **LoadingShimmer** - Loading placeholder
   - Matches layout of content being loaded

9. **EmptyState** - Empty list state
   - Illustration, title, subtitle

10. **ErrorState** - Error display
    - Error icon, message, retry button

### Animations & Transitions
- **Page transitions:** Fade + slide up (300ms)
- **Bottom sheet:** Slide up (250ms, ease-out)
- **List items:** Staggered fade-in on load
- **FAB:** Scale animation on press
- **Success feedback:** Checkmark with scale + fade
- **Pull-to-refresh:** Custom indicator with app colors
- **Swipe actions:** Smooth reveal with background color

---

## 5. Functionality Specification

### Authentication Flow

#### Google OAuth (Primary)
1. User taps "Continuar con Google"
2. Native Google Sign-In flow launches
3. On success, exchange code with backend via `/auth/oauth/token/google`
4. Store JWT token in secure storage
5. Navigate to Home screen

#### Email/Password (Fallback)
1. User enters email and password
2. Call `/auth/register` or `/auth/login`
3. On success, store JWT token
4. Navigate to Home screen

#### Session Management
- JWT stored in secure storage (Keychain/Keystore)
- Auto-refresh token before expiration
- On 401 response, clear session and redirect to Login

### Transaction Management

#### Create Transaction
1. User taps FAB (+) button
2. Bottom sheet slides up with form
3. User fills required fields (type, amount, name, category)
4. On submit:
   - Show loading state
   - Call POST `/transactions`
   - On success: dismiss sheet, show success snackbar, refresh list
   - On error: show error message, keep sheet open

#### Edit Transaction
1. User swipes right on transaction OR taps transaction
2. Bottom sheet with pre-filled form
3. User modifies fields
4. On submit: PUT `/transactions/{id}`

#### Delete Transaction
1. User swipes left on transaction
2. Delete action revealed
3. User taps delete
4. Confirmation dialog: "Eliminar transacción?"
5. On confirm: DELETE `/transactions/{id}`
6. On success: remove from list with animation, show undo snackbar (5s)

#### Filter Transactions
- **Type:** All, Income, Expense (chip selector)
- **Date Range:** This month, Last month, Custom range
- **Category:** Single category filter
- **Applied filters shown as removable chips below filter bar**

### Offline Behavior
1. **On App Start:**
   - Load cached transactions immediately
   - Fetch fresh data in background
   - Update UI when new data arrives

2. **On Offline Create/Edit:**
   - Queue action locally with timestamp
   - Show "Guardado sin conexión" indicator
   - When online: sync with server, update with server response

3. **On Network Error:**
   - Show non-blocking error snackbar
   - Retry button where applicable

### Data Validation Rules
- **Amount:** Required, > 0, max 12 digits, 2 decimal places
- **Name:** Required, 1-50 characters
- **Category:** Required
- **Date:** Cannot be future date (warning only, allows override)
- **Email:** Valid email format
- **Password:** Minimum 8 characters

---

## 6. State Management

### BLoC Structure

#### AuthBloc
```
States: AuthInitial, AuthLoading, AuthAuthenticated(user), AuthUnauthenticated, AuthError
Events: AuthCheckRequested, AuthGoogleSignInRequested, AuthEmailLoginRequested, AuthRegisterRequested, AuthLogoutRequested
```

#### TransactionBloc
```
States: TransactionInitial, TransactionLoading, TransactionLoaded(transactions, hasMore), TransactionError
Events: TransactionFetchRequested, TransactionCreateRequested, TransactionUpdateRequested, TransactionDeleteRequested, TransactionFilterChanged
```

#### CategoryBloc
```
States: CategoryInitial, CategoryLoading, CategoryLoaded(categories), CategoryError
Events: CategoryFetchRequested
```

#### SummaryBloc
```
States: SummaryInitial, SummaryLoading, SummaryLoaded(monthlyData), SummaryError
Events: SummaryFetchRequested(year, month), SummaryMonthChanged
```

### Hydrated BLoC (Persistence)
- Auth state persisted: keep user logged in across app restarts
- Transaction filters persisted: remember user's filter preferences
- Selected currency persisted: default currency preference

---

## 7. Security Considerations

1. **Token Storage:** Use flutter_secure_storage for JWT (encrypted)
2. **No sensitive data in logs:** Sanitize Dio logs
3. **Certificate pinning:** Optional for production
4. **Biometric auth:** Optional enhancement for app unlock
5. **Session timeout:** Auto-logout after 30 days of inactivity

---

## 8. Project Structure

```
registro-mis-gastos-mobile/
├── android/                    # Android-specific config
├── ios/                       # iOS-specific config
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_interceptor.dart
│   │   │   └── connectivity_service.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── currency_formatter.dart
│   │       └── date_formatter.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── google_sign_in.dart
│   │   │   │       ├── email_login.dart
│   │   │   │       ├── register.dart
│   │   │   │       └── logout.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   └── register_page.dart
│   │   │       └── widgets/
│   │   │           └── google_button.dart
│   │   ├── transactions/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       │   ├── home_page.dart
│   │   │       │   └── add_transaction_page.dart
│   │   │       └── widgets/
│   │   │           ├── transaction_list_item.dart
│   │   │           ├── transaction_filters.dart
│   │   │           └── summary_card.dart
│   │   ├── categories/
│   │   │   └── ... (same structure)
│   │   ├── summary/
│   │   │   └── ... (same structure)
│   │   └── profile/
│   │       └── ... (same structure)
│   ├── injection_container.dart
│   └── main.dart
├── pubspec.yaml
├── .env.example
└── README.md
```

---

## 9. Implementation Priorities

### Phase 1: Foundation
1. Project setup with Clean Architecture
2. Theme and design system
3. API client with Dio
4. Authentication feature (Google OAuth)
5. Basic navigation with bottom bar

### Phase 2: Core Features
1. Transaction list (home screen)
2. Add/Edit transaction
3. Delete transaction with swipe
4. Category selector
5. Basic filters

### Phase 3: Enhanced Features
1. Offline cache with SQLite
2. Monthly summary screen
3. Pull-to-refresh
4. Infinite scroll

### Phase 4: Polish
1. Loading states (shimmer)
2. Empty states
3. Error handling
4. Animations and transitions
5. Profile screen

---

## 10. Suggested File Structure for Implementation

```
lib/
├── main.dart                           # App entry, BlocProvider setup
├── app.dart                            # MaterialApp configuration
├── injection_container.dart           # GetIt service locator setup
├── core/
│   ├── constants/
│   │   └── api_constants.dart         # API endpoints, headers
│   ├── errors/
│   │   ├── exceptions.dart            # ServerException, CacheException
│   │   └── failures.dart              # Failure classes for Either<Failure, Success>
│   ├── network/
│   │   ├── api_client.dart            # Dio instance with interceptors
│   │   ├── api_interceptor.dart       # Auth header, error handling, logging
│   │   └── connectivity_service.dart  # Network connectivity monitoring
│   └── theme/
│       ├── app_colors.dart            # Color constants from design system
│       ├── app_typography.dart         # TextStyles
│       ├── app_spacing.dart           # Spacing and radius constants
│       └── app_theme.dart             # ThemeData configuration
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart    # API calls
│   │   │   │   └── auth_local_datasource.dart     # Secure storage
│   │   │   ├── models/
│   │   │   │   └── user_model.dart                 # JSON serialization
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart (abstract)
│   │   │   └── usecases/
│   │   │       ├── google_sign_in.dart
│   │   │       ├── email_login.dart
│   │   │       ├── register.dart
│   │   │       └── logout.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── splash_page.dart
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           ├── google_sign_in_button.dart
│   │           └── auth_text_field.dart
│   ├── transactions/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── transaction_remote_datasource.dart
│   │   │   │   └── transaction_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── transaction_model.dart
│   │   │   │   └── category_model.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── transaction.dart
│   │   │   │   └── category.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_transactions.dart
│   │   │       ├── create_transaction.dart
│   │   │       ├── update_transaction.dart
│   │   │       └── delete_transaction.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── transaction_bloc.dart
│   │       │   ├── transaction_event.dart
│   │       │   └── transaction_state.dart
│   │       ├── pages/
│   │       │   ├── home_page.dart
│   │       │   └── add_transaction_page.dart
│   │       └── widgets/
│   │           ├── transaction_list_item.dart
│   │           ├── transaction_filters.dart
│   │           ├── summary_header.dart
│   │           ├── category_selector.dart
│   │           └── amount_input.dart
│   ├── categories/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── summary/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   └── summary_page.dart
│   │       └── widgets/
│   │           ├── kpi_card.dart
│   │           └── category_chart.dart
│   └── profile/
│       └── presentation/
│           ├── pages/
│           │   └── profile_page.dart
│           └── widgets/
│               └── profile_header.dart
└── shared/
    └── widgets/
        ├── primary_button.dart
        ├── text_input_field.dart
        ├── loading_shimmer.dart
        ├── empty_state.dart
        ├── error_state.dart
        └── confirmation_dialog.dart
```

---

## 11. Key Implementation Notes

### Dio Configuration
```dart
final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ),
)..interceptors.addAll([
    AuthInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);
```

### Auth Interceptor
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getTokenFromStorage();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear token and redirect to login
    }
    handler.next(err);
  }
}
```

### Offline Sync Strategy
```dart
class PendingAction {
  final String id;
  final String type; // CREATE, UPDATE, DELETE
  final String endpoint;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

// Queue in SQLite, process when online
// On conflict, server wins, notify user of changes
```

---

## 12. Testing Strategy

### Unit Tests
- All use cases
- BLoC state transitions
- Repository methods
- Form validation

### Widget Tests
- Individual widget rendering
- User interaction flows
- Error state displays

### Integration Tests
- Authentication flow
- Create/Edit/Delete transaction flow
- Offline/Online transitions

---

## 13. Environment Configuration

### Development (.env)
```
API_BASE_URL=http://10.0.2.2:8080/api  # Android emulator localhost
GOOGLE_CLIENT_ID=your-dev-client-id
```

### Production (.env)
```
API_BASE_URL=https://api.registromisgastos.com/api
GOOGLE_CLIENT_ID=your-prod-client-id
```

---

## 14. Accessibility

- Minimum touch target: 48x48dp
- Color contrast ratio: 4.5:1 minimum
- Semantic labels for screen readers
- Support for system font scaling
- Respect system dark/light mode (future enhancement)

---

*Document Version: 1.0*  
*Created: 2026-03-26*  
*Based on: expense-tracker-frontend design system*
