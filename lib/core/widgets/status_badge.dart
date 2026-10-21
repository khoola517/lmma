import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum StatusBadgeType {
  waiting,
  confirmed,
  inProgress,
  completed,
  cancelled,
  active,
  inactive,
  gold,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (type) {
      case StatusBadgeType.waiting:
        bgColor = AppColors.burgundyLight;
        textColor = AppColors.burgundy;
        borderColor = AppColors.burgundyLightBorder;
        break;
      case StatusBadgeType.confirmed:
      case StatusBadgeType.active:
      case StatusBadgeType.completed:
        bgColor = AppColors.successBg;
        textColor = AppColors.success;
        borderColor = AppColors.successBorder;
        break;
      case StatusBadgeType.inProgress:
        bgColor = AppColors.warningBg;
        textColor = AppColors.warning;
        borderColor = AppColors.warningBorder;
        break;
      case StatusBadgeType.cancelled:
      case StatusBadgeType.inactive:
        bgColor = AppColors.errorBg;
        textColor = AppColors.error;
        borderColor = AppColors.errorBorder;
        break;
      case StatusBadgeType.gold:
        bgColor = AppColors.goldLight;
        textColor = AppColors.goldDark;
        borderColor = AppColors.goldBorder;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
