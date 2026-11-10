import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:midterm_admin/models/user_model.dart';
import 'package:midterm_admin/services/api_service.dart';
import 'package:midterm_admin/services/auth_service.dart';
import 'package:midterm_admin/services/user_service.dart';
import 'package:midterm_admin/utils/image_tools.dart';
import 'package:midterm_admin/utils/validators.dart';

void main() {
  const user = UserModel(
    id: 'abc',
    email: 'an@example.com',
    matkhau: '123456',
    hoten: 'Nguyễn An',
  );
  test('Model gửi đúng bốn trường, không gửi id', () {
    expect(user.toJson().keys.toSet(), {
      'email',
      'matkhau',
      'hoten',
      'hinhanh',
    });
    expect(
      UserModel.fromJson({'_id': 'abc', ...user.toJson()}).hoten,
      user.hoten,
    );
  });
  test('Validation tương ứng backend', () {
    expect(Validators.email('bad'), isNotNull);
    expect(Validators.email('an@example.com'), isNull);
    expect(Validators.password('123'), isNotNull);
    expect(Validators.name('   '), isNotNull);
  });
  test('Ảnh PNG được nén thành JPEG, thu nhỏ và giữ giới hạn', () {
    final bytes = img.encodePng(img.Image(width: 1200, height: 400));
    final uri = compressImage(bytes);
    expect(uri.startsWith('data:image/jpeg;base64,'), isTrue);
    final compressed = base64Decode(uri.split(',').last);
    expect(compressed.length, lessThanOrEqualTo(512 * 1024));
    final image = img.decodeJpg(compressed)!;
    expect(image.width, 800);
    expect(image.height, 267);
    expect(() => compressImage(Uint8List.fromList([1, 2, 3])), throwsException);
  });
  test('HTTP client: login, unicode, query, token, CRUD payload', () async {
    final seen = <http.Request>[];
    final api = ApiService(
      baseUrl: 'http://test',
      client: MockClient((req) async {
        seen.add(req);
        if (req.url.path == '/api/auth/login') {
          return http.Response('{"token":"demo"}', 200);
        }
        if (req.method == 'DELETE') return http.Response('', 204);
        if (req.method == 'GET' && req.url.path == '/api/users') {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'users': [
                  {'_id': 'abc', ...user.toJson()},
                ],
                'total': 1,
              }),
            ),
            200,
          );
        }
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'user': {'_id': 'abc', ...user.toJson()},
            }),
          ),
          200,
        );
      }),
    );
    final auth = AuthService(api), service = UserService(api);
    await auth.login('admin@example.com', 'demo');
    expect(seen.first.method, 'POST');
    expect(seen.first.url.path, '/api/auth/login');
    expect(jsonDecode(seen.first.body), {
      'email': 'admin@example.com',
      'matkhau': 'demo',
    });
    expect(api.token, 'demo');
    final result = await service.list('Nguyễn');
    expect(result.users.single.hoten, user.hoten);
    expect(seen.last.url.queryParameters['q'], 'Nguyễn');
    expect(seen.last.headers['Authorization'], 'Bearer demo');
    await service.save(user);
    expect(seen.last.method, 'PUT');
    expect(jsonDecode(seen.last.body), user.toJson());
    await service.save(
      UserModel(email: user.email, matkhau: user.matkhau, hoten: user.hoten),
    );
    expect(seen.last.method, 'POST');
    await service.delete('abc');
    auth.logout();
    expect(api.token, isNull);
    api.dispose();
  });
  test('HTTP client: 401 hết phiên, 409 thông báo tiếng Việt', () async {
    var expired = false;
    final api = ApiService(
      baseUrl: 'http://test',
      client: MockClient(
        (_) async => http.Response('{"message":"Expired"}', 401),
      ),
    );
    api.onUnauthorized = () => expired = true;
    await expectLater(
      api.request('GET', '/api/users'),
      throwsA(isA<ApiException>()),
    );
    expect(expired, isTrue);
    api.dispose();
    final duplicate = ApiService(
      baseUrl: 'http://test',
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('{"message":"Email đã tồn tại."}'),
          409,
        ),
      ),
    );
    await expectLater(
      duplicate.request('POST', '/api/users'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Email đã tồn tại.',
        ),
      ),
    );
    duplicate.dispose();
  });
}
