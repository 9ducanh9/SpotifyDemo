# Local Music Player

A Flutter application for local music playback with offline support, built with clean architecture principles.

## Features (EASY Level)

- ✅ CRUD operations for music tracks
- ✅ Local SQLite storage (offline-first)
- ✅ Audio playback with progress tracking
- ✅ Audio recording
- ✅ Search and filter functionality
- ✅ Favorite tracks management
- ✅ Clean Material Design UI
- ✅ Loading, empty, and error states
- ✅ Unit tests

## Tech Stack

- **Flutter** (Dart, stable channel)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: SQLite (sqflite)
- **Audio**: audioplayers, record
- **Testing**: Flutter test

## Project Structure

```
lib/
├── core/              # Core utilities and constants
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/              # Data layer
│   ├── models/        # Data models
│   ├── database/      # SQLite database
│   └── repositories/  # Data repositories
├── domain/            # Business logic layer
│   └── entities/      # Domain entities
├── features/          # Feature-based modules
│   ├── tracks/        # Music tracks feature
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   └── audio/         # Audio playback feature
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart          # App entry point
```

## Getting Started

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Testing

Run unit tests:
```bash
flutter test
```

## Demo Flow

1. Launch the app
2. Add a new music track (or record audio)
3. View track list
4. Search/filter tracks
5. Play a track
6. Mark/unmark favorite
7. Edit track details
8. Delete a track
