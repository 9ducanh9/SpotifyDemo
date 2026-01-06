/// Các hàm validation cho form inputs
class Validators {
  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }

  /// Validate email hoặc username (linh hoạt)
  static String? emailOrUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email hoặc tên đăng nhập không được để trống';
    }
    
    // Nếu có @ thì phải là email hợp lệ
    if (value.contains('@')) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      
      if (!emailRegex.hasMatch(value)) {
        return 'Email không hợp lệ';
      }
    } else {
      // Nếu không có @, coi như username (ít nhất 3 ký tự)
      if (value.trim().length < 3) {
        return 'Tên đăng nhập phải có ít nhất 3 ký tự';
      }
    }
    
    return null;
  }

  /// Validate mật khẩu
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    
    return null;
  }

  /// Validate trường bắt buộc
  static String? required(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Validate tên hiển thị
  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên hiển thị không được để trống';
    }
    
    if (value.trim().length < 2) {
      return 'Tên hiển thị phải có ít nhất 2 ký tự';
    }
    
    return null;
  }

  /// Validate xác nhận mật khẩu
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    
    return null;
  }

  /// Validate từ khóa tìm kiếm
  static String? searchQuery(String? value) {
    // Search can be empty, but if provided, check length
    if (value != null && value.trim().length > 100) {
      return 'Từ khóa tìm kiếm quá dài';
    }
    return null;
  }

  /// Validate tên bài hát
  static String? trackTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên bài hát không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Tên bài hát phải có ít nhất 2 ký tự';
    }
    if (value.trim().length > 200) {
      return 'Tên bài hát không được vượt quá 200 ký tự';
    }
    return null;
  }

  /// Validate thời lượng bài hát
  static String? trackDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Thời lượng không được để trống';
    }
    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Thời lượng phải là số';
    }
    if (duration <= 0) {
      return 'Thời lượng phải lớn hơn 0';
    }
    if (duration > 3600) {
      return 'Thời lượng không được vượt quá 1 giờ';
    }
    return null;
  }

  /// Validate URL hoặc đường dẫn file của bài hát
  static String? trackFileUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL file không được để trống';
    }
    // Check if it's a valid URL or file path
    final urlPattern = RegExp(
      r'^(https?:\/\/|file:\/\/|\/).*',
      caseSensitive: false,
    );
    if (!urlPattern.hasMatch(value.trim())) {
      return 'URL hoặc đường dẫn file không hợp lệ';
    }
    return null;
  }

  /// Validate tên nghệ sĩ
  static String? artistName(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length > 100) {
        return 'Tên nghệ sĩ không được vượt quá 100 ký tự';
      }
    }
    return null;
  }

  /// Validate thể loại
  static String? genre(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length > 50) {
        return 'Thể loại không được vượt quá 50 ký tự';
      }
    }
    return null;
  }
}

