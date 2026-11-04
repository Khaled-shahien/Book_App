<div align="center">

# Book App

A Flutter bookstore app for discovering books, browsing categories, viewing details, and managing a simple cart experience.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![CI](https://github.com/Khaled-shahien/Book_App/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/Khaled-shahien/Book_App/actions)

[Download](#download) * [Features](#features) *
[Architecture](#architecture) * [Getting Started](#getting-started)

</div>

---

## About
Book App is a cross-platform Flutter application for readers who want a clean way to explore books, inspect details, and move through a bookstore-style flow. It integrates Google Books API data with a Firebase-ready app foundation and a feature-first Flutter codebase.

The project is suited for learning or extending a modern Flutter app that uses GetX for routing/state patterns, Dio for HTTP calls, Firebase packages for backend integration, and Material theming for the UI.

## Features
| Feature | Description |
|---------|-------------|
| Welcome and splash flow | Launch and onboarding entry points for first-run navigation. |
| Authentication screens | Login and registration views backed by Firebase-ready dependencies. |
| Book discovery | Fetches book data from the Google Books API using Dio. |
| Category browsing | Category UI and category-driven book browsing screens. |
| Book details | Dedicated detail view for selected books. |
| Cart view | Cart screen for a bookstore-style purchase flow. |
| Account area | Profile/account page for user-facing settings and identity. |
| Responsive assets | Image and screenshot assets included for multi-screen documentation and UI polish. |

## Architecture
The app uses a feature-first Flutter structure. Shared concerns live under `lib/core`, while screens and feature-specific widgets/controllers live under `lib/features`. State and navigation patterns are built around GetX controllers, bindings, and `GetPage` routes.

Project structure:

```text
lib/
|-- main.dart
|-- core/
|   |-- api/
|   |-- constants/
|   |-- controllers/
|   |-- errors/
|   |-- firebase/
|   |-- helper_function/
|   |-- models/
|   |-- navigation/
|   |-- routes/
|   |-- services/
|   |-- theme/
|   `-- widgets/
`-- features/
    |-- account/
    |-- cart/
    |-- category/
    |   `-- widgets/
    |-- details/
    |-- home/
    |   |-- data/
    |   |   `-- controllers/
    |   `-- widgets/
    |-- login/
    |-- register/
    |-- splash/
    `-- welcome/
```

## Tech Stack
| Technology | Usage |
|------------|-------|
| Flutter | Cross-platform app framework. |
| Dart | Application language, SDK constraint `^3.10.4`. |
| GetX | Routing, bindings, dependency setup, and reactive controllers. |
| Dio | HTTP client for Google Books API requests. |
| Firebase Core | Firebase initialization foundation. |
| Firebase Auth | Authentication dependency for login and registration flows. |
| Cloud Firestore | Data persistence dependency for Firebase-backed features. |
| Google Fonts | Custom typography support. |
| flutter_lints | Static analysis and linting baseline. |

## Screenshots
| Welcome | Home | Book Details |
|---------|------|--------------|
| ![](assets/screenshots/welcome.png) | ![](assets/screenshots/home.png) | ![](assets/screenshots/book_details.png) |

| Login | Categories | Cart |
|-------|------------|------|
| ![](assets/screenshots/login.png) | ![](assets/screenshots/categories.png) | ![](assets/screenshots/cart.png) |

## Getting Started

### Prerequisites
- Flutter SDK (stable, Dart >= 3.10)
- Java 17 for Android builds
- A Firebase project if you plan to use authentication or Firestore features

### Installation
1. Clone the repository:

```bash
git clone https://github.com/Khaled-shahien/Book_App.git
cd Book_App
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### Environments (dev / staging / prod)
Config is injected at compile time with `--dart-define-from-file`. Copy a template once (the copies are git-ignored):

```bash
cp env/dev.example.json env/dev.json
flutter run --dart-define-from-file=env/dev.json
```

Keys: `APP_ENV`, `BOOKS_API_BASE_URL`, `BOOKS_API_KEY` (optional). See `lib/core/config/app_config.dart`.

### Firebase
Firebase configuration files are intentionally ignored and must not be committed. Generate them locally with the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Security rules live in `firestore.rules`; deploy with `firebase deploy --only firestore:rules`.

### Testing

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test --coverage
```

Unit tests cover the API client (with a scripted HTTP adapter), models, validators, cart money math and `BookController`. Widget tests cover splash routing, Home loading/error/empty/success, and the form widgets.

### Release

```bash
# Android: requires android/key.properties (see android/key.properties.example)
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols \
  --dart-define-from-file=env/prod.json

# iOS
flutter build ipa --release --obfuscate --split-debug-info=build/symbols \
  --dart-define-from-file=env/prod.json
```

Keep `build/symbols` to symbolicate crash reports. The remaining manual release steps are in [docs/HUMAN_ACTIONS.md](docs/HUMAN_ACTIONS.md); the audit and decisions are in [docs/](docs/).

## Download
[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](../../releases/latest)

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).

## License
This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
