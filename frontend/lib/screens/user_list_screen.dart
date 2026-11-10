import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../widgets/user_avatar.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  int _generation = 0, _total = 0;
  List<UserModel> _users = [];
  bool _loading = true, _showPasswords = false;
  String? _error, _deleting;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await context.read<UserService>().list(_search.text.trim());
      if (mounted && generation == _generation) {
        setState(() {
          _users = page.users;
          _total = page.total;
        });
      }
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _changed(String _) {
    _debounce?.cancel();
    // Vô hiệu hóa kết quả request cũ ngay khi từ khóa thay đổi.
    _generation++;
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _form([UserModel? user]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user == null ? const AddUserScreen() : EditUserScreen(user: user),
      ),
    );
    if (result == true && mounted) {
      _message(
        user == null ? 'Đã thêm người dùng.' : 'Đã cập nhật người dùng.',
      );
      await _load();
    }
  }

  Future<void> _delete(UserModel user) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa người dùng?'),
        content: Text(
          'Bạn muốn xóa ${user.hoten}\n(${user.email})? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() => _deleting = user.id);
    try {
      await context.read<UserService>().delete(user.id);
      if (mounted) {
        _message('Đã xóa người dùng.');
        await _load();
      }
    } catch (e) {
      if (mounted) _message(e.toString());
    } finally {
      if (mounted) setState(() => _deleting = null);
    }
  }

  Widget _actions(UserModel user) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Chi tiết',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailScreen(userId: user.id)),
        ),
        icon: const Icon(Icons.open_in_new, size: 20),
      ),
      IconButton(
        tooltip: 'Sửa',
        onPressed: _deleting != null ? null : () => _form(user),
        icon: const Icon(Icons.edit_outlined, size: 20),
      ),
      IconButton(
        tooltip: 'Xóa',
        onPressed: _deleting != null ? null : () => _delete(user),
        icon: _deleting == user.id
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.delete_outline,
                size: 20,
                color: Color(0xffb54444),
              ),
      ),
    ],
  );
  Widget _cell(String text, {double width = 180}) => SizedBox(
    width: width,
    child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
  );
  Widget _data(bool wide) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(72),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.people_outline, size: 54, color: Colors.blueGrey),
            const SizedBox(height: 16),
            Text(
              _search.text.trim().isEmpty
                  ? 'Chưa có người dùng nào'
                  : 'Không tìm thấy người dùng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const Text(
              'Thêm người dùng mới hoặc thay đổi từ khóa tìm kiếm.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (!wide) {
      return Column(
        children: _users
            .map(
              (user) => Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffedf0f2))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(image: user.hinhanh, name: user.hoten),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.hoten,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(user.email),
                    const SizedBox(height: 8),
                    Text(
                      'Mật khẩu: ${_showPasswords ? user.matkhau : '••••••••'}',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _actions(user),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            headingRowColor: const WidgetStatePropertyAll(Color(0xfff7f9fa)),
            dataRowMinHeight: 76,
            dataRowMaxHeight: 86,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Mật khẩu')),
              DataColumn(label: Text('Họ tên')),
              DataColumn(label: Text('Hình ảnh')),
              DataColumn(label: Text('Thao tác')),
            ],
            rows: _users
                .map(
                  (user) => DataRow(
                    cells: [
                      DataCell(_cell(user.email, width: 220)),
                      DataCell(
                        _cell(
                          _showPasswords ? user.matkhau : '••••••••',
                          width: 130,
                        ),
                      ),
                      DataCell(_cell(user.hoten)),
                      DataCell(
                        UserAvatar(image: user.hinhanh, name: user.hoten),
                      ),
                      DataCell(_actions(user)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_view_rounded, color: Color(0xff176c64)),
          SizedBox(width: 12),
          Text('AdminSpace', style: TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Đăng xuất',
          onPressed: () => context.read<AuthProvider>().logout(),
          icon: const Icon(Icons.logout),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.all(constraints.maxWidth > 700 ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'KHÔNG GIAN QUẢN TRỊ',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: Color(0xff176c64),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Người dùng',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Thêm, xem và cập nhật thông tin tại một nơi.',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: () => _form(),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm người dùng'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Card(
                  color: const Color(0xffe4f1eb),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 32,
                          color: Color(0xff176c64),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_total',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text('Tổng số người dùng'),
                            ],
                          ),
                        ),
                        const Text(
                          'Web & Android',
                          style: TextStyle(color: Color(0xff176c64)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth > 700
                                  ? 370
                                  : constraints.maxWidth - 72,
                              child: Semantics(
                                container: true,
                                child: TextField(
                                  controller: _search,
                                  maxLength: 100,
                                  onChanged: _changed,
                                  decoration: InputDecoration(
                                    hintText: 'Tìm email hoặc họ tên…',
                                    counterText: '',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: IconButton(
                                      tooltip: 'Xóa tìm kiếm',
                                      onPressed: () {
                                        _search.clear();
                                        _debounce?.cancel();
                                        _load();
                                      },
                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Làm mới',
                              onPressed: _loading ? null : _load,
                              icon: const Icon(Icons.refresh),
                            ),
                            FilterChip(
                              label: const Text('Hiện mật khẩu demo'),
                              selected: _showPasswords,
                              onSelected: (value) =>
                                  setState(() => _showPasswords = value),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      _data(constraints.maxWidth >= 850),
                      if (!_loading && _error == null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Hiển thị ${_users.length} / $_total người dùng',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đồ án giữa kỳ • Dữ liệu người dùng chỉ gồm email, matkhau, hoten, hinhanh.\nMật khẩu dạng rõ chỉ phục vụ minh họa bài thi.',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
