import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/track.dart';
import '../utils/constants.dart';

/// Service quản lý database SQLite local
class LocalDatabaseService {
  static Database? _database;

  /// Lấy instance database (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Khởi tạo database và tạo các bảng
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tracks (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        duration INTEGER NOT NULL,
        file_url TEXT NOT NULL,
        album_id INTEGER,
        play_count INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        artist TEXT,
        genre TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Create favorites table
    await db.execute('''
      CREATE TABLE favorites (
        track_id INTEGER PRIMARY KEY,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (track_id) REFERENCES tracks (id) ON DELETE CASCADE
      )
    ''');

    // Create play_history table
    await db.execute('''
      CREATE TABLE play_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        track_id INTEGER NOT NULL,
        played_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (track_id) REFERENCES tracks (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_tracks_title ON tracks(title)');
    await db.execute('CREATE INDEX idx_tracks_play_count ON tracks(play_count)');
    await db.execute('CREATE INDEX idx_play_history_track_id ON play_history(track_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
  }

  /// Lấy tất cả tracks từ database với tùy chọn tìm kiếm, sắp xếp, lọc theo genre
  Future<List<Track>> getAllTracks({
    String? search,
    String? sortBy,
    String? genre,
  }) async {
    final db = await database;
    String query = 'SELECT * FROM tracks';

    final whereConditions = <String>[];
    final whereArgs = <dynamic>[];

    if (search != null && search.isNotEmpty) {
      whereConditions.add('(title LIKE ? OR artist LIKE ?)');
      whereArgs.add('%$search%');
      whereArgs.add('%$search%');
    }

    if (genre != null && genre.isNotEmpty) {
      whereConditions.add('genre = ?');
      whereArgs.add(genre);
    }

    if (whereConditions.isNotEmpty) {
      query += ' WHERE ${whereConditions.join(' AND ')}';
    }

    // Sort
    final sortField = sortBy ?? 'title';
    query += ' ORDER BY $sortField ASC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Track.fromMap({
        'id': map['id'],
        'title': map['title'],
        'duration': map['duration'],
        'file_url': map['file_url'],
        'album_id': map['album_id'],
        'play_count': map['play_count'] ?? 0,
        'created_at': map['created_at'],
        'updated_at': map['updated_at'],
        'artist': map['artist'],
        'genre': map['genre'],
        'is_favorite': (map['is_favorite'] ?? 0) == 1,
      });
    });
  }

  /// Thêm một track mới vào database
  Future<void> insertTrack(Track track) async {
    final db = await database;
    await db.insert(
      'tracks',
      {
        if (track.id != null) 'id': track.id,
        'title': track.title,
        'duration': track.duration,
        'file_url': track.fileUrl,
        'album_id': track.albumId,
        'play_count': track.playCount,
        'created_at': track.createdAt?.toIso8601String(),
        'updated_at': track.updatedAt?.toIso8601String(),
        'artist': track.artist,
        'genre': track.genre,
        'is_favorite': track.isFavorite ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Thêm nhiều tracks vào database cùng lúc (batch insert)
  Future<void> insertTracksBatch(List<Track> tracks) async {
    final db = await database;
    final batch = db.batch();
    
    for (final track in tracks) {
      batch.insert(
        'tracks',
        {
          if (track.id != null) 'id': track.id,
          'title': track.title,
          'duration': track.duration,
          'file_url': track.fileUrl,
          'album_id': track.albumId,
          'play_count': track.playCount,
          'created_at': track.createdAt?.toIso8601String(),
          'updated_at': track.updatedAt?.toIso8601String(),
          'artist': track.artist,
          'genre': track.genre,
          'is_favorite': track.isFavorite ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  /// Cập nhật thông tin track trong database
  Future<void> updateTrack(Track track) async {
    final db = await database;
    await db.update(
      'tracks',
      {
        'title': track.title,
        'duration': track.duration,
        'file_url': track.fileUrl,
        'album_id': track.albumId,
        'play_count': track.playCount,
        'updated_at': DateTime.now().toIso8601String(),
        'artist': track.artist,
        'genre': track.genre,
        'is_favorite': track.isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  /// Xóa track khỏi database
  Future<void> deleteTrack(int id) async {
    final db = await database;
    await db.delete(
      'tracks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Tăng số lần phát của track
  Future<void> incrementPlayCount(int trackId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE tracks SET play_count = play_count + 1 WHERE id = ?',
      [trackId],
    );
  }

  /// Lấy danh sách tracks yêu thích
  Future<List<Track>> getFavoriteTracks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM tracks t
      INNER JOIN favorites f ON t.id = f.track_id
      ORDER BY f.added_at DESC
    ''');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Track.fromMap({
        'id': map['id'],
        'title': map['title'],
        'duration': map['duration'],
        'file_url': map['file_url'],
        'album_id': map['album_id'],
        'play_count': map['play_count'] ?? 0,
        'created_at': map['created_at'],
        'updated_at': map['updated_at'],
        'artist': map['artist'],
        'genre': map['genre'],
        'is_favorite': true,
      });
    });
  }

  /// Thêm track vào danh sách yêu thích
  Future<void> addToFavorites(int trackId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'track_id': trackId,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update is_favorite in tracks table
    await db.update(
      'tracks',
      {'is_favorite': 1},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  /// Xóa track khỏi danh sách yêu thích
  Future<void> removeFromFavorites(int trackId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'track_id = ?',
      whereArgs: [trackId],
    );

    // Update is_favorite in tracks table
    await db.update(
      'tracks',
      {'is_favorite': 0},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  /// Thêm track vào lịch sử phát
  Future<void> addPlayHistory(int trackId) async {
    final db = await database;
    await db.insert(
      'play_history',
      {
        'track_id': trackId,
        'played_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Lấy lịch sử phát nhạc (giới hạn số lượng)
  Future<List<Map<String, dynamic>>> getPlayHistory({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, ph.played_at 
      FROM play_history ph
      INNER JOIN tracks t ON ph.track_id = t.id
      ORDER BY ph.played_at DESC
      LIMIT ?
    ''', [limit]);

    return maps;
  }
}

