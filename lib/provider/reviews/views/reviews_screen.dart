import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/core/widgets/custom_text_field.dart';
import 'package:khadematy_web/provider/reviews/models/review_model.dart';
import 'package:khadematy_web/provider/reviews/providers/reviews_provider.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {

  void _showReplyDialog(BuildContext context, ReviewModel review) {
    final controller = TextEditingController(text: review.providerReply ?? '');
    final reviewsProvider = context.read<ReviewsProvider>();
    final isEditing =
        review.providerReply != null && review.providerReply!.trim().isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppColors.cardBg,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.burgundyLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.rate_review_outlined,
                        color: AppColors.burgundy, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'تعديل الرد على تقييم ${review.customerName}'
                          : 'الرد على تقييم ${review.customerName}',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Review Summary snippet
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review.serviceName,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: AppColors.gold),
                                  const SizedBox(width: 3),
                                  Text(
                                    review.rating.toStringAsFixed(1),
                                    style: AppTextStyles.labelSmall
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (review.comment.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '"${review.comment}"',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: 'نص الرد الرسمي من مقدم الخدمة',
                      hint:
                          'اكتب رداً مهنياً وودوداً للعميل يعكس احترافية خدماتكم...',
                      controller: controller,
                      maxLines: 4,
                      isRequired: true,
                    ),
                  ],
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: Text('إلغاء', style: AppTextStyles.labelMedium),
                ),
                CustomButton(
                  text: isEditing ? 'حفظ التعديل' : 'إرسال الرد',
                  isLoading: isSubmitting,
                  variant: ButtonVariant.primary,
                  onPressed: () async {
                    final replyText = controller.text.trim();
                    if (replyText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى كتابة نص الرد قبل الإرسال'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    setDialogState(() => isSubmitting = true);
                    final success = await reviewsProvider.replyToReview(
                      reviewId: review.id,
                      replyText: replyText,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(ctx);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing
                              ? 'تم تعديل الرد وحفظه في Supabase بنجاح'
                              : 'تم إرسال الرد وتوثيقه في Supabase بنجاح'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              reviewsProvider.errorMessage ?? 'تعذر حفظ الرد'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteReplyConfirmDialog(BuildContext context, ReviewModel review) {
    final reviewsProvider = context.read<ReviewsProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: AppColors.cardBg,
        title: const Text('حذف الرد على التقييم'),
        content: const Text(
            'هل أنت متأكد من رغبتك في حذف ردك الرسمي على هذا التقييم؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: AppTextStyles.labelMedium),
          ),
          CustomButton(
            text: 'حذف الرد',
            variant: ButtonVariant.outline,
            height: 38,
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await reviewsProvider.deleteReply(review.id);
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الرد بنجاح من Supabase'),
                    backgroundColor: AppColors.burgundy,
                    behavior: SnackBarBehavior.floating,
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
    final provider = context.watch<ReviewsProvider>();
    final reviews = provider.reviews;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeader(context, provider),

          const SizedBox(height: 24),

          // Error Banner (if any)
          if (provider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                  CustomButton(
                    text: 'إعادة المحاولة',
                    variant: ButtonVariant.ghost,
                    height: 34,
                    onPressed: () => provider.loadReviews(force: true),
                  ),
                ],
              ),
            ),
          ],

          // 4 Stats Cards
          _buildStatsCards(provider),

          const SizedBox(height: 24),

          // Rating Breakdown and Filter Toolbar
          _buildRatingBreakdownAndFilters(context, provider),

          const SizedBox(height: 20),

          // Reviews Content Area
          if (provider.isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.burgundy),
                    SizedBox(height: 16),
                    Text('جاري مزامنة البيانات')
                  ],
                ),
              ),
            ),
          ] else if (reviews.isEmpty) ...[
            _buildEmptyState(context, provider),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final r = reviews[index];
                return _buildReviewCard(context, r, provider);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReviewsProvider provider) {
    return const ProviderPageHeaderCard(
      title: 'التقييمات والمراجعات',
      subtitle:
          'تقييمات العملاء الموثقة المسجلة في Supabase ومستوى رضاهم عن الخدمات المقدمة والردود',
      icon: Icons.rate_review_outlined,
    );
  }

  Widget _buildStatsCards(ReviewsProvider provider) {
    return ProviderStatsRow(
      cards: [
        ProviderMetricCard(
          title: 'متوسط التقييم العام',
          value: provider.totalReviewsCount > 0
              ? '${provider.averageRating} ★'
              : '—',
          subText: provider.totalReviewsCount > 0
              ? 'من أصل 5.0 نجوم'
              : 'لا توجد تقييمات',
          subTextColor: AppColors.goldDark,
          icon: Icons.star_rate_rounded,
          iconBg: AppColors.goldLight,
          iconColor: AppColors.goldDark,
        ),
        ProviderMetricCard(
          title: 'إجمالي التقييمات',
          value: '${provider.totalReviewsCount}',
          subText: 'تقييم موثق',
          icon: Icons.reviews_outlined,
          iconBg: const Color(0xFFFBEAEA),
          iconColor: const Color(0xFF681729),
        ),
        ProviderMetricCard(
          title: 'تقييمات 5 نجوم',
          value: '${provider.fiveStarCount}',
          subText: 'أعلى درجات الرضا',
          subTextColor: AppColors.success,
          icon: Icons.sentiment_very_satisfied,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
        ),
        ProviderMetricCard(
          title: 'الخدمات المقيمة',
          value: '${provider.reviewedServicesCount}',
          subText: 'خدمات مقيمة',
          icon: Icons.room_service_outlined,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
        ),
      ],
    );
  }

  Widget _buildRatingBreakdownAndFilters(
      BuildContext context, ReviewsProvider provider) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips and Search
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildFilterChip(
                      label: 'كافة التقييمات (${provider.totalReviewsCount})',
                      isSelected: provider.ratingFilter == null &&
                          provider.replyFilter == ReviewReplyFilter.all,
                      onTap: () {
                        provider.setRatingFilter(null);
                        provider.setReplyFilter(ReviewReplyFilter.all);
                      },
                    ),
                    _buildFilterChip(
                      label: '★ 5 نجوم (${provider.fiveStarCount})',
                      isSelected: provider.ratingFilter == 5.0,
                      onTap: () => provider.setRatingFilter(
                          provider.ratingFilter == 5.0 ? null : 5.0),
                    ),
                    _buildFilterChip(
                      label: '★ 4 نجوم (${provider.fourStarCount})',
                      isSelected: provider.ratingFilter == 4.0,
                      onTap: () => provider.setRatingFilter(
                          provider.ratingFilter == 4.0 ? null : 4.0),
                    ),
                    _buildFilterChip(
                      label:
                          '★ 3 نجوم فما دون (${provider.threeStarCount + provider.twoStarCount + provider.oneStarCount})',
                      isSelected: provider.ratingFilter == 3.0,
                      onTap: () => provider.setRatingFilter(
                          provider.ratingFilter == 3.0 ? null : 3.0),
                    ),
                    _buildFilterChip(
                      label: 'بانتظار الرد (${provider.pendingRepliesCount})',
                      isSelected:
                          provider.replyFilter == ReviewReplyFilter.pending,
                      color: AppColors.burgundy,
                      onTap: () {
                        if (provider.replyFilter == ReviewReplyFilter.pending) {
                          provider.setReplyFilter(ReviewReplyFilter.all);
                        } else {
                          provider.setReplyFilter(ReviewReplyFilter.pending);
                        }
                      },
                    ),
                    _buildFilterChip(
                      label: 'تم الرد عليها',
                      isSelected:
                          provider.replyFilter == ReviewReplyFilter.replied,
                      color: AppColors.success,
                      onTap: () {
                        if (provider.replyFilter == ReviewReplyFilter.replied) {
                          provider.setReplyFilter(ReviewReplyFilter.all);
                        } else {
                          provider.setReplyFilter(ReviewReplyFilter.replied);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Service Dropdown Filter (if there are multiple services)
          if (provider.availableServicesWithReviews.length > 1) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('تصفية حسب الخدمة: ',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: provider.selectedServiceId,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  hint: Text('جميع الخدمات', style: AppTextStyles.labelSmall),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child:
                          Text('جميع الخدمات', style: AppTextStyles.labelSmall),
                    ),
                    ...provider.availableServicesWithReviews.map(
                      (s) => DropdownMenuItem<String?>(
                        value: s['id'],
                        child:
                            Text(s['name']!, style: AppTextStyles.labelSmall),
                      ),
                    ),
                  ],
                  onChanged: (val) => provider.setServiceFilter(val),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.burgundy;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(
      BuildContext context, ReviewModel review, ReviewsProvider provider) {
    final hasReply =
        review.providerReply != null && review.providerReply!.trim().isNotEmpty;
    final initialLetter = review.customerName.isNotEmpty
        ? review.customerName.substring(0, 1)
        : 'ع';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Name + Rating Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipOval(
                      child: review.customerAvatar.isNotEmpty
                          ? Image.network(
                              review.customerAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  _buildAvatarFallback(initialLetter),
                            )
                          : _buildAvatarFallback(initialLetter),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.customerName,
                            style: AppTextStyles.labelLarge
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified,
                                    size: 12, color: AppColors.success),
                                const SizedBox(width: 3),
                                Text(
                                  'عميل موثق',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review.date,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              // Stars & numeric rating
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: i < review.rating.floor()
                          ? AppColors.gold
                          : AppColors.border,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldBorder),
                    ),
                    child: Text(
                      review.rating.toStringAsFixed(1),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Service Pill Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.room_service,
                    size: 14, color: AppColors.burgundy),
                const SizedBox(width: 6),
                Text(
                  review.serviceName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              review.comment,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],

          // Provider Reply (if present)
          if (hasReply) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.burgundyLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.burgundyLightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.reply,
                              size: 18, color: AppColors.burgundy),
                          const SizedBox(width: 6),
                          Text(
                            'رد مقدم الخدمة الرسمي:',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.burgundy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _showReplyDialog(context, review),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined,
                                      size: 14, color: AppColors.burgundy),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تعديل',
                                    style: AppTextStyles.labelSmall
                                        .copyWith(color: AppColors.burgundy),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () =>
                                _showDeleteReplyConfirmDialog(context, review),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline,
                                      size: 14, color: AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(
                                    'حذف',
                                    style: AppTextStyles.labelSmall
                                        .copyWith(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
          const SizedBox(height: 8),

          // Action row (Reply Button if not replied yet)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'معرف التقييم: ${review.id.length > 8 ? review.id.substring(0, 8) : review.id}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 10),
              ),
              if (!hasReply)
                CustomButton(
                  text: 'الرد على التقييم',
                  icon: Icons.reply,
                  variant: ButtonVariant.ghost,
                  height: 36,
                  onPressed: () => _showReplyDialog(context, review),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String initial) {
    return Container(
      color: AppColors.burgundyLight,
      child: Center(
        child: Text(
          initial,
          style:
              AppTextStyles.headlineSmall.copyWith(color: AppColors.burgundy),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReviewsProvider provider) {
    final isFiltered = provider.ratingFilter != null ||
        provider.replyFilter != ReviewReplyFilter.all ||
        provider.selectedServiceId != null ||
        provider.searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                size: 38,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'لا توجد تقييمات مطابقة لمعايير البحث والتصفية'
                  : 'لا توجد تقييمات مسجلة حتى الآن',
              style: AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'جرّب تغيير فلاتر التقييم أو تفريغ نص البحث للعثور على النتائج'
                  : 'ستظهر تقييمات وآراء عملائك الموثقة من Supabase هنا عند اكتمال الحجوزات',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            if (isFiltered)
              CustomButton(
                text: 'إعادة تعيين الفلاتر',
                icon: Icons.clear_all,
                variant: ButtonVariant.outline,
                onPressed: () {
                  provider.clearFilters();
                },
              ),
          ],
        ),
      ),
    );
  }
}
