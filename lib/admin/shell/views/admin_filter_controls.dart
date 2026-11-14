import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';

/// ثوابت وأدوات التنسيق الموحدة لأزرار وقوائم الفلترة في صفحات لوحة الإدارة.
class AdminFilterStyle {
  AdminFilterStyle._();

  static const double height = 42;
  static const double radius = 24;
  static const Color textColor = Color(0xFF4A3E44);

  static TextStyle textStyle({bool isSelected = false}) {
    return GoogleFonts.cairo(
      fontSize: 12.5,
      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
      color: isSelected ? Colors.white : textColor,
    );
  }

  static BoxDecoration decoration({
    bool isSelected = false,
    bool isActive = false,
  }) {
    final activeBorder = isSelected || isActive;
    return BoxDecoration(
      color: isSelected ? AppColors.primary : AppColors.cardBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: activeBorder ? AppColors.primary : AppColors.borderDark,
        width: activeBorder ? 1.5 : 1.2,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.28),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
}

/// زر فلترة موحد لصفحات المشرف (خلفية بيضاء، حواف دائرية، ونص أبيض مع لون ذهبي عند التحديد).
class AdminFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final int? count;
  final bool expand;

  const AdminFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.count,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            style: AdminFilterStyle.textStyle(isSelected: isSelected),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.25)
                  : AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AdminFilterStyle.textColor,
              ),
            ),
          ),
        ],
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminFilterStyle.radius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: AdminFilterStyle.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: AdminFilterStyle.decoration(isSelected: isSelected),
        child: content,
      ),
    );
  }
}

/// قائمة منسدلة موحدة للفلاتر في صفحات المشرف بنفس الحجم والخلفية والخط والأيقونات.
class AdminFilterDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final bool isActive;
  final bool isExpanded;

  const AdminFilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.isActive = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.any((item) => item.value == value)
        ? value
        : (items.isNotEmpty ? items.first.value : null);

    final dropdown = DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: safeValue,
        isDense: true,
        isExpanded: isExpanded,
        dropdownColor: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.primary,
        ),
        style: AdminFilterStyle.textStyle(),
        items: items,
        onChanged: onChanged,
      ),
    );

    return Container(
      height: AdminFilterStyle.height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: AdminFilterStyle.decoration(isActive: isActive),
      child: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          if (isExpanded) Expanded(child: dropdown) else dropdown,
        ],
      ),
    );
  }
}

/// زر إجرائي ثانوي بجانب الفلاتر (مثل تصدير) بنفس تنسيق أزرار الفلترة.
class AdminFilterActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AdminFilterActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminFilterStyle.radius),
      child: Container(
        height: AdminFilterStyle.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: AdminFilterStyle.decoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AdminFilterStyle.textStyle().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

