import 'dart:convert';
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
  testWidgets('Login sai giữ form; login đúng chuyển quản lý và gửi Bearer', (
    tester,
  ) async {
    var loginCalls = 0;
    var authenticatedListRequested = false;
    final api = ApiService(
      baseUrl: 'http://test',
      client: MockClient((req) async {
        if (req.url.path == '/api/auth/login') {
          expect(jsonDecode(req.body).keys.toSet(), {'email', 'matkhau'});
          loginCalls++;
          if (loginCalls == 1) {
            return http.Response('{"message":"Invalid credentials"}', 401);
          }
          return http.Response(
            '{"token":"test-session-token","expiresIn":7200}',
            200,
          );
        }
        expect(req.url.path, '/api/users');
        expect(req.headers['Authorization'], 'Bearer test-session-token');
        authenticatedListRequested = true;
        return http.Response('{"users":[],"total":0}', 200);
      }),
    );
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
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'qa-admin@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'test-only-input');
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(auth.authenticated, isFalse);
    expect(authenticatedListRequested, isFalse);
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Người dùng'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsNothing);
    expect(auth.authenticated, isTrue);
    expect(authenticatedListRequested, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
    api.dispose();
  });
}
