import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/image_tools.dart';
import '../utils/validators.dart';
import '../widgets/user_avatar.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  const UserFormScreen({super.key, this.user});
  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email, _password, _name;
  final _picker = ImagePicker();
  late String _image;
  String? _error;
  bool _saving = false, _picking = false, _hidden = true;
  bool get _busy => _saving || _picking;
  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.user?.email);
    _password = TextEditingController(text: widget.user?.matkhau);
    _name = TextEditingController(text: widget.user?.hoten);
    _image = widget.user?.hinhanh ?? '';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) _recover();
  }

  Future<void> _recover() async {
    try {
      final lost = await _picker.retrieveLostData();
      if (!mounted) return;
      if (lost.files?.isNotEmpty ?? false) {
        setState(() => _picking = true);
        final value = await ImageTools.prepare(lost.files!.first);
        if (mounted) setState(() => _image = value);
      } else if (lost.exception != null) {
        setState(
          () => _error = 'Không khôi phục được ảnh đã chọn. Hãy chọn lại.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Không đọc được ảnh đã chọn trước đó.');
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final value = await ImageTools.prepare(file);
        if (mounted) setState(() => _image = value);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Không chọn được ảnh: $e');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<UserService>().save(
        UserModel(
          id: widget.user?.id ?? '',
          email: _email.text.trim(),
          matkhau: _password.text,
          hoten: _name.text.trim(),
          hinhanh: _image,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Thêm người dùng' : 'Sửa người dùng'),
        automaticallyImplyLeading: !_busy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Thông tin người dùng',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nhập đủ thông tin bên dưới. Chỉ dùng mật khẩu minh họa.',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: UserAvatar(
                          image: _image,
                          name: _name.text,
                          radius: 54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _busy ? null : _pick,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text(
                              _picking ? 'Đang xử lý ảnh…' : 'Chọn ảnh',
                            ),
                          ),
                          if (_image.isNotEmpty)
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => setState(() => _image = ''),
                              child: const Text('Bỏ ảnh'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'JPG / PNG • ảnh gốc ≤ 8 MB, ≤ 16 MP\nTự thu nhỏ tối đa 800 px; ảnh lưu ≤ 512 KB.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        enabled: !_busy,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 254,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _password,
                        enabled: !_busy,
                        validator: Validators.password,
                        obscureText: _hidden,
                        maxLength: 128,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu demo',
                          counterText: '',
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
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _name,
                        enabled: !_busy,
                        validator: Validators.name,
                        maxLength: 100,
                        onChanged: (_) {
                          if (_image.isEmpty) setState(() {});
                        },
                        decoration: const InputDecoration(labelText: 'Họ tên'),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          FilledButton.icon(
                            onPressed: _busy ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              _saving ? 'Đang lưu…' : 'Lưu người dùng',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
