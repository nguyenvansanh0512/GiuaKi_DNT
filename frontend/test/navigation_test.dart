import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:midterm_admin/app.dart';
import 'package:midterm_admin/providers/auth_provider.dart';
import 'package:midterm_admin/services/api_service.dart';
import 'package:midterm_admin/services/auth_service.dart';
import 'package:midterm_admin/services/user_service.dart';

void main() {
  testWidgets('System Back trở về danh sách; logout đóng form bảo vệ', (
    tester,
  ) async {
    final api = ApiService(
      baseUrl: 'http://test',
      client: MockClient(
        (_) async => http.Response('{"users":[],"total":0}', 200),
      ),
    );
    api.token = 'test-only';
    final auth = AuthProvider(AuthService(api));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<UserService>.value(value: UserService(api)),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm người dùng'));
    await tester.pumpAndSettle();
    expect(find.text('Lưu người dùng'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Lưu người dùng'), findsNothing);
    expect(find.text('Người dùng'), findsOneWidget);
    await tester.tap(find.text('Thêm người dùng'));
    await tester.pumpAndSettle();
    auth.logout();
    await tester.pumpAndSettle();
    expect(find.text('Lưu người dùng'), findsNothing);
    expect(find.text('Đăng nhập'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
    api.dispose();
  });
}
