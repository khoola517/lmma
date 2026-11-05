import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';

/// كارد الهيدر الموحد لصفحات بوابة مقدم الخدمة
/// يتميز بالتدرج اللوني الذهبي/الأصفر المعتمد في الهوية البصرية، وخالٍ من الأزرار الداخلية
class ProviderPageHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? badge;

  const ProviderPageHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF2E2527), size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E2527),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 12),
                badge!,
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF423538),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

