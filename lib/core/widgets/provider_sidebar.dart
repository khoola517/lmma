import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/profile_provider.dart';

class ProviderSidebar extends StatelessWidget {
  const ProviderSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final bookingsProvider = context.watch<BookingsProvider>();
    final profileProvider = context.watch<ProfileProvider>();

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
                      Icons.diamond_outlined,
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
                      Text(
                        'خِدمتي',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'بوابة مقدمي الخدمة',
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

          const Divider(height: 1),
          const SizedBox(height: 16),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildNavItem(
                  context: context,
                  item: ProviderNavItem.dashboard,
                  title: 'لوحة التحكم',
                  icon: Icons.dashboard_outlined,
                  isSelected: navProvider.selectedItem == ProviderNavItem.dashboard,
                  onTap: () => navProvider.selectItem(ProviderNavItem.dashboard),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  item: ProviderNavItem.bookingRequests,
                  title: 'طلبات الحجز',
                  icon: Icons.mark_email_unread_outlined,
                  isSelected: navProvider.selectedItem == ProviderNavItem.bookingRequests,
                  badgeText: '${bookingsProvider.pendingRequestsCount} جديد',
                  badgeColor: AppColors.goldLight,
                  badgeTextColor: AppColors.goldDark,
                  onTap: () => navProvider.selectItem(ProviderNavItem.bookingRequests),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  item: ProviderNavItem.confirmedBookings,
                  title: 'الحجوزات',
                  icon: Icons.event_available_outlined,
                  isSelected: navProvider.selectedItem == ProviderNavItem.confirmedBookings,
                  onTap: () => navProvider.selectItem(ProviderNavItem.confirmedBookings),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  item: ProviderNavItem.myServices,
                  title: 'خدماتي',
                  icon: Icons.category_outlined,
                  isSelected: navProvider.selectedItem == ProviderNavItem.myServices,
                  onTap: () => navProvider.selectItem(ProviderNavItem.myServices),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  item: ProviderNavItem.reviews,
                  title: 'التقييمات',
                  icon: Icons.star_border_outlined,
                  isSelected: navProvider.selectedItem == ProviderNavItem.reviews,
                  badgeText: '★ ${profileProvider.averageRating.toStringAsFixed(1)}',
                  badgeColor: AppColors.goldLight,
                  badgeTextColor: AppColors.goldDark,
                  onTap: () => navProvider.selectItem(ProviderNavItem.reviews),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  item: ProviderNavItem.profile,
                  title: 'الملف الشخصي',
                  icon: Icons.badge_outlined,
                  isSelected: navProvider.selectedItem == ProviderNavItem.profile,
                  onTap: () => navProvider.selectItem(ProviderNavItem.profile),
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  item: ProviderNavItem.settings,
                  title: 'الإعدادات',
                  icon: Icons.settings_outlined,
                  isSelected: navProvider.selectedItem == ProviderNavItem.settings,
                  onTap: () => navProvider.selectItem(ProviderNavItem.settings),
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الخروج بنجاح'),
                    backgroundColor: AppColors.burgundy,
                    duration: Duration(seconds: 1),
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/login');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorBorder, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(
                      'تسجيل الخروج',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required ProviderNavItem item,
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.burgundyLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? const Border(
                    right: BorderSide(color: AppColors.burgundy, width: 3.5),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.burgundy : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected ? AppColors.burgundy : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
