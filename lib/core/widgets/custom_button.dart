import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant {
  primary, // Burgundy background
  secondary, // Gold accent
  outline, // Border with burgundy text
  danger, // Rose / Red background
  ghost, // No background
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.burgundy;
        textColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.gold;
        textColor = Colors.white;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppColors.burgundy;
        borderSide = const BorderSide(color: AppColors.borderDark, width: 1.2);
        break;
      case ButtonVariant.danger:
        bgColor = AppColors.errorBg;
        textColor = AppColors.error;
        borderSide = const BorderSide(color: AppColors.errorBorder, width: 1);
        break;
      case ButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = AppColors.textSecondary;
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
        ],
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          hoverColor: variant == ButtonVariant.primary
              ? AppColors.burgundyHover
              : Colors.black.withOpacity(0.05),
          child: Padding(
            padding: padding,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
