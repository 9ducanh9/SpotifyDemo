/// Model đại diện cho một bài hát trong ứng dụng
class Track {
  final int? id;
  final String title;
  final int duration; // Thời lượng tính bằng giây
  final String fileUrl;
  final int? albumId;
  final int playCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;
  final String? artist;
  final String? genre;

  Track({
    this.id,
    required this.title,
    required this.duration,
    required this.fileUrl,
    this.albumId,
    this.playCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.artist,
    this.genre,
  });

  /// Chuyển đổi từ Map (từ database hoặc API) sang Track object
  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as int?,
      title: map['title'] as String,
      duration: map['duration'] as int,
      fileUrl: map['file_url'] as String? ?? map['fileUrl'] as String? ?? '',
      albumId: map['album_id'] as int? ?? map['albumId'] as int?,
      playCount: (map['play_count'] as int?) ?? (map['playCount'] as int?) ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : map['createdAt'] != null
              ? DateTime.parse(map['createdAt'] as String)
              : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'] as String)
              : null,
      isFavorite: (map['is_favorite'] as bool?) ?? (map['isFavorite'] as bool?) ?? false,
      artist: map['artist'] as String?,
      genre: map['genre'] as String?,
    );
  }

  /// Chuyển đổi Track object sang Map để lưu vào database hoặc gửi API
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'duration': duration,
      'file_url': fileUrl,
      if (albumId != null) 'album_id': albumId,
      'play_count': playCount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      if (artist != null) 'artist': artist,
      if (genre != null) 'genre': genre,
    };
  }

  /// Tạo bản sao Track với các thuộc tính được cập nhật (immutability pattern)
  Track copyWith({
    int? id,
    String? title,
    int? duration,
    String? fileUrl,
    int? albumId,
    int? playCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? artist,
    String? genre,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      fileUrl: fileUrl ?? this.fileUrl,
      albumId: albumId ?? this.albumId,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
    );
  }

  /// Định dạng thời lượng thành chuỗi MM:SS
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

