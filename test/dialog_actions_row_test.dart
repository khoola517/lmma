import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/dialog_actions_row.dart';

void main() {
  testWidgets('DialogActionsRow keeps AlertDialog buttons side by side',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AlertDialog(
              content: const Text('تأكيد العملية'),
              actions: [
                DialogActionsRow(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('إلغاء'),
                    ),
                    CustomButton(
                      text: 'تأكيد التنفيذ',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final cancelRect = tester.getRect(find.text('إلغاء'));
    final confirmRect = tester.getRect(find.text('تأكيد التنفيذ'));

    // Both buttons must be aligned on the same horizontal row, not stacked.
    expect((cancelRect.center.dy - confirmRect.center.dy).abs(), lessThan(4.0));
    expect((cancelRect.center.dx - confirmRect.center.dx).abs(), greaterThan(20.0));
    expect(tester.takeException(), isNull);
  });
}

