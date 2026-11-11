import 'package:flutter/material.dart';
import '../services/live_notification_banner_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// طبقة عالمية لعرض لافتة الإشعارات الفورية في أعلى شاشة الويب
class InAppNotificationOverlay extends StatelessWidget {
  final Widget child;

  const InAppNotificationOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<InAppAlertEvent?>(
          valueListenable: LiveNotificationBannerService.instance.currentAlert,
          builder: (context, alert, _) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              top: alert != null ? 20 : -140,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: alert == null,
                child: SafeArea(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: alert != null ? 1.0 : 0.0,
                      child: alert == null
                          ? const SizedBox.shrink()
                          : _BannerCard(alert: alert),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final InAppAlertEvent alert;

  const _BannerCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.burgundy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldLight.withOpacity(0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.goldLight.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.goldLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (alert.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      alert.body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => LiveNotificationBannerService.instance.dismiss(),
              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
              tooltip: 'إغلاق',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }
}

