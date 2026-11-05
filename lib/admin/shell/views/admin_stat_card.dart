import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';

/// كارد إحصائي موحد لشاشات لوحة تحكم الأدمن
/// يوحد الشكل والحجم والارتفاع ونمط الألوان والظلال والخطوط عبر جميع صفحات لوحة التحكم
class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subText;
  final Color? subTextColor;
  final Color? valueColor;
  final IconData? icon;
  final Color iconBg;
  final Color iconColor;
  final Widget? iconWidget;
  final Widget? badge;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? activeBorderColor;
  final double height;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subText,
    this.subTextColor,
    this.valueColor,
    this.icon,
    this.iconBg = const Color(0xFFFDF2F4),
    this.iconColor = AppColors.burgundy,
    this.iconWidget,
    this.badge,
    this.onTap,
    this.isSelected = false,
    this.activeBorderColor,
    this.height = 96.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = isSelected
        ? (activeBorderColor ?? AppColors.burgundy)
        : const Color(0xFFEBE6DF);

    final cardContent = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? (activeBorderColor ?? AppColors.burgundy).withOpacity(0.08)
                : Colors.black.withOpacity(0.018),
            blurRadius: isSelected ? 12 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Text Info (Title & Value & SubText/Badge) on the Start/Right side (RTL)
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: valueColor ?? const Color(0xFF2E2527),
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (subText != null && subText!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          subText!,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subTextColor ?? const Color(0xFF9CA3AF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge!,
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 2. Icon Container on the End/Left side (RTL)
          iconWidget ??
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon ?? Icons.analytics_outlined,
                    color: iconColor, size: 22),
              ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: AppColors.burgundy.withOpacity(0.02),
          splashColor: AppColors.burgundy.withOpacity(0.06),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// صف أفقي متناسق ومستجيب (Responsive) لعرض كاردات الإحصائيات في شاشات الأدمن
class AdminStatsRow extends StatelessWidget {
  final List<Widget> cards;
  final double? minWidth;
  final double spacing;

  const AdminStatsRow({
    super.key,
    required this.cards,
    this.minWidth,
    this.spacing = 14,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMinWidth = minWidth ?? (cards.length * 215.0);
        final row = Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              Expanded(child: cards[i]),
            ],
          ],
        );

        if (constraints.maxWidth >= effectiveMinWidth) {
          return row;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: effectiveMinWidth,
            child: row,
          ),
        );
      },
    );
  }
}

