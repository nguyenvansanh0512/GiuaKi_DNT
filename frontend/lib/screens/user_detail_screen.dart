import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/user_avatar.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});
  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late Future<UserModel> _future;
  bool _hidden = true;
  @override
  void initState() {
    super.initState();
    _future = context.read<UserService>().get(widget.userId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chi tiết người dùng')),
    body: FutureBuilder<UserModel>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('${snapshot.error}'),
                ),
                FilledButton(
                  onPressed: () => setState(
                    () => _future = context.read<UserService>().get(
                      widget.userId,
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        final user = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: UserAvatar(
                          image: user.hinhanh,
                          name: user.hoten,
                          radius: 70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        user.hoten,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Email',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      SelectableText(user.email),
                      const SizedBox(height: 20),
                      const Text(
                        'Mật khẩu demo',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              _hidden ? '••••••••' : user.matkhau,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hiện/ẩn mật khẩu demo',
                            onPressed: () => setState(() => _hidden = !_hidden),
                            icon: Icon(
                              _hidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.hinhanh.isEmpty
                            ? 'Chưa có hình ảnh.'
                            : 'Hình ảnh được tải từ bản ghi người dùng.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
