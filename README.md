# Contact Manager — Flutter

A modern, production-ready contact management application built with **Flutter**, **GetX**, and **SQLite**.  
Clean architecture · Reactive state · Responsive tablet layout · Material 3 UI.

---

## 📱 Overview

Contact Manager is a fully offline-capable contacts application that lets users create, edit, search, sort, and organize contacts with favorites. Data is stored locally using SQLite, and the app supports an adaptive two-pane layout for tablets. Designed as a clean, maintainable codebase following industry best practices.

---

## 🎬 Demo

> **Watch the app in action:**


https://github.com/user-attachments/assets/ed9455f6-fb5c-4b04-8767-b187486d92e1

<!-- 
  HOW TO ADD YOUR DEMO VIDEO:

  Option 1 — YouTube (Recommended)
  1. Record a screen demo of the app (1–2 min).
  2. Upload to YouTube as "Unlisted".
  3. Replace YOUR_VIDEO_ID above with the YouTube video ID.
     Example: https://youtu.be/abc123xyz → replace YOUR_VIDEO_ID with abc123xyz

  Option 2 — Google Drive
  1. Upload the video to Google Drive.
  2. Set sharing to "Anyone with the link can view".
  3. Replace the link above with:
     [▶ Watch Demo Video](https://drive.google.com/file/d/YOUR_FILE_ID/view)

  Option 3 — GitHub (GIF / MP4 < 10 MB)
  1. Drag the video/GIF into a GitHub Issue or PR to get a hosted URL.
  2. Embed it with: ![Demo](https://user-images.githubusercontent.com/...)
-->

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Add / Edit / Delete** | Full CRUD with form validation |
| **Favorites** | Quick toggle with animated star icon |
| **Search** | Debounced real-time search across name, phone, and email |
| **Sorting** | Reactive sorting by Name (A–Z), Date Created, or Date Modified |
| **Tablet Layout** | Responsive two-pane master-detail (600dp breakpoint) |
| **Contact Avatars** | Optional profile images from gallery with local file storage |
| **Phone & Email** | Direct call and email launch via URL schemes |
| **Reactive UI** | Lists update instantly without database refetching |
| **Animations** | Hero transitions, shimmer loading, fade-in entries |
| **Dark Mode** | Full Material 3 dynamic theming |

---

## 🏗 Architecture

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **State Management** | GetX | Reactive observables, navigation, dependency injection |
| **Database** | SQLite (sqflite) | Local persistent storage with schema migration |
| **Pattern** | Repository | Abstracts data source from business logic |
| **UI ↔ Logic** | Dumb UI / Smart Controller | All logic, validation, and navigation in the controller; screens are purely presentational |

### Key Design Decisions

- **Centralized `AppStrings`** — Every user-facing string lives in one file. No hardcoded text in UI or controller.
- **Centralized `showMessage()`** — Single snackbar method handles all feedback with duplicate prevention.
- **In-Memory Sorting** — O(n log n) sort without re-querying the database.
- **Lightweight Images** — Avatar paths stored as text in SQLite. No cloud storage.
- **DB Migration** — `onUpgrade` with version checks ensures safe schema upgrades.

---

## 📂 Folder Structure

```
lib/
├── main.dart                            # App entry point, GetMaterialApp setup
├── app/
│   ├── routes/
│   │   └── app_routes.dart              # Named route constants
│   └── theme/
│       └── app_theme.dart               # Material 3 light & dark themes
├── core/
│   └── constants/
│       └── app_strings.dart             # All static & dynamic user-facing strings
├── features/
│   └── contacts/
│       ├── controllers/
│       │   └── contact_controller.dart  # Business logic, navigation, validation
│       ├── data/
│       │   ├── datasources/
│       │   │   └── database_helper.dart # SQLite operations, schema, migrations
│       │   ├── models/
│       │   │   ├── contact_model.dart   # Contact data class with serialization
│       │   │   └── contact_sort_type.dart
│       │   └── repositories/
│       │       └── contact_repository.dart
│       └── screens/
│           ├── home_screen.dart          # Phone & tablet layouts, nav bar
│           ├── contacts_screen.dart      # Contact list with search & sort
│           ├── favorites_screen.dart     # Favorites list
│           ├── contact_detail_screen.dart
│           └── add_edit_contact_screen.dart
└── shared/
    └── utils/
        └── app_colors.dart              # Avatar color palette
```

---

## ⚙️ Setup Instructions

### Prerequisites

- **Flutter** 3.41.x or later (stable channel)
- **Dart** 3.11.x or later
- Android Studio / VS Code with Flutter extensions
- Android emulator or physical device

### Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd contact_manager_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Verify Setup

```bash
flutter doctor
flutter analyze
```

---

## 📦 Build APK

### Debug

```bash
flutter build apk --debug
```

Output → `build/app/outputs/flutter-apk/app-debug.apk`

### Release

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Output → `build/app/outputs/flutter-apk/app-release.apk`

---

## 📥 Download APK

> **Get the latest release APK from GitHub Releases:**

[**⬇ Download APK**](https://github.com/vinittailor/contact_manager_flutter/releases/tag/v.1.0.0)

<!-- 
  HOW TO CREATE A GITHUB RELEASE:

  1. Build the release APK:
     flutter clean && flutter pub get && flutter build apk --release

  2. Go to your GitHub repo → "Releases" → "Draft a new release"

  3. Fill in:
     - Tag: v1.0.0
     - Title: v1.0.0 — Contact Manager
     - Description: Production-ready release with all features.

  4. Attach the APK file from:
     build/app/outputs/flutter-apk/app-release.apk

  5. Click "Publish release"

  6. Replace YOUR_USERNAME above with your GitHub username.
-->

---

## 🚀 Git Push

```bash
git init
git add .
git commit -m "Initial commit - Production Ready Contacts App"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

---

## 🛠 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `get` | ^4.7.2 | State management, navigation, DI |
| `sqflite` | ^2.4.2 | SQLite database |
| `path` | ^1.9.1 | Database file path resolution |
| `url_launcher` | ^6.3.1 | Phone call & email intents |
| `google_fonts` | ^6.2.1 | Typography |
| `image_picker` | ^1.1.2 | Gallery image selection for avatars |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 📄 License

This project is for educational and portfolio purposes.
