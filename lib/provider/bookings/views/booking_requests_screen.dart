import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/core/widgets/status_badge.dart';
import 'package:khadematy_web/provider/bookings/models/booking_request_model.dart';
import 'package:khadematy_web/provider/bookings/providers/bookings_provider.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';
import 'package:khadematy_web/provider/profile/providers/profile_provider.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        context
            .read<BookingsProvider>()
            .loadBookings(providerId: auth.currentProviderId);
      }
    });
  }

  void _confirmRejectRequest(
    BuildContext context,
    BookingRequestModel req,
    BookingsProvider provider,
  ) {
    final reasonController = TextEditingController();

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
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text('تأكيد رفض طلب الحجز', style: AppTextStyles.headlineSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من رغبتك في الاعتذار عن تلبية طلب الحجز رقم ${req.code} للعميل ${req.customerName}؟',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'سبب الرفض (اختياري)',
                hintText: 'مثال: انشغال القاعة / عدم توفر الموعد',
                labelStyle: AppTextStyles.labelMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('تراجع', style: AppTextStyles.labelMedium),
          ),
          CustomButton(
            text: 'تأكيد الرفض',
            variant: ButtonVariant.danger,
            onPressed: () async {
              Navigator.pop(ctx);
              final reason = reasonController.text.trim();
              final success = await provider.rejectBookingRequest(
                req.id,
                reason: reason.isNotEmpty ? reason : null,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'تم رفض طلب حجز ${req.customerName}'
                          : 'تعذر رفض الطلب، يرجى المحاولة لاحقاً',
                    ),
                    backgroundColor:
                        success ? AppColors.error : AppColors.burgundy,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsProvider = context.watch<BookingsProvider>();
    final requests = bookingsProvider.pendingRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner Card with golden yellow gradient
          const ProviderPageHeaderCard(
            title: 'طلبات الحجز الجديدة',
            subtitle:
                'راجع طلبات الحجز الواردة من العملاء وقم بالموافقة عليها أو تقديم عروضك قبل انتهاء المهلة',
            //icon: Icons.mark_email_unread_outlined,
          ),

          const SizedBox(height: 24),

          // 2. 4 Metric Cards (Live from Supabase in a single horizontal row)
          ProviderStatsRow(
            cards: [
              ProviderMetricCard(
                title: 'طلبات بانتظار الرد',
                value: '${requests.length}',
                //subText: requests.isNotEmpty ? 'تحتاج إجراء' : 'تم الرد',
                subTextColor: requests.isNotEmpty
                    ? AppColors.burgundy
                    : AppColors.success,
                icon: Icons.mark_email_unread_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
              ),
              ProviderMetricCard(
                title: 'الحجوزات المؤكدة',
                value: '${bookingsProvider.totalConfirmedCount}',
                //subText: 'حجز معتمد',
                icon: Icons.check_circle_outline_rounded,
                iconBg: const Color(0xFFFBEAEA),
                iconColor: const Color(0xFF681729),
              ),
              ProviderMetricCard(
                title: 'معدل القبول',
                value: '${(bookingsProvider.acceptanceRate * 100).toInt()}%',
                // subText: 'نسبة القبول',
                icon: Icons.trending_up_rounded,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
              ),
              ProviderMetricCard(
                title: 'الإيرادات المحققة',
                value: '${bookingsProvider.totalRevenue.toInt()} ر.ي',
                //subText: 'مدفوعات مؤكدة',
                icon: Icons.payments_outlined,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Error banner if any
          // if (bookingsProvider.errorMessage != null) ...[
          //   Container(
          //     padding: const EdgeInsets.all(16),
          //     margin: const EdgeInsets.only(bottom: 20),
          //     decoration: BoxDecoration(
          //       color: AppColors.errorBg,
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: AppColors.error.withOpacity(0.3)),
          //     ),
          //     child: Row(
          //       children: [
          //         const Icon(Icons.error_outline, color: AppColors.error),
          //         const SizedBox(width: 12),
          //         Expanded(
          //           child: Text(
          //             bookingsProvider.errorMessage!,
          //             style: AppTextStyles.bodyMedium
          //                 .copyWith(color: AppColors.error),
          //           ),
          //         ),
          //         CustomButton(
          //           text: 'إعادة المحاولة',
          //           variant: ButtonVariant.danger,
          //           height: 36,
          //           onPressed: () => bookingsProvider.loadBookings(force: true),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],

          // Loading state
          if (bookingsProvider.isLoading && requests.isEmpty)
            CustomCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppColors.burgundy,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري جلب طلبات الحجز من السيرفر...',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          // Requests List
          else if (requests.isEmpty)
            CustomCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.mark_email_read_outlined,
                        size: 52, color: AppColors.goldDark),
                    const SizedBox(height: 14),
                    Text(
                      'لا توجد طلبات حجز معلقة حالياً',
                      style: AppTextStyles.headlineSmall
                          .copyWith(fontWeight: FontWeight.w700),
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
    final isProcessing = provider.isActionLoading(req.id);

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
                      child: req.customerAvatar.isNotEmpty
                          ? Image.network(
                              req.customerAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: AppColors.burgundyLight,
                                child: Center(
                                  child: Text(
                                    req.customerName.isNotEmpty
                                        ? req.customerName.substring(0, 1)
                                        : 'ع',
                                    style: AppTextStyles.headlineSmall.copyWith(
                                      color: AppColors.burgundy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.burgundyLight,
                              child: Center(
                                child: Text(
                                  req.customerName.isNotEmpty
                                      ? req.customerName.substring(0, 1)
                                      : 'ع',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: AppColors.burgundy,
                                    fontWeight: FontWeight.bold,
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
                        const Icon(Icons.location_on,
                            size: 15, color: AppColors.goldDark),
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
                        const Icon(Icons.schedule,
                            size: 15, color: AppColors.goldDark),
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
                  // Container(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.surfaceLow,
                  //     borderRadius: BorderRadius.circular(8),
                  //     border: Border.all(color: AppColors.border),
                  //   ),
                  //   child: Text(
                  //     req.code,
                  //     style: AppTextStyles.labelSmall.copyWith(
                  //       fontFamily: 'monospace',
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // 4 Grid Info Boxes
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = constraints.maxWidth > 700
                    ? (constraints.maxWidth - 36) / 4
                    : (constraints.maxWidth - 12) / 2;
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
                      label: "السعر",
                      value: '${req.budget.toStringAsFixed(0)} ر.ي',
                      valueColor: AppColors.burgundy,
                    ),
                  ],
                );
              },
            ),
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
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.burgundy),
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
                  req.notes.isNotEmpty
                      ? '"${req.notes}"'
                      : '"لا توجد ملاحظات إضافية من العميل"',
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
                text: isProcessing ? 'جاري المعالجة...' : 'قبول وتأكيد الحجز',
                icon: isProcessing ? null : Icons.check_circle_outline,
                variant: ButtonVariant.primary,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                onPressed: isProcessing
                    ? null
                    : () async {
                        final success =
                            await provider.acceptBookingRequest(req.id);
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
                                    ? 'تم قبول وتأكيد حجز ${req.customerName} بنجاح وإضافته إلى الحجوزات المؤكدة'
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
              const SizedBox(width: 12),
              CustomButton(
                text: 'رفض الطلب',
                icon: Icons.close,
                variant: ButtonVariant.danger,
                height: 40,
                onPressed: isProcessing
                    ? null
                    : () => _confirmRejectRequest(context, req, provider),
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
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textMuted),
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
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
