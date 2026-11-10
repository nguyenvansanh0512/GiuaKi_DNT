class Validators {
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    return text.length <= 254 &&
            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)
        ? null
        : 'Nhập email hợp lệ.';
  }

  static String? password(String? value) =>
      value != null && value.length >= 6 && value.length <= 128
      ? null
      : 'Mật khẩu demo từ 6 đến 128 ký tự.';
  static String? name(String? value) =>
      value != null && value.trim().isNotEmpty && value.trim().length <= 100
      ? null
      : 'Họ tên từ 1 đến 100 ký tự.';
}
