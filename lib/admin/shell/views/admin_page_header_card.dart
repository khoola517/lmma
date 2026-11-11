import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';

class AdminPageHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget? action;
  final Widget? badge;
  final String? breadcrumb;

  const AdminPageHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.trailing,
    this.action,
    this.badge,
    this.breadcrumb,
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
          color: Colors.white.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;

          final contentColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (breadcrumb != null) ...[
                Text(
                  breadcrumb!,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A3E42),
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //if (icon != null) ...[
                  // Container(
                  //   padding: const EdgeInsets.all(8),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.35),
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child:
                  //       Icon(icon, color: const Color(0xFF2E2527), size: 20),
                  // ),
                  //const SizedBox(width: 10),
                  //],
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
          );

          final actionWidget = action ?? trailing;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                contentColumn,
                if (actionWidget != null) ...[
                  const SizedBox(height: 14),
                  actionWidget,
                ],
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: contentColumn),
              if (actionWidget != null) ...[
                const SizedBox(width: 16),
                actionWidget,
              ],
            ],
          );
        },
      ),
    );
  }
}
