import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/status_badge.dart';
import 'package:khadematy_web/provider/bookings/models/confirmed_booking_model.dart';
import 'package:khadematy_web/provider/shell/providers/navigation_provider.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';
import 'package:khadematy_web/provider/bookings/providers/bookings_provider.dart';
import 'package:khadematy_web/provider/services/providers/services_provider.dart';
import 'package:khadematy_web/provider/profile/providers/profile_provider.dart';

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
          _buildWelcomeBanner(
              context, navProvider, profileProvider.profile.businessName),

          const SizedBox(height: 24),

          // 2. 4 Key Metric Cards
          _buildMetricsGrid(
              context, bookingsProvider, servicesProvider, profileProvider),

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
                          _buildUrgentRequestsSection(
                              context, navProvider, bookingsProvider),
                          const SizedBox(height: 24),
                          _buildUpcomingBookingsSection(
                              context, navProvider, bookingsProvider),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Secondary Column (Top Services)
                    Expanded(
                      flex: 2,
                      child: _buildTopServicesCard(
                          context, navProvider, servicesProvider),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildUrgentRequestsSection(
                        context, navProvider, bookingsProvider),
                    const SizedBox(height: 24),
                    _buildUpcomingBookingsSection(
                        context, navProvider, bookingsProvider),
                    const SizedBox(height: 24),
                    _buildTopServicesCard(
                        context, navProvider, servicesProvider),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(
      BuildContext context, NavigationProvider nav, String businessName) {
    return ProviderPageHeaderCard(
      title: 'مرحباً بك مجدداً، $businessName',
      subtitle:
          'إليك نظرة سريعة على مؤشرات أداء أعمالك والطلبات التي تنتظر اتخاذ إجراءك اليوم.',
      //icon: Icons.dashboard_customize_outlined,
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    BookingsProvider bookingsProvider,
    ServicesProvider servicesProvider,
    ProfileProvider profileProvider,
  ) {
    final totalBookings = bookingsProvider.totalConfirmedCount;
    final pendingCount = bookingsProvider.pendingRequestsCount;
    final totalRevenue = bookingsProvider.totalRevenue;
    final formattedRevenue = _formatCurrency(totalRevenue);

    return ProviderStatsRow(
      cards: [
        ProviderMetricCard(
          title: 'إجمالي الحجوزات',
          value: '$totalBookings',
          subText: '',
          icon: Icons.event_seat_outlined,
          iconBg: AppColors.burgundyLight,
          iconColor: AppColors.burgundy,
          onTap: () => context
              .read<NavigationProvider>()
              .selectItem(ProviderNavItem.confirmedBookings),
        ),
        ProviderMetricCard(
          title: 'طلبات بانتظار الرد',
          value: '$pendingCount',
          // subText: pendingCount > 0 ? 'تحتاج إجراء' : 'تم الرد عليها',
          subTextColor:
              pendingCount > 0 ? AppColors.burgundy : AppColors.success,
          icon: Icons.mark_email_unread_outlined,
          iconBg: AppColors.goldLight,
          iconColor: AppColors.goldDark,
          onTap: () => context
              .read<NavigationProvider>()
              .selectItem(ProviderNavItem.bookingRequests),
        ),
        ProviderMetricCard(
          title: 'إجمالي الإيرادات',
          value: formattedRevenue,
          //subText: 'مدفوعات مؤكدة',
          icon: Icons.payments_outlined,
          iconBg: AppColors.successBg,
          iconColor: AppColors.success,
        ),
        ProviderMetricCard(
          title: 'متوسط التقييم العام',
          value: '${profileProvider.averageRating} ★',
          //subText: 'تقييم العملاء',
          subTextColor: AppColors.goldDark,
          icon: Icons.hotel_class_outlined,
          iconBg: AppColors.goldLight,
          iconColor: AppColors.goldDark,
          onTap: () => context
              .read<NavigationProvider>()
              .selectItem(ProviderNavItem.reviews),
        ),
      ],
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
                      child: const Icon(Icons.flash_on,
                          color: AppColors.burgundy, size: 18),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.burgundy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${requests.length} جديد',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    nav.selectItem(ProviderNavItem.bookingRequests),
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
                                  style: AppTextStyles.titleMedium
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (req.isExpired)
                                  const StatusBadge(
                                    label: 'انتهت المهلة',
                                    type: StatusBadgeType.cancelled,
                                    icon: Icons.timer_off_outlined,
                                  )
                                else if (req.isUrgent)
                                  StatusBadge(
                                    label: 'مهلة وشيكة (${req.remainingDisplay})',
                                    type: StatusBadgeType.inProgress,
                                    icon: Icons.hourglass_bottom_rounded,
                                  )
                                else
                                  StatusBadge(
                                    label: 'متبقي ${req.remainingDisplay}',
                                    type: StatusBadgeType.waiting,
                                    icon: Icons.access_time_rounded,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${req.eventType} • ${req.location}',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              CustomButton(
                                text: 'قبول',
                                height: 32,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                variant: ButtonVariant.primary,
                                onPressed: () async {
                                  final success = await bookingsProvider
                                      .acceptBookingRequest(req.id);
                                  if (context.mounted) {
                                    if (success) {
                                      context
                                          .read<ProfileProvider>()
                                          .incrementBookingsCount();
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'تم قبول حجز ${req.customerName} وتأكيده بنجاح'
                                              : 'تعذر قبول الحجز، يرجى المحاولة لاحقاً',
                                        ),
                                        backgroundColor: success
                                            ? AppColors.burgundy
                                            : AppColors.error,
                                      ),
                                    );
                                  }
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
                      child: const Icon(Icons.event_available,
                          color: AppColors.goldDark, size: 18),
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
                onPressed: () =>
                    nav.selectItem(ProviderNavItem.confirmedBookings),
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
          if (bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا توجد حجوزات مؤكدة حالياً',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
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
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textMuted),
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
                                  style: AppTextStyles.titleMedium
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  label: b.status ==
                                          ConfirmedBookingStatus.inProgress
                                      ? 'قيد التنفيذ'
                                      : 'مؤكد',
                                  type: b.status ==
                                          ConfirmedBookingStatus.inProgress
                                      ? StatusBadgeType.inProgress
                                      : StatusBadgeType.confirmed,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${b.serviceName} • ${b.customerLocation}',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${b.totalAmount.toStringAsFixed(0)} ر.ي',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.burgundy,
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

  static String _formatCurrency(num amount) {
    final str = amount.toStringAsFixed(0);
    final regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return '${str.replaceAll(regExp, ',')} ر.ي';
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
                      child: Icon(Icons.celebration,
                          color: AppColors.burgundy, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: AppTextStyles.labelLarge
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s.category,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted),
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
