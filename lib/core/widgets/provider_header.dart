import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:khadematy_web/provider/profile/providers/profile_provider.dart';
import 'package:khadematy_web/provider/shell/providers/navigation_provider.dart';

class ProviderHeader extends StatelessWidget {
  final String? title;
  final ValueChanged<String>? onSearch;

  const ProviderHeader({
    super.key,
    this.title,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final navProvider = context.watch<NavigationProvider>();
    final unreadCount = profileProvider.unreadNotificationsCount;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.creamBg,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(46, 37, 39, 0.02),
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              height: 42,
              decoration: BoxDecoration(
                
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: onSearch,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'ابحث عن حجز، عميل، أو خدمة...',
                  hintStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.burgundy,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Notifications Popup
          PopupMenuButton<int>(
            tooltip: 'الإشعارات',
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            color: AppColors.cardBg,
            elevation: 8,
            itemBuilder: (context) {
              return [
                PopupMenuItem<int>(
                  enabled: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإشعارات الأخيرة',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          profileProvider.markAllNotificationsAsRead();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'الكل مقروء',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ...profileProvider.notifications.map((n) {
                  return PopupMenuItem<int>(
                    value: int.tryParse(n.id) ?? 0,
                    child: Container(
                      width: 290,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: n.iconColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(n.icon, size: 18, color: n.iconColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style:
                                            AppTextStyles.labelMedium.copyWith(
                                          fontWeight: n.isRead
                                              ? FontWeight.w600
                                              : FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.burgundy,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  n.subtitle,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  n.time,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ];
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: AppColors.burgundy,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.burgundy,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Center(
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Provider Profile Avatar
          InkWell(
            onTap: () => navProvider.selectItem(ProviderNavItem.profile),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.burgundy,
                  shape: BoxShape.circle,
                  //border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
