# Data Model Diagram

## Entity Relationship Diagram

```
┌─────────────────┐
│      User       │
├─────────────────┤
│ id (PK)         │
│ email (UNIQUE)  │
│ role            │
└─────────────────┘
         │
         │ 1:N
         │
         ▼
┌─────────────────┐         ┌──────────────────┐
│   MusicTrack    │────────▶│  ActionHistory   │
├─────────────────┤   1:N    ├──────────────────┤
│ id (PK)         │          │ id (PK)          │
│ title           │          │ trackId (FK)     │
│ artist          │          │ action           │
│ duration        │          │ performedBy       │
│ filePath        │          │ timestamp        │
│ createdAt       │          │ metadata         │
│ isFavorite      │          │ comment          │
│ workflowStatus  │          └──────────────────┘
│ lastModifiedAt  │
└─────────────────┘
```

## Data Models

### User Model
```dart
class User {
  int? id;
  String email;        // Unique identifier
  String role;         // 'regular' or 'admin'
}
```

### MusicTrack Model
```dart
class MusicTrack {
  int? id;                    // Primary key
  String title;               // Track title
  String artist;              // Artist name
  int duration;               // Duration in seconds
  String filePath;           // Local file path
  DateTime createdAt;        // Creation timestamp
  bool isFavorite;           // Favorite status
  WorkflowStatus workflowStatus;  // Workflow state
  DateTime? lastModifiedAt;  // Last modification time
}
```

### ActionHistory Model
```dart
class ActionHistory {
  int? id;                    // Primary key
  int trackId;               // Foreign key to MusicTrack
  String action;             // Action type (created, updated, etc.)
  String performedBy;        // User who performed action
  DateTime timestamp;        // When action occurred
  Map<String, dynamic>? metadata;  // Additional data
  String? comment;           // Optional comment
}
```

## Workflow Status States

```
Draft ──▶ Review ──▶ Approved ──▶ Completed
  │         │            │
  │         │            └──▶ Review (revert)
  │         │
  │         └──▶ Rejected ──▶ Draft
  │
  └──▶ Rejected ──▶ Draft
```

### Workflow Status Enum
```dart
enum WorkflowStatus {
  draft,      // Initial state
  review,     // Under review
  approved,   // Approved
  completed,  // Completed (final)
  rejected,   // Rejected
}
```

## Database Schema

### Tracks Table
```sql
CREATE TABLE tracks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  duration INTEGER NOT NULL,
  filePath TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  isFavorite INTEGER NOT NULL DEFAULT 0,
  workflowStatus TEXT NOT NULL DEFAULT 'draft',
  lastModifiedAt TEXT
);
```

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL DEFAULT 'regular'
);
```

### Action History Table
```sql
CREATE TABLE action_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trackId INTEGER NOT NULL,
  action TEXT NOT NULL,
  performedBy TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  metadata TEXT,
  comment TEXT,
  FOREIGN KEY (trackId) REFERENCES tracks(id) ON DELETE CASCADE
);
```

## Indexes

```sql
-- Performance indexes
CREATE INDEX idx_tracks_title ON tracks(title);
CREATE INDEX idx_tracks_artist ON tracks(artist);
CREATE INDEX idx_tracks_createdAt ON tracks(createdAt);
CREATE INDEX idx_tracks_workflowStatus ON tracks(workflowStatus);
CREATE INDEX idx_action_history_trackId ON action_history(trackId);
CREATE INDEX idx_action_history_timestamp ON action_history(timestamp);
```

## Firestore Structure

```
users/
  {userId}/
    email: string
    displayName: string
    role: string
    createdAt: timestamp
    tracks/
      {trackId}/
        id: number
        title: string
        artist: string
        duration: number
        filePath: string
        createdAt: timestamp
        isFavorite: boolean
        workflowStatus: string
        lastModifiedAt: timestamp
        syncedAt: timestamp
```

## Data Flow

```
User Input
    │
    ▼
UI Layer (Screens/Widgets)
    │
    ▼
State Management (Riverpod Providers)
    │
    ▼
Repository Layer
    │
    ├──▶ Local Database (SQLite)
    │         │
    │         └──▶ Sync Service
    │                   │
    └──▶ Cloud Database (Firestore)
                │
                └──▶ Sync Service
```

## Relationships

1. **User to Tracks**: One-to-Many
   - One user can have many tracks
   - Tracks are stored per user in Firestore

2. **Track to Action History**: One-to-Many
   - One track can have many action history entries
   - Cascade delete: deleting track deletes its history

3. **Workflow States**: State Machine
   - Tracks transition through workflow states
   - Transitions are tracked in action history

## Data Synchronization

### Local → Cloud
- Tracks are synced to Firestore under `users/{userId}/tracks/{trackId}`
- Sync happens automatically when online
- Manual sync available via UI

### Cloud → Local
- Cloud data is downloaded to local SQLite
- Conflict resolution strategies available
- Offline-first approach

## Constraints

1. **Email uniqueness**: Users must have unique emails
2. **Track ownership**: Tracks belong to specific users
3. **Workflow transitions**: Only valid transitions allowed
4. **Cascade delete**: Deleting track deletes its action history

## Data Validation

- Title: Required, non-empty
- Artist: Required, non-empty
- Duration: Required, positive integer
- FilePath: Required, non-empty
- Email: Required, valid email format
- WorkflowStatus: Must be valid enum value
