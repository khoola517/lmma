import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';

class AdminHeader extends StatelessWidget {
  final String? title;

  const AdminHeader({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AdminNavigationProvider>();
    final adminData = context.watch<AdminDashboardProvider>();
    final auth = context.watch<AuthProvider>();
    final pendingCount = adminData.pendingApplicationsCount;
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
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
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'القائمة',
            ),
            const SizedBox(width: 8),
          ] else if (nav.isSidebarCollapsed) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: nav.toggleSidebar,
              tooltip: 'إظهار القائمة',
            ),
            const SizedBox(width: 8),
          ],

          // Search Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (q) => nav.setSearchQuery(q),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'بحث سريع في النظام، التصنيفات، أو الخدمات...',
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Notifications Popup Button
          PopupMenuButton<int>(
            tooltip: 'تنبيهات الإدارة',
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
                        'إشعارات النظام والإدارة',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingCount مهام معلقة',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_ind_outlined,
                            size: 18, color: AppColors.goldDark),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلبات اعتماد مقدمي خدمة جدد',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'يوجد $pendingCount طلب انضمام بانتظار التدقيق والمراجعة.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.success),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'استقرار اتصال Supabase',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'قاعدة البيانات تعمل بحالة ممتازة وبسرعة استجابة عالية.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (pendingCount > 0)
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
                          const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Center(
                        child: Text(
                          '$pendingCount',
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
          Container(height: 24, width: 1, color: AppColors.border),
          const SizedBox(width: 14),

          // Admin Profile Avatar Button
          InkWell(
            onTap: () => nav.selectItem(AdminNavItem.profile),
            borderRadius: BorderRadius.circular(20),
            child: Tooltip(
              message: 'الملف الشخصي للمشرف',
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.burgundy,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: auth.userProfile?.avatarUrl?.isNotEmpty == true
                    ? Image.network(
                        auth.userProfile!.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.admin_panel_settings,
                              color: Colors.white, size: 20),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.admin_panel_settings,
                            color: Colors.white, size: 20),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
