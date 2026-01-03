# Project Structure

This document explains the folder structure and architecture of the Local Music Player application.

## Overview

The project follows a **feature-based architecture** with clear separation of concerns across multiple layers:

- **UI Layer**: Presentation widgets and screens
- **State Layer**: Riverpod providers for state management
- **Data Layer**: Models, repositories, and database
- **Services Layer**: Business logic and external services

## Directory Structure

```
lib/
├── core/                          # Core application utilities
│   ├── constants/
│   │   └── app_constants.dart     # Application-wide constants
│   ├── routing/
│   │   └── app_router.dart        # GoRouter configuration
│   └── theme/
│       └── app_theme.dart          # Theme configuration
│
├── data/                          # Data layer
│   ├── database/
│   │   └── database_helper.dart   # SQLite database operations
│   ├── models/                    # Data models
│   │   ├── music_track_model.dart # MusicTrack entity
│   │   └── user_model.dart        # User entity
│   └── repositories/
│       └── track_repository.dart   # Track data repository
│
├── features/                      # Feature-based modules
│   ├── tracks/                    # Music tracks feature
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── track_providers.dart  # Riverpod providers
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── track_list_screen.dart
│   │       │   ├── track_detail_screen.dart
│   │       │   └── add_edit_track_screen.dart
│   │       └── widgets/
│   │           ├── loading_widget.dart
│   │           ├── empty_state_widget.dart
│   │           ├── error_state_widget.dart
│   │           └── track_list_item.dart
│   │
│   └── audio/                     # Audio playback feature
│       └── presentation/
│           ├── providers/
│           │   └── audio_providers.dart  # Audio state providers
│           └── services/
│               └── audio_recording_service.dart  # Recording service
│
└── main.dart                      # Application entry point
```

## Architecture Layers

### 1. Core Layer (`lib/core/`)
Contains shared utilities and configurations:
- **Constants**: App-wide constants (database name, table names, etc.)
- **Routing**: Navigation configuration using GoRouter
- **Theme**: Material Design theme configuration

### 2. Data Layer (`lib/data/`)
Handles all data operations:
- **Models**: Data transfer objects (DTOs) with serialization
- **Database**: SQLite database helper with CRUD operations
- **Repositories**: Data access abstraction layer

### 3. Features Layer (`lib/features/`)
Feature-based modules, each containing:
- **Presentation**: UI components (screens, widgets, providers)
- **Domain**: Business logic (if needed for advanced features)
- **Data**: Feature-specific data operations (if needed)

### 4. State Management
Uses **Riverpod** for state management:
- Providers for data fetching
- State providers for UI state
- Future providers for async operations
- Automatic dependency injection

## Data Flow

```
UI (Screens/Widgets)
    ↓
Riverpod Providers
    ↓
Repositories
    ↓
Database Helper
    ↓
SQLite Database
```

## Key Design Patterns

1. **Repository Pattern**: Abstracts data access logic
2. **Provider Pattern**: Manages state and dependencies
3. **Feature-based Structure**: Organizes code by feature
4. **Separation of Concerns**: Clear boundaries between layers

## Naming Conventions

- **Files**: snake_case (e.g., `track_list_screen.dart`)
- **Classes**: PascalCase (e.g., `TrackListScreen`)
- **Variables/Functions**: camelCase (e.g., `getAllTracks`)
- **Constants**: camelCase with descriptive names (e.g., `databaseName`)

## Testing Structure

```
test/
├── music_track_model_test.dart    # Model unit tests
├── track_repository_test.dart     # Repository unit tests
└── database_helper_test.dart      # Database unit tests
```

## Future Extensions

The structure is designed to easily accommodate:
- **Medium Level**: Cloud sync, authentication, authorization
- **Advanced Level**: Multi-step workflows, reporting, real-time features

Each new feature can be added as a new module under `lib/features/` following the same pattern.
