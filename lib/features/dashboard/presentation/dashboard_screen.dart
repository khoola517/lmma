import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/confirmed_booking_model.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/bookings_provider.dart';
import '../../../providers/services_provider.dart';
import '../../../providers/profile_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.read<NavigationProvider>();
    final bookingsProvider = context.watch<BookingsProvider>();
    final servicesProvider = context.watch<ServicesProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Banner
          _buildWelcomeBanner(context, navProvider, profileProvider.profile.businessName),

          const SizedBox(height: 24),

          // 2. 4 Key Metric Cards
          _buildMetricsGrid(context, bookingsProvider, servicesProvider, profileProvider),

          const SizedBox(height: 28),

          // 3. Main Dashboard Content (Two Columns or Stacked on Tablet)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1050) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Column (Requests & Upcoming Bookings)
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildUrgentRequestsSection(context, navProvider, bookingsProvider),
                          const SizedBox(height: 24),
                          _buildUpcomingBookingsSection(context, navProvider, bookingsProvider),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Secondary Column (Performance & Top Services)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildPerformanceKpiCard(context),
                          const SizedBox(height: 24),
                          _buildTopServicesCard(context, navProvider, servicesProvider),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildUrgentRequestsSection(context, navProvider, bookingsProvider),
                    const SizedBox(height: 24),
                    _buildUpcomingBookingsSection(context, navProvider, bookingsProvider),
                    const SizedBox(height: 24),
                    _buildPerformanceKpiCard(context),
                    const SizedBox(height: 24),
                    _buildTopServicesCard(context, navProvider, servicesProvider),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, NavigationProvider nav, String businessName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(101, 28, 50, 0.04),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;

          final textSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'مرحباً بك مجدداً، $businessName',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldBorder),
                    ),
                    child: Text(
                      'لوحة التحكم المباشرة',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'إليك نظرة سريعة على مؤشرات أداء أعمالك والطلبات التي تنتظر اتخاذ إجراءك اليوم.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          );

          final buttonsSection = Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              CustomButton(
                text: 'طلبات الحجز',
                icon: Icons.mark_email_unread_outlined,
                variant: ButtonVariant.outline,
                onPressed: () => nav.selectItem(ProviderNavItem.bookingRequests),
              ),
              CustomButton(
                text: 'إضافة خدمة جديدة',
                icon: Icons.add,
                variant: ButtonVariant.primary,
                onPressed: () => nav.selectItem(ProviderNavItem.myServices),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSection,
                const SizedBox(height: 16),
                buttonsSection,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: textSection),
              const SizedBox(width: 16),
              buttonsSection,
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    BookingsProvider bookingsProvider,
    ServicesProvider servicesProvider,
    ProfileProvider profileProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1050 ? 4 : (constraints.maxWidth > 580 ? 2 : 1);
        final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'إجمالي الحجوزات',
                value: '${profileProvider.profile.completedBookingsCount}',
                subText: '+14% هذا الشهر',
                subTextColor: AppColors.success,
                icon: Icons.event_seat_outlined,
                iconBg: AppColors.burgundyLight,
                iconColor: AppColors.burgundy,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'طلبات بانتظار الرد',
                value: '${bookingsProvider.pendingRequestsCount}',
                subText: 'تحتاج إجراء سريع',
                subTextColor: AppColors.burgundy,
                icon: Icons.mark_email_unread_outlined,
                iconBg: AppColors.goldLight,
                iconColor: AppColors.goldDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'إجمالي الإيرادات المعتمدة',
                value: '1,850,000 ر.ي',
                subText: 'مدفوعات مؤكدة',
                subTextColor: AppColors.success,
                icon: Icons.payments_outlined,
                iconBg: AppColors.successBg,
                iconColor: AppColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'متوسط التقييم العام',
                value: '${profileProvider.averageRating} ★',
                subText: 'من ${profileProvider.totalReviewsCount} مراجعة موثقة',
                subTextColor: AppColors.goldDark,
                icon: Icons.hotel_class_outlined,
                iconBg: AppColors.goldLight,
                iconColor: AppColors.goldDark,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subText,
    required Color subTextColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 20)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.burgundy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: subTextColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subText,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentRequestsSection(
    BuildContext context,
    NavigationProvider nav,
    BookingsProvider bookingsProvider,
  ) {
    final requests = bookingsProvider.pendingRequests;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.burgundyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flash_on, color: AppColors.burgundy, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'طلبات الحجز العاجلة',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.burgundy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${requests.length} جديد',
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => nav.selectItem(ProviderNavItem.bookingRequests),
                child: Text(
                  'عرض كافة الطلبات ←',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا توجد طلبات حجز جديدة حالياً',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.take(2).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = requests[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.burgundyLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Center(
                          child: Text(
                            req.customerName.substring(0, 1),
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.burgundy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  req.customerName,
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                ),
                                StatusBadge(
                                  label: 'متبقي ${req.remainingHours} ساعة',
                                  type: StatusBadgeType.waiting,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${req.eventType} • ${req.location}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${req.budget.toStringAsFixed(0)} ر.ي',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.burgundy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              CustomButton(
                                text: 'قبول',
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                variant: ButtonVariant.primary,
                                onPressed: () {
                                  bookingsProvider.acceptBookingRequest(req.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم قبول حجز ${req.customerName} وتأكيده'),
                                      backgroundColor: AppColors.burgundy,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBookingsSection(
    BuildContext context,
    NavigationProvider nav,
    BookingsProvider bookingsProvider,
  ) {
    final bookings = bookingsProvider.confirmedBookings;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.event_available, color: AppColors.goldDark, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'الحجوزات القادمة المعتمدة',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => nav.selectItem(ProviderNavItem.confirmedBookings),
                child: Text(
                  'عرض جدول الحجوزات ←',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.take(3).length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            b.eventDateString.split(' ').first,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.burgundy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            b.eventDateString.split(' ').length > 1
                                ? b.eventDateString.split(' ')[1]
                                : '',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                b.customerName,
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(
                                label: b.status == ConfirmedBookingStatus.inProgress
                                    ? 'قيد التنفيذ'
                                    : 'مؤكد',
                                type: b.status == ConfirmedBookingStatus.inProgress
                                    ? StatusBadgeType.inProgress
                                    : StatusBadgeType.confirmed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${b.serviceName} • ${b.customerLocation}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${b.totalAmount.toStringAsFixed(0)} ر.ي',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceKpiCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.burgundyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined, color: AppColors.burgundy, size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'مؤشرات الأداء والجودة',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 18),
          _buildKpiProgressItem('نسبة رضا العملاء', '98.4%', 0.984, AppColors.success),
          const SizedBox(height: 14),
          _buildKpiProgressItem('الالتزام بمواعيد التسليم', '100%', 1.0, AppColors.burgundy),
          const SizedBox(height: 14),
          _buildKpiProgressItem('سرعة الرد على الطلبات', '94%', 0.94, AppColors.goldDark),
          const SizedBox(height: 14),
          _buildKpiProgressItem('معدل قبول الحجوزات', '92%', 0.92, AppColors.info),
        ],
      ),
    );
  }

  Widget _buildKpiProgressItem(String title, String percentage, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              percentage,
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.surfaceLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTopServicesCard(
    BuildContext context,
    NavigationProvider nav,
    ServicesProvider servicesProvider,
  ) {
    final services = servicesProvider.services;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'الخدمات الأكثر طلباً',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => nav.selectItem(ProviderNavItem.myServices),
                child: Text(
                  'إدارة الخدمات',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.take(3).length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final s = services[index];
              return Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Icon(Icons.celebration, color: AppColors.burgundy, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s.category,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${s.price.toStringAsFixed(0)} ر.ي',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
