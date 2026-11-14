import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AdminNavigationProvider>();
    final adminData = context.watch<AdminDashboardProvider>();

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          left: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(46, 37, 39, 0.04),
            blurRadius: 16,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo & Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.burgundy,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(101, 28, 50, 0.25),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.gold,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'لمة',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 6, vertical: 2),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.goldLight,
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Text(
                          //     'إدارة',
                          //     style: AppTextStyles.labelSmall.copyWith(
                          //       color: AppColors.goldDark,
                          //       fontWeight: FontWeight.bold,
                          //       fontSize: 9,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      Text(
                        'لوحة تحكم المشرف العام',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // const Divider(height: 1),
          // const SizedBox(height: 12),

          // 12 Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildNavItem(
                  item: AdminNavItem.dashboard,
                  title: 'الرئيسية (Dashboard)',
                  icon: Icons.dashboard_rounded,
                  isSelected: nav.selectedItem == AdminNavItem.dashboard,
                  onTap: () => nav.selectItem(AdminNavItem.dashboard),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.users,
                  title: 'إدارة المستخدمين',
                  icon: Icons.people_alt_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.users,
                  badgeText: '${adminData.totalUsersCount}',
                  badgeColor: AppColors.surfaceLow,
                  badgeTextColor: AppColors.textSecondary,
                  onTap: () => nav.selectItem(AdminNavItem.users),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.applications,
                  title: 'إدارة طلبات الانضمام',
                  icon: Icons.assignment_ind_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.applications,
                  badgeText: adminData.pendingApplicationsCount > 0
                      ? '${adminData.pendingApplicationsCount} جديد'
                      : '0',
                  badgeColor: adminData.pendingApplicationsCount > 0
                      ? AppColors.goldLight
                      : AppColors.surfaceLow,
                  badgeTextColor: adminData.pendingApplicationsCount > 0
                      ? AppColors.goldDark
                      : AppColors.textMuted,
                  onTap: () => nav.selectItem(AdminNavItem.applications),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.categories,
                  title: 'إدارة التصنيفات',
                  icon: Icons.category_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.categories,
                  onTap: () => nav.selectItem(AdminNavItem.categories),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.services,
                  title: 'إدارة الخدمات',
                  icon: Icons.miscellaneous_services_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.services,
                  badgeText: '${adminData.totalServicesCount}',
                  badgeColor: AppColors.surfaceLow,
                  badgeTextColor: AppColors.textSecondary,
                  onTap: () => nav.selectItem(AdminNavItem.services),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.bookings,
                  title: 'إدارة الحجوزات',
                  icon: Icons.calendar_month_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.bookings,
                  badgeText: '${adminData.totalBookingsCount}',
                  badgeColor: AppColors.burgundyLight,
                  badgeTextColor: AppColors.burgundy,
                  onTap: () => nav.selectItem(AdminNavItem.bookings),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.complaints,
                  title: 'إدارة الشكاوى',
                  icon: Icons.report_problem_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.complaints,
                  badgeText: adminData.newComplaintsCount > 0
                      ? '${adminData.newComplaintsCount} معلقة'
                      : null,
                  badgeColor: AppColors.errorBg,
                  badgeTextColor: AppColors.error,
                  onTap: () => nav.selectItem(AdminNavItem.complaints),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.reviews,
                  title: 'إدارة التقييمات',
                  icon: Icons.rate_review_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.reviews,
                  badgeText: '★ ${adminData.averageRating}',
                  badgeColor: AppColors.goldLight,
                  badgeTextColor: AppColors.goldDark,
                  onTap: () => nav.selectItem(AdminNavItem.reviews),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.notifications,
                  title: 'إدارة الإشعارات',
                  icon: Icons.campaign_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.notifications,
                  onTap: () => nav.selectItem(AdminNavItem.notifications),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.settings,
                  title: 'إعدادات المنصة',
                  icon: Icons.tune_rounded,
                  isSelected: nav.selectedItem == AdminNavItem.settings,
                  onTap: () => nav.selectItem(AdminNavItem.settings),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  item: AdminNavItem.profile,
                  title: 'الملف الشخصي ',
                  icon: Icons.account_circle_outlined,
                  isSelected: nav.selectedItem == AdminNavItem.profile,
                  onTap: () => nav.selectItem(AdminNavItem.profile),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                await context.read<AuthProvider>().signOut();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الخروج من لوحة الإدارة بنجاح'),
                    backgroundColor: AppColors.burgundy,
                    duration: Duration(seconds: 1),
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/login');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorBorder, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 35),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18, color: AppColors.cardBg),
                      const SizedBox(width: 12),
                      Text(
                        'تسجيل الخروج',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.cardBg,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required AdminNavItem item,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.burgundy : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.burgundy.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isSelected) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (badgeText != null && !isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.surfaceLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: badgeTextColor != null
                          ? badgeTextColor.withOpacity(0.3)
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: badgeTextColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
