import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/review_model.dart';
import '../../../providers/profile_provider.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  void _showReplyDialog(BuildContext context, ReviewModel review, ProfileProvider provider) {
    final controller = TextEditingController(text: review.providerReply ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardBg,
        title: Text('الرد على تقييم ${review.customerName}', style: AppTextStyles.headlineSmall),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التعليق: "${review.comment}"',
                style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'نص الرد الرسمي من مقدم الخدمة',
                hint: 'اكتب رداً مهنياً وودوداً للعميل...',
                controller: controller,
                maxLines: 3,
                isRequired: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: AppTextStyles.labelMedium),
          ),
          CustomButton(
            text: 'إرسال الرد',
            variant: ButtonVariant.primary,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.replyToReview(review.id, controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال الرد على التقييم بنجاح'),
                    backgroundColor: AppColors.burgundy,
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
    final profileProvider = context.watch<ProfileProvider>();
    final reviews = profileProvider.reviews;

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
                        'التقييمات والمراجعات',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.goldBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.goldDark),
                            const SizedBox(width: 4),
                            Text(
                              '4.9 مميز',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.goldDark,
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
                    'تابع آراء وتقييمات العملاء الموثقة وتعرّف على تفاصيل مستوى رضاهم عن خدماتك',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.thumb_up_alt_outlined, color: AppColors.success, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نسبة الرضا العامة',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          '98.4% تقييم إيجابي',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4 Stats Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.maxWidth > 900
                  ? (constraints.maxWidth - 48) / 4
                  : (constraints.maxWidth > 550 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth);
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: boxWidth,
                    child: _buildStatCard(
                      title: 'متوسط التقييم العام',
                      value: '4.9 ★',
                      subText: 'تقييم استثنائي',
                      color: AppColors.goldDark,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: _buildStatCard(
                      title: 'إجمالي التقييمات',
                      value: '${profileProvider.totalReviewsCount} تقييم',
                      subText: 'عملاء موثقون',
                      color: AppColors.burgundy,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: _buildStatCard(
                      title: 'تقييمات 5 نجوم',
                      value: '${profileProvider.fiveStarCount} تقييم',
                      subText: 'أعلى درجات الرضا',
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: _buildStatCard(
                      title: 'الخدمات المقيمة',
                      value: '6 خدمات',
                      subText: 'تغطية شاملة',
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Filter Chips
          Row(
            children: [
              _buildFilterChip(context, 'كافة التقييمات', null, profileProvider),
              const SizedBox(width: 8),
              _buildFilterChip(context, '★ 5 نجوم', 5.0, profileProvider),
              const SizedBox(width: 8),
              _buildFilterChip(context, '★ 4 نجوم فما فوق', 4.0, profileProvider),
            ],
          ),

          const SizedBox(height: 20),

          // Reviews List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final r = reviews[index];
              return _buildReviewCard(context, r, profileProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subText,
    required Color color,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(subText, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    double? rating,
    ProfileProvider provider,
  ) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (_) => provider.setRatingFilter(rating),
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewModel review, ProfileProvider provider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        review.customerAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.burgundyLight,
                          child: Center(
                            child: Text(
                              review.customerName.substring(0, 1),
                              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.burgundy),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        review.date,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 16,
                      color: i < review.rating.floor() ? AppColors.gold : AppColors.border,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.burgundy,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'الخدمة: ${review.serviceName}',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.burgundy, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            review.comment,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.6),
          ),

          // Provider Reply (if present)
          if (review.providerReply != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.burgundyLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.burgundyLightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply, size: 16, color: AppColors.burgundy),
                      const SizedBox(width: 6),
                      Text(
                        'رد مقدم الخدمة الرسمي:',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.burgundy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.providerReply!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                text: review.providerReply != null ? 'تعديل الرد' : 'الرد على التقييم',
                icon: Icons.reply,
                variant: ButtonVariant.ghost,
                height: 34,
                onPressed: () => _showReplyDialog(context, review, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
