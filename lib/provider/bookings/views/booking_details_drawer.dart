import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/status_badge.dart';
import 'package:khadematy_web/provider/bookings/models/confirmed_booking_model.dart';

class BookingDetailsDrawer extends StatefulWidget {
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
  State<BookingDetailsDrawer> createState() => _BookingDetailsDrawerState();
}

class _BookingDetailsDrawerState extends State<BookingDetailsDrawer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isOngoing = booking.status == ConfirmedBookingStatus.inProgress;
    final isCompleted = booking.status == ConfirmedBookingStatus.completed;
    final isCancelled = booking.status == ConfirmedBookingStatus.cancelled;

    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.88,
          maxWidth: 620,
        ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                                : (isCancelled
                                    ? StatusBadgeType.cancelled
                                    : StatusBadgeType.confirmed)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content Area with Visible Scrollbar
            Flexible(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Visual Tracking Stepper (مراحل متابعة وتنفيذ الحجز)
                      _buildTrackingStepper(booking),

                      const SizedBox(height: 20),

                      // 2. Customer Profile Box with Direct Contact
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.burgundy,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      booking.customerName.trim().isNotEmpty
                                          ? booking.customerName
                                              .trim()
                                              .substring(0, 1)
                                          : 'ع',
                                      style:
                                          AppTextStyles.headlineSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.customerName,
                                        style: AppTextStyles.headlineSmall
                                            .copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
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
                                        textDirection: TextDirection.ltr,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.customerLocation,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. Booking Details Grid
                      Text(
                        'بيانات الحجز والفعالية',
                        style: AppTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w800),
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
                            _buildDetailRow(
                                'تاريخ المناسبة', booking.eventDateString),
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

                      // 4. Notes / Execution Instructions
                      Text(
                        'الملاحظات والتعليمات',
                        style: AppTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w800),
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
                          booking.notes.isNotEmpty
                              ? booking.notes
                              : 'لا توجد ملاحظات إضافية لهذا الحجز.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
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
                      icon: Icons.cancel_outlined,
                      variant: ButtonVariant.danger,
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onCancelBooking();
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
                      if (isOngoing && widget.onCompleteBooking != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onCompleteBooking!();
                          },
                          icon: const Icon(Icons.check_circle_rounded,
                              size: 18, color: Colors.white),
                          label: Text(
                            'إتمام وتسليم الخدمة',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      else if (!isCancelled && !isCompleted && !isOngoing)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onStartExecution();
                          },
                          icon: const Icon(Icons.play_arrow_rounded,
                              size: 18, color: Colors.white),
                          label: Text(
                            'بدء التنفيذ',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF681729),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      else if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded,
                                  size: 16, color: Color(0xFF059669)),
                              const SizedBox(width: 6),
                              Text(
                                'الخدمة مكتملة ومسلّمة',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
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

  // 1. Visual Tracking Stepper Widget
  Widget _buildTrackingStepper(ConfirmedBookingModel booking) {
    final isConfirmed = booking.status == ConfirmedBookingStatus.confirmed;
    final isOngoing = booking.status == ConfirmedBookingStatus.inProgress;
    final isCompleted = booking.status == ConfirmedBookingStatus.completed;
    final isCancelled = booking.status == ConfirmedBookingStatus.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined,
                color: Color(0xFFDC2626), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الحجز ملغي',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                  Text(
                    'تم إلغاء هذا الحجز مسبقاً ولا يتطلب أي إجراءات أو تنفيذ حالياً.',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Stages: 1. Confirmed -> 2. In Progress -> 3. Completed
    final step1Done = isOngoing || isCompleted;
    final step2Active = isOngoing;
    final step2Done = isCompleted;
    final step3Done = isCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مراحل متابعة وتنفيذ الحجز',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFECFDF5)
                      : (isOngoing
                          ? const Color(0xFFFEF9C3)
                          : const Color(0xFFEFF6FF)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFFA7F3D0)
                        : (isOngoing
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFBFDBFE)),
                  ),
                ),
                child: Text(
                  isCompleted
                      ? 'مكتمل بنجاح'
                      : (isOngoing ? 'جاري التنفيذ' : 'بانتظار البدء'),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF059669)
                        : (isOngoing
                            ? const Color(0xFFD97706)
                            : const Color(0xFF2563EB)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Step 1: تم التأكيد
              _buildStepItem(
                title: 'تأكيد الحجز',
                subtitle: 'معتمد وجاهز',
                isDone: step1Done,
                isActive: isConfirmed,
                icon: Icons.check_circle_rounded,
              ),

              // Connector 1 -> 2
              Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: (step2Active || step2Done)
                        ? const Color(0xFF681729)
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Step 2: قيد التنفيذ
              _buildStepItem(
                title: 'بدء التنفيذ',
                subtitle: isOngoing
                    ? 'جاري العمل'
                    : (step2Done ? 'تم الإنجاز' : 'في الانتظار'),
                isDone: step2Done,
                isActive: step2Active,
                icon: step2Done
                    ? Icons.check_circle_rounded
                    : (step2Active
                        ? Icons.timelapse_rounded
                        : Icons.radio_button_unchecked),
              ),

              // Connector 2 -> 3
              Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: step3Done
                        ? const Color(0xFF059669)
                        : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Step 3: إتمام وتسليم
              _buildStepItem(
                title: 'التسليم النهائي',
                subtitle: step3Done ? 'تم التسليم' : 'المرحلة الأخيرة',
                isDone: step3Done,
                isActive: false,
                icon: step3Done
                    ? Icons.task_alt_rounded
                    : Icons.radio_button_unchecked,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    required IconData icon,
  }) {
    Color circleBg;
    Color iconColor;
    Color titleColor;

    if (isDone) {
      circleBg = const Color(0xFF059669);
      iconColor = Colors.white;
      titleColor = const Color(0xFF059669);
    } else if (isActive) {
      circleBg = const Color(0xFF681729);
      iconColor = Colors.white;
      titleColor = const Color(0xFF681729);
    } else {
      circleBg = const Color(0xFFF3F4F6);
      iconColor = const Color(0xFF9CA3AF);
      titleColor = const Color(0xFF6B7280);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            boxShadow: (isActive || isDone)
                ? [
                    BoxShadow(
                      color: circleBg.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 9.5,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isPrimary = false, bool isHighlight = false}) {
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
            fontWeight:
                isHighlight || isPrimary ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
