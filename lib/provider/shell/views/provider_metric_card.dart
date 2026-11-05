import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// كارد إحصائي موحد لشاشات مقدم الخدمة يعرض أرقاماً حية من قاعدة البيانات
class ProviderMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subText;
  final Color? subTextColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? activeBorderColor;

  const ProviderMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subText,
    this.subTextColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.onTap,
    this.isSelected = false,
    this.activeBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (activeBorderColor ?? const Color(0xFF681729))
                : const Color(0xFFEBE6DF),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (activeBorderColor ?? const Color(0xFF681729)).withOpacity(0.08)
                  : Colors.black.withOpacity(0.015),
              blurRadius: isSelected ? 12 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8A7F84),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E2527),
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subText != null && subText!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          subText!,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subTextColor ?? const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

