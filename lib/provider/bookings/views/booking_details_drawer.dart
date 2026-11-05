import 'package:flutter/material.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/status_badge.dart';
import 'package:khadematy_web/provider/bookings/models/confirmed_booking_model.dart';

class BookingDetailsDrawer extends StatelessWidget {
  final ConfirmedBookingModel booking;
  final VoidCallback onStartExecution;
  final VoidCallback? onCompleteBooking;
  final VoidCallback onCancelBooking;

  const BookingDetailsDrawer({
    super.key,
    required this.booking,
    required this.onStartExecution,
    this.onCompleteBooking,
    required this.onCancelBooking,
  });

  @override
  Widget build(BuildContext context) {
    final isOngoing = booking.status == ConfirmedBookingStatus.inProgress;
    final isCompleted = booking.status == ConfirmedBookingStatus.completed;
    final isCancelled = booking.status == ConfirmedBookingStatus.cancelled;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.burgundyLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${booking.bookingNumber}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.burgundy,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      StatusBadge(
                        label: isOngoing
                            ? 'قيد التنفيذ'
                            : (isCompleted
                                ? 'مكتمل'
                                : (isCancelled ? 'ملغي' : 'مؤكد')),
                        type: isOngoing
                            ? StatusBadgeType.inProgress
                            : (isCompleted
                                ? StatusBadgeType.completed
                                : (isCancelled ? StatusBadgeType.cancelled : StatusBadgeType.confirmed)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Profile Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.burgundy,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                booking.customerName.substring(0, 1),
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: Colors.white,
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
                                Text(
                                  booking.customerName,
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  booking.customerPhone,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontFamily: 'monospace',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking.customerLocation,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Booking Details Grid
                    Text(
                      'بيانات الحجز والفعالية',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'الخدمة المطلوبة',
                            booking.serviceName,
                            isPrimary: true,
                          ),
                          const Divider(height: 18),
                          _buildDetailRow('نوع المناسبة', booking.eventType),
                          const Divider(height: 18),
                          _buildDetailRow('تاريخ المناسبة', booking.eventDateString),
                          const Divider(height: 18),
                          _buildDetailRow('توقيت الفعالية', booking.eventTime),
                          const Divider(height: 18),
                          _buildDetailRow(
                            'المبلغ الإجمالي',
                            '${booking.totalAmount.toStringAsFixed(0)} ر.ي',
                            isHighlight: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Notes / Execution Instructions
                    Text(
                      'الملاحظات والتعليمات',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        booking.notes.isNotEmpty ? booking.notes : 'لا توجد ملاحظات إضافية لهذا الحجز.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isCancelled && !isCompleted)
                    CustomButton(
                      text: 'إلغاء الحجز',
                      variant: ButtonVariant.danger,
                      onPressed: () {
                        Navigator.pop(context);
                        onCancelBooking();
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      CustomButton(
                        text: 'إغلاق',
                        variant: ButtonVariant.ghost,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      if (isOngoing && onCompleteBooking != null)
                        CustomButton(
                          text: 'إتمام وتسليم الخدمة',
                          icon: Icons.check_circle_outline,
                          variant: ButtonVariant.primary,
                          onPressed: () {
                            Navigator.pop(context);
                            onCompleteBooking!();
                          },
                        )
                      else if (!isCancelled && !isCompleted && !isOngoing)
                        CustomButton(
                          text: 'بدء التنفيذ',
                          icon: Icons.play_arrow,
                          variant: ButtonVariant.primary,
                          onPressed: () {
                            Navigator.pop(context);
                            onStartExecution();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: isHighlight
                ? AppColors.burgundy
                : (isPrimary ? AppColors.textPrimary : AppColors.textSecondary),
            fontWeight: isHighlight || isPrimary ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}