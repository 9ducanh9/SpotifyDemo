import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/token_debug.dart';

class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends ConsumerState<UsersManagementScreen> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  UserRole? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tokenInfo = await TokenDebug.checkToken();
      print('🔍 [Users Management] Token Debug:');
      print('  - Has Token: ${tokenInfo['hasToken']}');
      print('  - Role: ${tokenInfo['role']}');
      print('  - Is Admin: ${tokenInfo['isAdmin']}');
      
      final users = await _apiService.getAllUsers();
      print('✅ [Users Management] Successfully loaded ${users.length} users');
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
      _filterUsers();
    } catch (e) {
      final tokenInfo = await TokenDebug.checkToken();
      print('❌ [Users Management] Error loading users: $e');
      print('🔍 Token Debug on Error:');
      print('  - Has Token: ${tokenInfo['hasToken']}');
      print('  - Role: ${tokenInfo['role']}');
      print('  - Is Admin: ${tokenInfo['isAdmin']}');
      
      setState(() {
        _error = 'Lỗi khi tải danh sách users: $e';
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = query.isEmpty ||
            user.email.toLowerCase().contains(query) ||
            user.displayName.toLowerCase().contains(query);
        final matchesRole = _selectedRoleFilter == null ||
            user.role == _selectedRoleFilter;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.creator:
        return Colors.blue;
      case UserRole.approver:
        return Colors.orange;
      case UserRole.follower:
        return Colors.purple;
      case UserRole.user:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.creator:
        return Icons.create;
      case UserRole.approver:
        return Icons.check_circle;
      case UserRole.follower:
        return Icons.people;
      case UserRole.user:
        return Icons.person;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa có';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor(user.role),
              child: Icon(
                _getRoleIcon(user.role),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      user.role.value,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: _getRoleColor(user.role),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(Icons.email, 'Email', user.email),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person, 'Tên hiển thị', user.displayName),
              const SizedBox(height: 12),
              _buildDetailRow(
                _getRoleIcon(user.role),
                'Vai trò',
                user.role.value,
                color: _getRoleColor(user.role),
              ),
              if (user.createdAt != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Ngày tạo',
                  _formatDate(user.createdAt),
                ),
              ],
              if (user.lastLoginAt != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time,
                  'Đăng nhập lần cuối',
                  _formatDate(user.lastLoginAt),
                ),
              ],
              if (user.avatarUrl != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.image, 'Avatar URL', user.avatarUrl!),
              ],
              if (user.id != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.tag, 'ID', user.id.toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo email hoặc tên...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                // Role Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tất cả'),
                        selected: _selectedRoleFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRoleFilter = null;
                            _filterUsers();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...UserRole.values.map((role) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              avatar: Icon(
                                _getRoleIcon(role),
                                size: 18,
                                color: _selectedRoleFilter == role
                                    ? Colors.white
                                    : _getRoleColor(role),
                              ),
                              label: Text(role.value),
                              selected: _selectedRoleFilter == role,
                              selectedColor: _getRoleColor(role),
                              labelStyle: TextStyle(
                                color: _selectedRoleFilter == role
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRoleFilter = selected ? role : null;
                                  _filterUsers();
                                });
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Statistics Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Tổng', _users.length, Colors.blue),
                _buildStatItem('Admin', _users.where((u) => u.role == UserRole.admin).length, Colors.red),
                _buildStatItem('User', _users.where((u) => u.role == UserRole.user).length, Colors.grey),
                _buildStatItem('Creator', _users.where((u) => u.role == UserRole.creator).length, Colors.blue),
              ],
            ),
          ),
          // Users List
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade700),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  _users.isEmpty
                                      ? 'Chưa có user nào'
                                      : 'Không tìm thấy user nào',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              itemCount: _filteredUsers.length,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getRoleColor(user.role),
                                      child: Icon(
                                        _getRoleIcon(user.role),
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      user.displayName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(user.email),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(
                                                user.role.value,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor: _getRoleColor(user.role),
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            if (user.lastLoginAt != null) ...[
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDate(user.lastLoginAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => _showUserDetails(user),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
