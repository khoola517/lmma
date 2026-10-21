import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/confirmed_booking_model.dart';
import '../../../providers/bookings_provider.dart';
import 'widgets/booking_details_drawer.dart';

class ConfirmedBookingsScreen extends StatelessWidget {
  const ConfirmedBookingsScreen({super.key});

  void _openDetails(BuildContext context, ConfirmedBookingModel booking, BookingsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => BookingDetailsDrawer(
        booking: booking,
        onStartExecution: () {
          provider.updateBookingStatus(booking.id, ConfirmedBookingStatus.inProgress);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم بدء تنفيذ حجز #${booking.bookingNumber} بنجاح'),
              backgroundColor: AppColors.burgundy,
            ),
          );
        },
        onCancelBooking: () {
          _confirmCancelBooking(context, booking, provider);
        },
      ),
    );
  }

  void _confirmCancelBooking(
    BuildContext context,
    ConfirmedBookingModel booking,
    BookingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardBg,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text('تأكيد إلغاء الحجز', style: AppTextStyles.headlineSmall),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إلغاء الحجز #${booking.bookingNumber} للعميل ${booking.customerName}؟ سيتم إشعار العميل وإدارة المنصة فوراً.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('رجوع', style: AppTextStyles.labelMedium),
          ),
          CustomButton(
            text: 'تأكيد الإلغاء',
            variant: ButtonVariant.danger,
            onPressed: () {
              provider.updateBookingStatus(booking.id, ConfirmedBookingStatus.cancelled);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إلغاء الحجز #${booking.bookingNumber}'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsProvider = context.watch<BookingsProvider>();
    final bookings = bookingsProvider.confirmedBookings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'الحجوزات المؤكدة',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.successBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'حجوزات معتمدة',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إدارة الحجوزات التي تم تأكيدها ومتابعة مراحل تنفيذها والتواصل مع العملاء',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3 Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.maxWidth > 800 ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: boxWidth,
                    child: _buildSummaryCard(
                      title: 'إجمالي الحجوزات المؤكدة',
                      value: '${bookingsProvider.totalConfirmedCount}',
                      badgeText: 'سجل الحجوزات',
                      icon: Icons.event_available,
                      iconBg: AppColors.burgundyLight,
                      iconColor: AppColors.burgundy,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: _buildSummaryCard(
                      title: 'قيد التنفيذ حالياً',
                      value: '${bookingsProvider.inProgressCount}',
                      badgeText: 'متابعة ميدانية',
                      icon: Icons.timelapse,
                      iconBg: AppColors.warningBg,
                      iconColor: AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: _buildSummaryCard(
                      title: 'الحجوزات المكتملة',
                      value: '${bookingsProvider.completedCount}',
                      badgeText: 'تم التسليم بنجاح',
                      icon: Icons.task_alt,
                      iconBg: AppColors.successBg,
                      iconColor: AppColors.success,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Bookings List
          if (bookings.isEmpty)
            CustomCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_busy_outlined, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'لم يتم العثور على أي حجز مطابق',
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final b = bookings[index];
                return _buildBookingRowCard(context, b, bookingsProvider);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String badgeText,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    badgeText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingRowCard(
    BuildContext context,
    ConfirmedBookingModel booking,
    BookingsProvider provider,
  ) {
    StatusBadgeType badgeType;
    String statusLabel;
    switch (booking.status) {
      case ConfirmedBookingStatus.inProgress:
        badgeType = StatusBadgeType.inProgress;
        statusLabel = 'قيد التنفيذ';
        break;
      case ConfirmedBookingStatus.completed:
        badgeType = StatusBadgeType.completed;
        statusLabel = 'مكتمل';
        break;
      case ConfirmedBookingStatus.cancelled:
        badgeType = StatusBadgeType.cancelled;
        statusLabel = 'ملغي';
        break;
      case ConfirmedBookingStatus.confirmed:
        badgeType = StatusBadgeType.confirmed;
        statusLabel = 'مؤكد';
        break;
    }

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Booking Code Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '#${booking.bookingNumber}',
              style: AppTextStyles.labelMedium.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w800,
                color: AppColors.burgundy,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Customer & Service Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      booking.customerName,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•  ${booking.customerPhone}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${booking.serviceName} (${booking.eventType})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Date & Time
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.goldDark),
                    const SizedBox(width: 6),
                    Text(
                      booking.eventDateString,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  booking.eventTime,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${booking.totalAmount.toStringAsFixed(0)} ر.ي',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(label: statusLabel, type: badgeType),
            ],
          ),

          const SizedBox(width: 16),

          // Details Action
          CustomButton(
            text: 'التفاصيل',
            icon: Icons.visibility_outlined,
            variant: ButtonVariant.primary,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            onPressed: () => _openDetails(context, booking, provider),
          ),
        ],
      ),
    );
  }
}
