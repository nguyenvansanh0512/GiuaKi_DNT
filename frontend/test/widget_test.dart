import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_admin/app.dart';

void main() {
  for (final size in [const Size(360, 800), const Size(1440, 900)]) {
    testWidgets('Login responsive ${size.width}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const AdminApp());
      await tester.pumpAndSettle();
      expect(find.text('Đăng nhập'), findsOneWidget);
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();
      expect(find.text('Nhập email hợp lệ.'), findsOneWidget);
      expect(find.text('Nhập mật khẩu Admin.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.byTooltip('Hiện mật khẩu'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Ẩn mật khẩu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
