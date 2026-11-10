import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _password = TextEditingController();
  bool _hidden = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (_form.currentState!.validate()) {
      context.read<AuthProvider>().login(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 900;
          final form = Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 44,
                        color: Color(0xff176c64),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Chào mừng trở lại',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Đăng nhập Admin để quản lý người dùng.',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _email,
                        enabled: !auth.loading,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Email Admin',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _password,
                        enabled: !auth.loading,
                        obscureText: _hidden,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Nhập mật khẩu Admin.'
                            : null,
                        onFieldSubmitted: (_) {
                          if (!auth.loading) _login();
                        },
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _hidden ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                            onPressed: () => setState(() => _hidden = !_hidden),
                            icon: Icon(
                              _hidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      if (auth.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            auth.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: auth.loading ? null : _login,
                          child: auth.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Đồ án giữa kỳ • Lập trình đa nền tảng\nChỉ sử dụng thông tin và mật khẩu minh họa.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          return Row(
            children: [
              if (wide)
                Expanded(
                  child: Container(
                    color: const Color(0xff123c3b),
                    padding: const EdgeInsets.all(60),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          color: Color(0xff9cddc5),
                          size: 54,
                        ),
                        SizedBox(height: 32),
                        Text(
                          'AdminSpace',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Quản lý gọn gàng.\nKết nối mọi nền tảng.',
                          style: TextStyle(
                            color: Color(0xffc3ddd7),
                            fontSize: 26,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 48),
                        Text(
                          'FLUTTER  /  EXPRESS  /  MONGODB',
                          style: TextStyle(
                            color: Color(0xff9cddc5),
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(child: form),
            ],
          );
        },
      ),
    );
  }
}
