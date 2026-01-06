import 'dart:io';

/// Model đại diện cho một bản ghi âm
class Recording {
  final String filePath;
  final String name;
  final DateTime createdAt;
  final int? fileSize;

  Recording({
    required this.filePath,
    required this.name,
    required this.createdAt,
    this.fileSize,
  });

  /// Lấy tên hiển thị (bỏ prefix 'recording_' và timestamp nếu có)
  String get displayName {
    if (name.startsWith('recording_')) {
      return name.replaceFirst('recording_', '').replaceAll(RegExp(r'_\d+\.m4a$'), '.m4a');
    }
    return name;
  }

  /// Định dạng kích thước file thành chuỗi dễ đọc (B, KB, MB)
  String get formattedSize {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Định dạng ngày tạo thành chuỗi DD/MM/YYYY HH:mm
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Kiểm tra file recording có tồn tại trên hệ thống không
  bool exists() {
    final file = File(filePath);
    return file.existsSync();
  }
}




