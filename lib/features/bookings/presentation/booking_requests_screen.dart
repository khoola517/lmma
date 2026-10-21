import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/booking_request_model.dart';
import '../../../providers/bookings_provider.dart';

class BookingRequestsScreen extends StatelessWidget {
  const BookingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingsProvider = context.watch<BookingsProvider>();
    final requests = bookingsProvider.pendingRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'طلبات الحجز الجديدة',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.burgundy,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${requests.length} جديد',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'راجع طلبات الحجز الواردة من العملاء وقم بالموافقة عليها أو تقديم عروضك قبل انتهاء المهلة',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Requests List
          if (requests.isEmpty)
            CustomCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 52, color: AppColors.goldDark),
                    const SizedBox(height: 14),
                    Text(
                      'لا توجد طلبات حجز معلقة حالياً',
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تم الرد على كافة الطلبات السابقة، ستتلقى إشعاراً فورياً عند وصول أي حجز جديد.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final req = requests[index];
                return _buildRequestCard(context, req, bookingsProvider);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    BookingRequestModel req,
    BookingsProvider provider,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Customer Details + Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDark, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        req.customerAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.burgundyLight,
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
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name & Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.customerName,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 15, color: AppColors.goldDark),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            req.location,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: AppTextStyles.bodySmall),
                        const SizedBox(width: 8),
                        const Icon(Icons.schedule, size: 15, color: AppColors.goldDark),
                        const SizedBox(width: 4),
                        Text(
                          req.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badges (Code & Remaining Timer)
              Row(
                children: [
                  StatusBadge(
                    label: 'بانتظار الرد (${req.remainingHours} ساعة متبقية)',
                    type: StatusBadgeType.waiting,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      req.code,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // 4 Grid Info Boxes
          LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.maxWidth > 700 ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFieldBox(
                    width: boxWidth,
                    icon: Icons.celebration,
                    label: 'نوع المناسبة',
                    value: req.eventType,
                  ),
                  _buildFieldBox(
                    width: boxWidth,
                    icon: Icons.calendar_month,
                    label: 'تاريخ ووقت الفعالية',
                    value: req.eventDate,
                    subValue: req.eventTime,
                  ),
                  _buildFieldBox(
                    width: boxWidth,
                    icon: Icons.groups,
                    label: 'عدد الحضور',
                    value: '${req.attendeesCount} شخص',
                  ),
                  _buildFieldBox(
                    width: boxWidth,
                    icon: Icons.payments,
                    label: 'الميزانية المقترحة',
                    value: '${req.budget.toStringAsFixed(0)} ر.ي',
                    valueColor: AppColors.burgundy,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          // Quote / Notes Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.burgundy),
                    const SizedBox(width: 8),
                    Text(
                      'الخدمة المطلوبة: ${req.serviceName}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.burgundy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"${req.notes}"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                text: 'رفض الطلب',
                icon: Icons.close,
                variant: ButtonVariant.danger,
                height: 40,
                onPressed: () {
                  provider.rejectBookingRequest(req.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم رفض طلب ${req.customerName}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              CustomButton(
                text: 'قبول وتأكيد الحجز',
                icon: Icons.check,
                variant: ButtonVariant.primary,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                onPressed: () {
                  provider.acceptBookingRequest(req.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم قبول وتأكيد حجز ${req.customerName} وإضافته إلى جدول الحجوزات'),
                      backgroundColor: AppColors.burgundy,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldBox({
    required double width,
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    Color? valueColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.burgundy),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
