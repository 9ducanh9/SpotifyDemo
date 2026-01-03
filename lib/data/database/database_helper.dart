import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../models/music_track_model.dart';
import '../models/user_model.dart';

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
        isFavorite INTEGER NOT NULL DEFAULT 0
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
      track.toMap(),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  /// Toggle favorite status
  Future<int> toggleFavorite(int trackId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      AppConstants.tracksTable,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  /// Delete a track
  Future<int> deleteTrack(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tracksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all tracks
  Future<int> deleteAllTracks() async {
    final db = await database;
    return await db.delete(AppConstants.tracksTable);
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
