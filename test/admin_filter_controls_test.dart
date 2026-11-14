import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khadematy_web/admin/shell/views/admin_filter_controls.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';

void main() {
  testWidgets(
      'Admin filter chip, dropdown, and action button share uniform 42px height and colors',
      (WidgetTester tester) async {
    String selected = 'all';

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Row(
              children: [
                AdminFilterChip(
                  label: 'الكل',
                  count: 5,
                  isSelected: true,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'قيد المراجعة',
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                AdminFilterDropdown<String>(
                  value: selected,
                  icon: Icons.filter_alt_outlined,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
                    DropdownMenuItem(value: 'active', child: Text('نشط')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(width: 8),
                AdminFilterActionButton(
                  label: 'تصدير',
                  icon: Icons.file_download_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final chip1Size = tester.getSize(find.byType(AdminFilterChip).first);
    final chip2Size = tester.getSize(find.byType(AdminFilterChip).last);
    final dropdownSize = tester.getSize(find.byType(AdminFilterDropdown<String>));
    final actionSize = tester.getSize(find.byType(AdminFilterActionButton));

    expect(chip1Size.height, AdminFilterStyle.height);
    expect(chip2Size.height, AdminFilterStyle.height);
    expect(dropdownSize.height, AdminFilterStyle.height);
    expect(actionSize.height, AdminFilterStyle.height);

    final selectedLabel = tester.widget<Text>(find.text('الكل'));
    expect(selectedLabel.style?.color, Colors.white);

    final unselectedLabel = tester.widget<Text>(find.text('قيد المراجعة'));
    expect(unselectedLabel.style?.color, AdminFilterStyle.textColor);

    final leadingIcon =
        tester.widget<Icon>(find.byIcon(Icons.filter_alt_outlined));
    expect(leadingIcon.color, AppColors.primary);
    expect(leadingIcon.size, 18);
  });
}

