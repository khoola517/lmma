import 'package:flutter/material.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/status_badge.dart';
import 'package:khadematy_web/provider/services/models/service_model.dart';
import 'service_image_carousel.dart';

class ServiceDetailsDialog extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;

  const ServiceDetailsDialog({
    super.key,
    required this.service,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.burgundyLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline, color: AppColors.burgundy, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'تفاصيل الخدمة',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
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
                    // Main Image Carousel with Interactive Arrows & Gallery
                    ServiceImageCarousel(
                      imageUrls: service.imageUrls,
                      height: 240,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    const SizedBox(height: 20),

                    // Title & Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  StatusBadge(
                                    label: service.category,
                                    type: StatusBadgeType.gold,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'المناسبة: ${service.occasion}',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: service.isAvailable ? 'متاحة للحجز' : 'غير متاحة',
                          type: service.isAvailable
                              ? StatusBadgeType.active
                              : StatusBadgeType.inactive,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Price & Execution Details Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'السعر الإجمالي',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service.price.toStringAsFixed(0)} ر.ي',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 36, color: AppColors.border),
                          Column(
                            children: [
                              Text(
                                'مدة التنفيذ والتجهيز',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service.executionTimeHours} ساعات',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'الوصف التفصيلي للخدمة',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            // Actions Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'إغلاق',
                    variant: ButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    text: 'تعديل الخدمة',
                    icon: Icons.edit,
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}