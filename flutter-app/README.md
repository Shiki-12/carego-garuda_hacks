# Flutter Mobile App — CareGo

> **Owner: Dev B**  
> This entire directory is owned by the mobile developer.

## Setup

```bash
cd flutter-app
flutter pub get
flutter run
```

## Structure (to be scaffolded)

```
flutter-app/lib/
├── main.dart                  # Entry point, AuthGate, version check
├── models/
│   └── models.dart            # User, Recommendation data classes
├── services/
│   └── api_service.dart       # HTTP client for all backend endpoints
└── screens/
    ├── main_navigation.dart   # Bottom nav bar + tab switching
    ├── login_screen.dart      # Email/password, OTP, Google login
    ├── register_screen.dart   # OTP-verified registration
    ├── home_screen.dart       # Dashboard with services grid
    ├── ambulance_screen.dart  # Booking flow with GPS + map
    ├── caregiver_screen.dart  # Caregiver listing + booking
    ├── rental_screen.dart     # Equipment catalog + booking
    ├── orders_screen.dart     # Order history + tracking
    ├── chat_screen.dart       # Messaging
    ├── account_screen.dart    # Settings menu
    ├── profile_screen.dart    # Edit photo + phone
    ├── wallet_screen.dart     # Balance + top-up
    └── ...
```

## Conventions

- File naming: `snake_case.dart`
- Widget naming: `PascalCaseScreen`
- Typography: `GoogleFonts.inter()`
- Primary color: `Color(0xFF0D9488)` (teal)
- Error display: `SnackBar`
- State: `setState` + `SharedPreferences`

## Backend Connection

Edit `lib/services/api_service.dart`:
```dart
// Local (Android emulator):
static const String baseUrl = 'http://10.0.2.2:4000';

// Staging (Encore Cloud):
// static const String baseUrl = 'https://staging-url.encr.app';
```

## Before Adding API Methods

1. Pull latest `develop`
2. Read `docs/API_CONTRACT.md` for endpoint shapes
3. Implement methods matching the documented request/response
