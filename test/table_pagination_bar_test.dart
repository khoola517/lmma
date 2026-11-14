import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khadematy_web/core/widgets/table_pagination_bar.dart';

void main() {
  test('PaginationSlice slices 5 items per page and clamps safePage', () {
    final items = List<int>.generate(12, (i) => i + 1);

    final page1 = PaginationSlice.fromList(items, currentPage: 1);
    expect(page1.pageItems, [1, 2, 3, 4, 5]);
    expect(page1.totalPages, 3);
    expect(page1.startIndex, 0);
    expect(page1.endIndex, 5);

    final page3 = PaginationSlice.fromList(items, currentPage: 99);
    expect(page3.safePage, 3);
    expect(page3.pageItems, [11, 12]);
    expect(page3.startIndex, 10);
    expect(page3.endIndex, 12);
  });

  testWidgets('TablePaginationBar renders golden active page and switches pages',
      (WidgetTester tester) async {
    int? selectedPage;
    final items = List<int>.generate(12, (i) => i + 1);
    final pagination = PaginationSlice.fromList(items, currentPage: 2);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: TablePaginationBar(
              pagination: pagination,
              itemLabel: 'مستخدم',
              onPageChanged: (p) => selectedPage = p,
            ),
          ),
        ),
      ),
    );

    expect(find.text('عرض 6 - 10 من إجمالي 12 مستخدم'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('3'));
    expect(selectedPage, 3);

    await tester.tap(find.text('السابق'));
    expect(selectedPage, 1);
  });
}

