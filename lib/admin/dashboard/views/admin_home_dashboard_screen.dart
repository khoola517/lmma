import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'package:khadematy_web/admin/shell/views/admin_stat_card.dart';

class AdminHomeDashboardScreen extends StatelessWidget {
  const AdminHomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final nav = context.read<AdminNavigationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Banner
          _buildWelcomeBanner(nav),

          const SizedBox(height: 24),

          // 2. 4 Primary Stat Cards
          _buildFourStatCards(context, adminData),

          const SizedBox(height: 28),

          // 3. Platform Summary Grid (الخدمات النشطة/المتوقفة والمزودون المعتمدون/طلبات الانضمام)
          _buildPlatformSummarySection(context, adminData, nav),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(AdminNavigationProvider nav) {
    return const AdminPageHeaderCard(
      title: 'مرحباً بك في إدارة منصة خِدمتي',
      subtitle:
          'متابعة حية ومباشرة لحركة الحجوزات، اعتماد مقدمي الخدمات، ونمو قطاع تنظيم المناسبات في كافة المدن.',
      //icon: Icons.admin_panel_settings_rounded,
    );
  }

  Widget _buildFourStatCards(
      BuildContext context, AdminDashboardProvider data) {
    return AdminStatsRow(
      cards: [
        AdminStatCard(
          title: 'إجمالي المستخدمين',
          value: '${data.totalUsersCount}',
          icon: Icons.people_alt_outlined,
          iconBg: AppColors.burgundyLight,
          iconColor: AppColors.burgundy,
        ),
        AdminStatCard(
          title: 'مقدمو الخدمات',
          value: '${data.totalProvidersCount}',
          icon: Icons.storefront_outlined,
          iconBg: AppColors.goldLight,
          iconColor: AppColors.goldDark,
        ),
        AdminStatCard(
          title: 'إجمالي الحجوزات',
          value: '${data.totalBookingsCount}',
          icon: Icons.calendar_month_outlined,
          iconBg: AppColors.successBg,
          iconColor: AppColors.success,
        ),
        AdminStatCard(
          title: 'إجمالي الخدمات',
          value: '${data.totalServicesCount}',
          icon: Icons.category_outlined,
          iconBg: const Color(0xFFF0EAE1),
          iconColor: AppColors.burgundy,
        ),
      ],
    );
  }

  Widget _buildPlatformSummarySection(
    BuildContext context,
    AdminDashboardProvider data,
    AdminNavigationProvider nav,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص المنصة التشغيلي',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نظرة سريعة على توازن الخدمات وحالة مقدمي الخدمة بدون تكرار الجداول التفصيلية',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;

            final servicesCard = CustomCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.burgundyLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.miscellaneous_services_outlined,
                            color: AppColors.burgundy, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'حالة الخدمات في السوق',
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => nav.selectItem(AdminNavItem.services),
                        child: Text(
                          'إدارة الخدمات ←',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryProgressRow(
                    label: 'الخدمات النشطة (متاحة للطلب)',
                    count: data.activeServicesCount,
                    total: data.totalServicesCount > 0
                        ? data.totalServicesCount
                        : 1,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 14),
                  _buildSummaryProgressRow(
                    label: 'الخدمات المتوقفة أو المؤقتة',
                    count: data.pausedServicesCount,
                    total: data.totalServicesCount > 0
                        ? data.totalServicesCount
                        : 1,
                    color: AppColors.warning,
                  ),
                ],
              ),
            );

            final providersCard = CustomCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.verified_user_outlined,
                            color: AppColors.goldDark, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'حالة مقدمي الخدمات والطلبات',
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            nav.selectItem(AdminNavItem.applications),
                        child: Text(
                          'طلبات الانضمام ←',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryProgressRow(
                    label: 'مقدمو الخدمات المعتمدون',
                    count: data.approvedProvidersCount,
                    total: (data.approvedProvidersCount +
                                data.pendingApplicationsCount) >
                            0
                        ? (data.approvedProvidersCount +
                            data.pendingApplicationsCount)
                        : 1,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 14),
                  _buildSummaryProgressRow(
                    label: 'طلبات انضمام قيد المراجعة والتدقيق',
                    count: data.pendingApplicationsCount,
                    total: (data.approvedProvidersCount +
                                data.pendingApplicationsCount) >
                            0
                        ? (data.approvedProvidersCount +
                            data.pendingApplicationsCount)
                        : 1,
                    color: AppColors.goldDark,
                  ),
                ],
              ),
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: servicesCard),
                  const SizedBox(width: 16),
                  Expanded(child: providersCard),
                ],
              );
            } else {
              return Column(
                children: [
                  servicesCard,
                  const SizedBox(height: 16),
                  providersCard,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryProgressRow({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final double percentage = (count / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 7,
            backgroundColor: AppColors.surfaceLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
