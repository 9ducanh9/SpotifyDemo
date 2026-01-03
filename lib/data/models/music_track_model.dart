/// Data model for a music track
class MusicTrack {
  final int? id;
  final String title;
  final String artist;
  final int duration; // Duration in seconds
  final String filePath;
  final DateTime createdAt;
  final bool isFavorite;

  MusicTrack({
    this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.filePath,
    required this.createdAt,
    this.isFavorite = false,
  });

  /// Create a copy of this track with updated fields
  MusicTrack copyWith({
    int? id,
    String? title,
    String? artist,
    int? duration,
    String? filePath,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return MusicTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  /// Create from Map (database retrieval)
  factory MusicTrack.fromMap(Map<String, dynamic> map) {
    return MusicTrack(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String,
      duration: map['duration'] as int,
      filePath: map['filePath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }

  /// Format duration as MM:SS
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'MusicTrack(id: $id, title: $title, artist: $artist, duration: $duration, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicTrack &&
        other.id == id &&
        other.title == title &&
        other.artist == artist &&
        other.duration == duration &&
        other.filePath == filePath &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        artist.hashCode ^
        duration.hashCode ^
        filePath.hashCode ^
        isFavorite.hashCode;
  }
}
