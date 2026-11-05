import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khadematy_web/main.dart';

void main() {
  testWidgets('KhadematyProviderApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const KhadematyProviderApp());
    await tester.pumpAndSettle();

    expect(find.text('خِدمتي'), findsWidgets);
    expect(find.text('بوابة شركاء النجاح'), findsWidgets);
  });
}
