import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';

/// زر فلترة موحد لبوابة مقدم الخدمة مطابق لتصميم أزرار صفحة التقييمات
/// يتميز بحواف دائرية (24px)، خلفية بيضاء عند عدم التحديد، ولون بارز وظل عند التحديد.
class ProviderFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const ProviderFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = activeColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? resolvedColor : AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? resolvedColor : AppColors.borderDark,
            width: isSelected ? 1.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: resolvedColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF4A3E44),
          ),
        ),
      ),
    );
  }
}

