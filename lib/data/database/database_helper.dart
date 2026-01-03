import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../models/music_track_model.dart';
import '../models/user_model.dart';
import '../models/action_history.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create tracks table
    await db.execute('''
      CREATE TABLE ${AppConstants.tracksTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        duration INTEGER NOT NULL,
        filePath TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        workflowStatus TEXT NOT NULL DEFAULT 'draft',
        lastModifiedAt TEXT
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL DEFAULT 'regular'
      )
    ''');

    // Create action history table
    await db.execute('''
      CREATE TABLE ${AppConstants.actionHistoryTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trackId INTEGER NOT NULL,
        action TEXT NOT NULL,
        performedBy TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        metadata TEXT,
        comment TEXT,
        FOREIGN KEY (trackId) REFERENCES ${AppConstants.tracksTable}(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_tracks_title ON ${AppConstants.tracksTable}(title)
    ''');
    await db.execute('''
      CREATE INDEX idx_tracks_artist ON ${AppConstants.tracksTable}(artist)
    ''');
    await db.execute('''
      CREATE INDEX idx_tracks_createdAt ON ${AppConstants.tracksTable}(createdAt)
    ''');
    await db.execute('''
      CREATE INDEX idx_tracks_workflowStatus ON ${AppConstants.tracksTable}(workflowStatus)
    ''');
    await db.execute('''
      CREATE INDEX idx_action_history_trackId ON ${AppConstants.actionHistoryTable}(trackId)
    ''');
    await db.execute('''
      CREATE INDEX idx_action_history_timestamp ON ${AppConstants.actionHistoryTable}(timestamp)
    ''');
  }

  /// Upgrade database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add workflow status and action history
      try {
        await db.execute('''
          ALTER TABLE ${AppConstants.tracksTable} 
          ADD COLUMN workflowStatus TEXT NOT NULL DEFAULT 'draft'
        ''');
      } catch (e) {
        // Column might already exist
      }
      try {
        await db.execute('''
          ALTER TABLE ${AppConstants.tracksTable} 
          ADD COLUMN lastModifiedAt TEXT
        ''');
      } catch (e) {
        // Column might already exist
      }
      try {
        await db.execute('''
          CREATE TABLE ${AppConstants.actionHistoryTable} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trackId INTEGER NOT NULL,
            action TEXT NOT NULL,
            performedBy TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            metadata TEXT,
            comment TEXT,
            FOREIGN KEY (trackId) REFERENCES ${AppConstants.tracksTable}(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_tracks_workflowStatus ON ${AppConstants.tracksTable}(workflowStatus)
        ''');
        await db.execute('''
          CREATE INDEX idx_action_history_trackId ON ${AppConstants.actionHistoryTable}(trackId)
        ''');
        await db.execute('''
          CREATE INDEX idx_action_history_timestamp ON ${AppConstants.actionHistoryTable}(timestamp)
        ''');
      } catch (e) {
        // Table might already exist
      }
    }
  }

  // ========== TRACKS OPERATIONS ==========

  /// Insert a new track
  Future<int> insertTrack(MusicTrack track) async {
    final db = await database;
    return await db.insert(
      AppConstants.tracksTable,
      track.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all tracks
  Future<List<MusicTrack>> getAllTracks() async {
    final db = await database;
    final result = await db.query(
      AppConstants.tracksTable,
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => MusicTrack.fromMap(map)).toList();
  }

  /// Get track by ID
  Future<MusicTrack?> getTrackById(int id) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tracksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return MusicTrack.fromMap(result.first);
  }

  /// Search tracks by title or artist
  Future<List<MusicTrack>> searchTracks(String query) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tracksTable,
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
      limit: AppConstants.maxSearchResults,
    );
    return result.map((map) => MusicTrack.fromMap(map)).toList();
  }

  /// Get tracks filtered by favorite status
  Future<List<MusicTrack>> getFavoriteTracks() async {
    final db = await database;
    final result = await db.query(
      AppConstants.tracksTable,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => MusicTrack.fromMap(map)).toList();
  }

  /// Get tracks by workflow status
  Future<List<MusicTrack>> getTracksByWorkflowStatus(String status) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tracksTable,
      where: 'workflowStatus = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => MusicTrack.fromMap(map)).toList();
  }

  /// Get tracks sorted by a field
  Future<List<MusicTrack>> getTracksSortedBy(String field, {bool ascending = true}) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tracksTable,
      orderBy: '$field ${ascending ? 'ASC' : 'DESC'}',
    );
    return result.map((map) => MusicTrack.fromMap(map)).toList();
  }

  /// Update a track
  Future<int> updateTrack(MusicTrack track) async {
    final db = await database;
    return await db.update(
      AppConstants.tracksTable,
      track.copyWith(lastModifiedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  /// Update workflow status
  Future<int> updateWorkflowStatus(int trackId, String status) async {
    final db = await database;
    return await db.update(
      AppConstants.tracksTable,
      {
        'workflowStatus': status,
        'lastModifiedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  /// Toggle favorite status
  Future<int> toggleFavorite(int trackId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      AppConstants.tracksTable,
      {
        'isFavorite': isFavorite ? 1 : 0,
        'lastModifiedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  /// Delete a track
  Future<int> deleteTrack(int id) async {
    final db = await database;
    // Delete action history first (cascade should handle this, but being explicit)
    await db.delete(
      AppConstants.actionHistoryTable,
      where: 'trackId = ?',
      whereArgs: [id],
    );
    return await db.delete(
      AppConstants.tracksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all tracks
  Future<int> deleteAllTracks() async {
    final db = await database;
    await db.delete(AppConstants.actionHistoryTable);
    return await db.delete(AppConstants.tracksTable);
  }

  // ========== ACTION HISTORY OPERATIONS ==========

  /// Insert action history
  Future<int> insertActionHistory(ActionHistory history) async {
    final db = await database;
    return await db.insert(
      AppConstants.actionHistoryTable,
      history.toMap(),
    );
  }

  /// Get action history for a track
  Future<List<ActionHistory>> getActionHistory(int trackId) async {
    final db = await database;
    final result = await db.query(
      AppConstants.actionHistoryTable,
      where: 'trackId = ?',
      whereArgs: [trackId],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ActionHistory.fromMap(map)).toList();
  }

  /// Get all action history
  Future<List<ActionHistory>> getAllActionHistory() async {
    final db = await database;
    final result = await db.query(
      AppConstants.actionHistoryTable,
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ActionHistory.fromMap(map)).toList();
  }

  // ========== USERS OPERATIONS ==========

  /// Insert a new user
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      AppConstants.usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      AppConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      AppConstants.usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
