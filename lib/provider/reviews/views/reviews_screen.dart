import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_text_field.dart';
import 'package:khadematy_web/provider/reviews/models/review_model.dart';
import 'package:khadematy_web/provider/reviews/providers/reviews_provider.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';
import 'package:khadematy_web/provider/shell/views/provider_filter_chip.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

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
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: AppTextStyles.labelMedium),
              ),
            ],
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

    // Pagination calculations (5 reviews per page matching bookings table)
    final totalFiltered = reviews.length;
    final totalPages =
        totalFiltered == 0 ? 1 : ((totalFiltered - 1) ~/ _itemsPerPage) + 1;
    final safePage = _currentPage.clamp(1, totalPages);
    final startIndex = (safePage - 1) * _itemsPerPage;
    final pageReviews =
        reviews.skip(startIndex).take(_itemsPerPage).toList();
    final endIndex = (startIndex + pageReviews.length);

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
            _buildReviewsTable(
              context,
              pageReviews,
              provider,
              totalFiltered: totalFiltered,
              safePage: safePage,
              totalPages: totalPages,
              startIndex: startIndex,
              endIndex: endIndex,
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
          'تقييمات العملاء الموثقة المسجلة في قاعدة البيانات ومستوى رضاهم عن الخدمات المقدمة والردود',
      //icon: Icons.rate_review_outlined,
    );
  }

  Widget _buildStatsCards(ReviewsProvider provider) {
    return ProviderStatsRow(
      cards: [
        ProviderMetricCard(
          title: 'متوسط التقييم العام',
          value: provider.totalReviewsCount > 0
              ? '${provider.averageRating} ★'
              : '',
          // subText: provider.totalReviewsCount > 0
          //     ? 'من أصل 5.0 نجوم'
          //     : 'لا توجد تقييمات',
          subTextColor: AppColors.goldDark,
          icon: Icons.star_rate_rounded,
          iconBg: AppColors.goldLight,
          iconColor: AppColors.goldDark,
        ),
        ProviderMetricCard(
          title: 'إجمالي التقييمات',
          value: '${provider.totalReviewsCount}',
          //subText: 'تقييم موثق',
          icon: Icons.reviews_outlined,
          iconBg: const Color(0xFFFBEAEA),
          iconColor: const Color(0xFF681729),
        ),
        ProviderMetricCard(
          title: 'تقييمات 5 نجوم',
          value: '${provider.fiveStarCount}',
          //subText: 'أعلى درجات الرضا',
          subTextColor: AppColors.success,
          icon: Icons.sentiment_very_satisfied,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
        ),
        ProviderMetricCard(
          title: 'الخدمات المقيمة',
          value: '${provider.reviewedServicesCount}',
          //subText: 'خدمات مقيمة',
          icon: Icons.room_service_outlined,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
        ),
      ],
    );
  }

  Widget _buildRatingBreakdownAndFilters(
      BuildContext context, ReviewsProvider provider) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildFilterChip(
          label: 'كافة التقييمات (${provider.totalReviewsCount})',
          isSelected: provider.ratingFilter == null &&
              provider.replyFilter == ReviewReplyFilter.all,
          onTap: () {
            provider.setRatingFilter(null);
            provider.setReplyFilter(ReviewReplyFilter.all);
            setState(() => _currentPage = 1);
          },
        ),
        _buildFilterChip(
          label: '★ 5 نجوم (${provider.fiveStarCount})',
          isSelected: provider.ratingFilter == 5.0,
          onTap: () {
            provider.setRatingFilter(
                provider.ratingFilter == 5.0 ? null : 5.0);
            setState(() => _currentPage = 1);
          },
        ),
        _buildFilterChip(
          label: '★ 4 نجوم (${provider.fourStarCount})',
          isSelected: provider.ratingFilter == 4.0,
          onTap: () {
            provider.setRatingFilter(
                provider.ratingFilter == 4.0 ? null : 4.0);
            setState(() => _currentPage = 1);
          },
        ),
        _buildFilterChip(
          label:
              '★ 3 نجوم فما دون (${provider.threeStarCount + provider.twoStarCount + provider.oneStarCount})',
          isSelected: provider.ratingFilter == 3.0,
          onTap: () {
            provider.setRatingFilter(
                provider.ratingFilter == 3.0 ? null : 3.0);
            setState(() => _currentPage = 1);
          },
        ),
        _buildFilterChip(
          label: 'بانتظار الرد (${provider.pendingRepliesCount})',
          isSelected: provider.replyFilter == ReviewReplyFilter.pending,
          color: const Color(0xFFD97706),
          onTap: () {
            if (provider.replyFilter == ReviewReplyFilter.pending) {
              provider.setReplyFilter(ReviewReplyFilter.all);
            } else {
              provider.setReplyFilter(ReviewReplyFilter.pending);
            }
            setState(() => _currentPage = 1);
          },
        ),
        _buildFilterChip(
          label: 'تم الرد عليها',
          isSelected: provider.replyFilter == ReviewReplyFilter.replied,
          color: AppColors.success,
          onTap: () {
            if (provider.replyFilter == ReviewReplyFilter.replied) {
              provider.setReplyFilter(ReviewReplyFilter.all);
            } else {
              provider.setReplyFilter(ReviewReplyFilter.replied);
            }
            setState(() => _currentPage = 1);
          },
        ),
        SizedBox(width: 10,),

        // Service Dropdown Filter (inline next to "تم الرد عليها")
        if (provider.availableServicesWithReviews.length > 1)
          Container(
            height: 41,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: provider.selectedServiceId != null
                    ? AppColors.primary
                    : AppColors.borderDark,
                width: provider.selectedServiceId != null ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   'تصفية حسب الخدمة: ',
                //   style: GoogleFonts.cairo(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w700,
                //     color: AppColors.textSecondary,
                //   ),
                // ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: provider.selectedServiceId,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color:AppColors.primary ),
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A3E44),
                    ),
                    hint: Text(
                      'جميع الخدمات',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A3E44),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'جميع الخدمات',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...provider.availableServicesWithReviews.map(
                        (s) => DropdownMenuItem<String?>(
                          value: s['id'],
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              s['name']!,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      provider.setServiceFilter(val);
                      setState(() => _currentPage = 1);
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ProviderFilterChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      activeColor: color,
    );
  }

  Widget _buildReviewsTable(
    BuildContext context,
    List<ReviewModel> pageReviews,
    ReviewsProvider provider, {
    required int totalFiltered,
    required int safePage,
    required int totalPages,
    required int startIndex,
    required int endIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth =
                constraints.maxWidth < 920 ? 920.0 : constraints.maxWidth;
            return Column(
              children: [
                Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: constraints.maxWidth < 920,
                  trackVisibility: constraints.maxWidth < 920,
                  interactive: true,
                  thickness: 7,
                  radius: const Radius.circular(4),
                  child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAF8F5),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFEBE6DF)),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTableHeader('العميل', flex: 17),
                            _buildTableHeader('الخدمة', flex: 15),
                            _buildTableHeader('التقييم', flex: 11),
                            _buildTableHeader('تعليق العميل', flex: 20),
                            _buildTableHeader('الرد الرسمي', flex: 15),
                            _buildTableHeader('تاريخ التقييم', flex: 9),
                            _buildTableHeader('الإجراءات',
                                flex: 13, textAlign: TextAlign.center),
                          ],
                        ),
                      ),

                    // Table Rows (5 reviews per page)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pageReviews.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      itemBuilder: (context, index) {
                        final r = pageReviews[index];
                        return _buildTableRow(context, r, index, provider);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Table Footer / Pagination Bar (Matching confirmed_bookings_screen design)
          _buildPaginationBar(
            totalFiltered: totalFiltered,
            startIndex: startIndex,
            endIndex: endIndex,
            safePage: safePage,
            totalPages: totalPages,
          ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaginationBar({
    required int totalFiltered,
    required int startIndex,
    required int endIndex,
    required int safePage,
    required int totalPages,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFAF7),
        border: Border(
          top: BorderSide(color: Color(0xFFEBE6DF)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Showing X - Y of Z reviews (Right side in RTL)
          Text(
            totalFiltered == 0
                ? 'عرض 0 من إجمالي 0 تقييم'
                : 'عرض ${startIndex + 1} - $endIndex من إجمالي $totalFiltered تقييم',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8A7F84),
            ),
          ),

          // Pagination Controls (Left side in RTL)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous Button
              OutlinedButton(
                onPressed:
                    safePage > 1 ? () => setState(() => _currentPage--) : null,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'السابق',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: safePage > 1
                        ? const Color(0xFF4B5563)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Page Numbers (Golden Yellow active button with white text)
              for (int p = 1; p <= totalPages; p++) ...[
                InkWell(
                  onTap: () => setState(() => _currentPage = p),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: safePage == p
                          ? const Color(0xFFFCC201)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: safePage == p
                            ? const Color(0xFFFCC201)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      '$p',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: safePage == p
                            ? Colors.white
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
                if (p < totalPages) const SizedBox(width: 6),
              ],

              const SizedBox(width: 8),

              // Next Button
              OutlinedButton(
                onPressed: safePage < totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'التالي',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: safePage < totalPages
                        ? const Color(0xFF4B5563)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title,
      {required int flex, TextAlign textAlign = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: textAlign,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8C7B83),
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ReviewModel review, int index,
      ReviewsProvider provider) {
    final hasReply =
        review.providerReply != null && review.providerReply!.trim().isNotEmpty;
    final initialLetter = review.customerName.isNotEmpty
        ? review.customerName.substring(0, 1)
        : 'ع';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. العميل (الاسم + الصورة + بادج التوثيق)
          Expanded(
            flex: 17,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEBE6DF)),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        review.customerName,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2327),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              size: 10, color: AppColors.success),
                          const SizedBox(width: 2),
                          Text(
                            'عميل موثق',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
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

          // 2. الخدمة المقيمة
          Expanded(
            flex: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  review.serviceName,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2327),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.room_service_outlined,
                          size: 11, color: AppColors.burgundy),
                      const SizedBox(width: 3),
                      Text(
                        'خدمة محجوزة',
                        style: GoogleFonts.cairo(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.burgundy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. التقييم
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.rating.floor()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 13.5,
                    );
                  }),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.goldBorder),
                  ),
                  child: Text(
                    '${review.rating.toStringAsFixed(1)} ★',
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. تعليق العميل
          Expanded(
            flex: 20,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                review.comment.isNotEmpty
                    ? review.comment
                    : 'لا يوجد تعليق مكتوب من العميل',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  color: review.comment.isNotEmpty
                      ? const Color(0xFF4A3E44)
                      : const Color(0xFFB0A4A7),
                  fontStyle: review.comment.isEmpty ? FontStyle.italic : null,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // 5. الرد الرسمي
          Expanded(
            flex: 15,
            child: hasReply
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.burgundyLight,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: AppColors.burgundyLightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 11, color: AppColors.success),
                            const SizedBox(width: 3),
                            Text(
                              'تم الرد',
                              style: GoogleFonts.cairo(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          review.providerReply!,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: const Color(0xFF2D2327),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 11, color: Color(0xFFD97706)),
                        const SizedBox(width: 3),
                        Text(
                          'بانتظار الرد',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // 6. تاريخ التقييم
          Expanded(
            flex: 9,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 12, color: Color(0xFF8C7B83)),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    review.date,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF8C7B83),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 7. الإجراءات (ظاهرة ومحاذاة بالكامل ومحمية من التجاوز)
          Expanded(
            flex: 13,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // زر الرد الرسمي / تعديل الرد
                    if (!hasReply)
                      Tooltip(
                        message: 'إضافة رد رسمي على التقييم',
                        child: InkWell(
                          onTap: () => _showReplyDialog(context, review),
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withOpacity(0.35),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.reply_rounded,
                                    size: 13, color: Colors.white),
                                const SizedBox(width: 3),
                                Text(
                                  'رد',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else ...[
                      // زر تعديل الرد
                      Tooltip(
                        message: 'تعديل الرد الرسمي',
                        child: InkWell(
                          onTap: () => _showReplyDialog(context, review),
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBEAEA),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: const Color(0xFFF3D5D9)),
                            ),
                            child: const Center(
                              child: Icon(Icons.edit_outlined,
                                  size: 15, color: Color(0xFF681729)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // زر حذف الرد
                      Tooltip(
                        message: 'حذف الرد الرسمي',
                        child: InkWell(
                          onTap: () =>
                              _showDeleteReplyConfirmDialog(context, review),
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: const Center(
                              child: Icon(Icons.delete_outline_rounded,
                                  size: 15, color: Color(0xFFDC2626)),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(width: 4),

                    // زر عرض تفاصيل التقييم
                    Tooltip(
                      message: 'عرض تفاصيل التقييم',
                      child: InkWell(
                        onTap: () => _showReviewDetailsDialog(context, review),
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF8F5),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFEBE6DF)),
                          ),
                          child: const Center(
                            child: Icon(Icons.visibility_outlined,
                                size: 15, color: Color(0xFF4B5563)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDetailsDialog(BuildContext context, ReviewModel review) {
    final hasReply =
        review.providerReply != null && review.providerReply!.trim().isNotEmpty;
    final initialLetter = review.customerName.isNotEmpty
        ? review.customerName.substring(0, 1)
        : 'ع';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.burgundyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rate_review_outlined,
                  color: AppColors.burgundy, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تفاصيل تقييم العميل',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2327),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer & Service Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEBE6DF)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                review.customerName,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2D2327),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.successBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'عميل موثق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الخدمة: ${review.serviceName} • ${review.date}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: const Color(0xFF8C7B83),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rating Stars
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating.floor()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldBorder),
                    ),
                    child: Text(
                      '${review.rating.toStringAsFixed(1)} من 5.0',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Comment
              Text(
                'تعليق العميل:',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A3E44),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEBE6DF)),
                ),
                child: Text(
                  review.comment.isNotEmpty
                      ? review.comment
                      : 'لم يكتب العميل تعليقاً نصياً، واكتفى بالتقييم بالنجوم.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    height: 1.6,
                    color: review.comment.isNotEmpty
                        ? const Color(0xFF2D2327)
                        : const Color(0xFF8C7B83),
                  ),
                ),
              ),

              // Provider Reply (if present)
              if (hasReply) ...[
                const SizedBox(height: 16),
                Text(
                  'ردك الرسمي:',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.burgundy,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.burgundyLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.burgundyLightBorder),
                  ),
                  child: Text(
                    review.providerReply!,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      height: 1.6,
                      color: const Color(0xFF2D2327),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إغلاق',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8C7B83),
              ),
            ),
          ),
          if (!hasReply)
            CustomButton(
              text: 'الرد على التقييم',
              icon: Icons.reply,
              height: 38,
              onPressed: () {
                Navigator.pop(ctx);
                _showReplyDialog(context, review);
              },
            )
          else
            CustomButton(
              text: 'تعديل الرد',
              icon: Icons.edit_outlined,
              height: 38,
              variant: ButtonVariant.outline,
              onPressed: () {
                Navigator.pop(ctx);
                _showReplyDialog(context, review);
              },
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
                  setState(() => _currentPage = 1);
                },
              ),
          ],
        ),
      ),
    );
  }
}
