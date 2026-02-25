# Contact Manager — Flutter

A modern, production-ready contact management application built with **Flutter**, **GetX**, and **SQLite**. Features a clean architecture with reactive state management, responsive tablet support, and a polished Material 3 UI.

## 📱 Overview

Contact Manager is a fully offline-capable contacts application that lets users create, edit, search, sort, and organize contacts with favorites. The app stores data locally using SQLite and supports an adaptive two-pane layout for tablets. Designed as a clean, maintainable codebase following industry best practices.

## ✨ Features

- **Add / Edit / Delete Contacts** — Full CRUD with form validation
- **Mark as Favorite** — Quick toggle with animated star icon
- **Search** — Debounced real-time search across name, phone, and email
- **Sorting** — Local reactive sorting by Name (A–Z), Date Created, or Date Modified
- **Tablet Support** — Responsive two-pane master-detail layout (600dp breakpoint)
- **Contact Avatars** — Optional profile images from gallery with local file storage
- **Phone & Email Actions** — Direct call and email launch via URL schemes
- **Reactive UI** — All lists update instantly without database refetching
- **Smooth Animations** — Hero transitions, shimmer loading, fade-in entries
- **Dark Mode** — Full Material 3 dynamic theming support

## 🏗 Architecture

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **State Management** | GetX | Reactive observables, navigation, dependency injection |
| **Database** | SQLite (sqflite) | Local persistent storage with migration support |
| **Pattern** | Repository | Abstracts data source from business logic |
| **UI ↔ Logic** | Dumb UI / Smart Controller | All business logic, validation, and navigation lives in the controller; screens are purely presentational |

### Key Design Decisions

- **Centralized `AppStrings`** — All user-facing text is in `lib/core/constants/app_strings.dart`. No hardcoded strings in UI or controller code.
- **Centralized `showMessage()`** — Single snackbar method in the controller handles success/error feedback with duplicate prevention.
- **Local Sorting** — Sorting is performed in-memory (O(n log n)) without re-querying the database, keeping the UI responsive.
- **Lightweight Image Support** — Avatar images are stored as local file paths in SQLite. No cloud storage or complex image processing.
- **DB Migration** — Schema versioning with `onUpgrade` ensures safe upgrades for existing users.

## 📂 Folder Structure

```
lib/
├── main.dart                          # App entry point, GetMaterialApp setup
├── app/
│   ├── routes/
│   │   └── app_routes.dart            # Named route constants
│   └── theme/
│       └── app_theme.dart             # Material 3 light & dark theme definitions
├── core/
│   └── constants/
│       └── app_strings.dart           # All static & dynamic user-facing strings
├── features/
│   └── contacts/
│       ├── controllers/
│       │   └── contact_controller.dart # All business logic, navigation, validation
│       ├── data/
│       │   ├── datasources/
│       │   │   └── database_helper.dart # SQLite operations, schema, migrations
│       │   ├── models/
│       │   │   ├── contact_model.dart   # Contact data class with serialization
│       │   │   └── contact_sort_type.dart # Sort mode enum
│       │   └── repositories/
│       │       └── contact_repository.dart # Repository abstraction over DB
│       └── screens/
│           ├── home_screen.dart         # Phone & tablet layouts, navigation bar
│           ├── contacts_screen.dart     # Contact list with search & sort
│           ├── favorites_screen.dart    # Favorites list
│           ├── contact_detail_screen.dart # Detail view (phone & tablet pane)
│           └── add_edit_contact_screen.dart # Add/Edit form with image picker
└── shared/
    └── utils/
        └── app_colors.dart             # Avatar color palette utility
```

## ⚙️ Setup Instructions

### Prerequisites

- **Flutter SDK** 3.41.x or later (stable channel)
- **Dart SDK** 3.11.x or later
- Android Studio / VS Code with Flutter extensions
- Android Emulator or physical device

### Installation

```bash
# 1. Clone the repository
git clone <repo_url>
cd contact_manager_flutter

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Verify Setup

```bash
flutter doctor
flutter analyze
```

## 📦 Build APK

### Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## 🚀 Git Push Instructions

```bash
# Initialize and push to GitHub
git init
git add .
git commit -m "Initial commit - Production Ready Contacts App"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

## 🛠 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `get` | ^4.7.2 | State management, navigation, DI |
| `sqflite` | ^2.4.2 | SQLite database |
| `path` | ^1.9.1 | Database file path resolution |
| `url_launcher` | ^6.3.1 | Phone call & email intents |
| `google_fonts` | ^6.2.1 | Typography (Inter, Outfit, etc.) |
| `image_picker` | ^1.1.2 | Gallery image selection for avatars |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

## 📄 License

This project is for educational / assignment purposes.
