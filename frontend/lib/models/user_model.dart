class UserModel {
  final String id, email, matkhau, hoten, hinhanh;
  const UserModel({
    this.id = '',
    required this.email,
    required this.matkhau,
    required this.hoten,
    this.hinhanh = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'] as String,
    email: json['email'] as String,
    matkhau: json['matkhau'] as String,
    hoten: json['hoten'] as String,
    hinhanh: json['hinhanh'] as String? ?? '',
  );
  Map<String, String> toJson() => {
    'email': email,
    'matkhau': matkhau,
    'hoten': hoten,
    'hinhanh': hinhanh,
  };
}
