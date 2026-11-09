import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'package:khadematy_web/admin/shell/views/admin_stat_card.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  int? _starFilter; // null = all, 5, 4, 3, 2 (2 or less)
  String _statusFilter = 'all'; // 'all', 'visible', 'hidden'
  String _dateFilter = 'all'; // 'all', 'this_month', 'this_week'
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminDashboardProvider>().loadAllAdminData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // Format Arabic Date
  String _formatArabicDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'غير محدد';
    try {
      final dt = DateTime.parse(rawDate);
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ];
      final monthName = months[dt.month - 1];
      return '${dt.day} $monthName ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  void _showReviewDetailsModal(
      BuildContext context, Map<String, dynamic> r, bool isHidden) {
    final rating = (r['rating'] as num?)?.toDouble() ?? 5.0;
    final comment = r['comment']?.toString() ?? 'لا يوجد تعليق متاح';
    final providerReply = r['provider_reply']?.toString();
    final date = _formatArabicDate(r['created_at']?.toString());
    final reviewId = r['id'].toString();

    final cust = r['customer'] as Map<String, dynamic>?;
    final custName = cust?['full_name'] ?? 'عميل خِدمتي';
    final custPhone = cust?['phone'] ?? '-';
    final custEmail = cust?['email'] ?? '-';

    final srv = r['service'] as Map<String, dynamic>?;
    final srvName = srv?['name'] ?? 'خدمة مناسبات';
    final srvCategory =
        (srv?['category'] is Map ? srv!['category']['name'] : null) ??
            'تنسيق مناسبات';
    final providerName =
        (srv?['provider'] is Map ? srv!['provider']['business_name'] : null) ??
            'مقدم الخدمة';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.star_rounded,
                  color: Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل التقييم والمراجعة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2327),
                    ),
                  ),
                  Text(
                    'مراجعة محتوى التقييم والتحكم في ظهوره للعملاء',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF8C7B83),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(isHidden),
          ],
        ),
        content: SizedBox(
          width: 540,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),

                // Star Rating & Date Header Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 22,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '$rating / 5.0',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: const Color(0xFF2D2327),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        date,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF8C7B83),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Customer & Service Info
                _buildInfoRow('اسم العميل:', custName),
                const Divider(height: 14, color: Color(0xFFEFE9E2)),
                _buildInfoRow('هاتف العميل:', custPhone),
                const Divider(height: 14, color: Color(0xFFEFE9E2)),
                _buildInfoRow('البريد الإلكتروني:', custEmail),
                const Divider(height: 14, color: Color(0xFFEFE9E2)),
                _buildInfoRow('الخدمة المقيمة:', '$srvName ($srvCategory)'),
                const Divider(height: 14, color: Color(0xFFEFE9E2)),
                _buildInfoRow('مقدم الخدمة:', providerName),
                const SizedBox(height: 16),

                // Comment Box
                Text(
                  'نص تعليق العميل:',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2327),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9EE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE8BA)),
                  ),
                  child: Text(
                    comment,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      height: 1.6,
                      color: const Color(0xFF2D2327),
                    ),
                  ),
                ),

                if (providerReply != null && providerReply.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'رد مقدم الخدمة:',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF681729),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Text(
                      providerReply,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.6,
                        color: const Color(0xFF6E6367),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Actions
                Text(
                  'الإجراءات الإدارية للتقييم:',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2327),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          isHidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 16,
                          color: isHidden
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                        label: Text(
                          isHidden
                              ? 'إظهار التقييم للمستخدمين'
                              : 'إخفاء التقييم من المنصة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isHidden
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: (isHidden
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFD97706))
                                .withOpacity(0.4),
                          ),
                          backgroundColor: (isHidden
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706))
                              .withOpacity(0.06),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context
                              .read<AdminDashboardProvider>()
                              .toggleReviewVisibility(reviewId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isHidden
                                    ? 'تم إظهار التقييم بنجاح'
                                    : 'تم إخفاء التقييم عن المنصة',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: Color(0xFFE11D48)),
                      label: Text(
                        'حذف نهائي',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: const Color(0xFFE11D48).withOpacity(0.4)),
                        backgroundColor:
                            const Color(0xFFE11D48).withOpacity(0.06),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok = await context
                            .read<AdminDashboardProvider>()
                            .deleteReview(reviewId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'تم حذف التقييم بنجاح من قاعدة البيانات'
                                    : 'فشل حذف التقييم',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor:
                                  ok ? AppColors.success : AppColors.error,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF681729),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'إغلاق النافذة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReview(
      BuildContext context, String reviewId, String customerName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد حذف التقييم',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف تقييم العميل "$customerName" نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
          style: GoogleFonts.cairo(
              fontSize: 13, color: const Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'تراجع',
              style: GoogleFonts.cairo(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context
                  .read<AdminDashboardProvider>()
                  .deleteReview(reviewId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'تم حذف التقييم بنجاح' : 'فشل حذف التقييم',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: ok ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('تأكيد الحذف',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF8C7B83)),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2327)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isHidden) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHidden ? const Color(0xFFF3F4F6) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHidden ? const Color(0xFFE5E7EB) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color:
                  isHidden ? const Color(0xFF9CA3AF) : const Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isHidden ? 'مخفي' : 'ظاهر',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
                  isHidden ? const Color(0xFF4B5563) : const Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final globalSearch = context.watch<AdminNavigationProvider>().searchQuery;
    final allReviews = adminData.reviews;

    // Direct accurate metrics calculation with live fallback
    final totalCount = adminData.totalReviewsCount > 0
        ? adminData.totalReviewsCount
        : allReviews.length;
    final avgRating = totalCount > 0
        ? (adminData.averageRating > 0
            ? adminData.averageRating
            : (allReviews.isNotEmpty
                ? allReviews.fold<double>(0.0,
                        (s, r) => s + ((r['rating'] as num?)?.toDouble() ?? 5.0)) /
                    allReviews.length
                : 5.0))
        : 5.0;
    final visibleCount = allReviews.isNotEmpty
        ? allReviews.where((r) => !adminData.isReviewHidden(r['id'].toString())).length
        : adminData.visibleReviewsCount;
    final hiddenCount = allReviews.isNotEmpty
        ? allReviews.where((r) => adminData.isReviewHidden(r['id'].toString())).length
        : adminData.hiddenReviewsCount;

    // Filter reviews from Supabase
    final filteredReviews = allReviews.where((r) {
      final isHidden = adminData.isReviewHidden(r['id'].toString());

      // Status filter
      if (_statusFilter == 'visible' && isHidden) return false;
      if (_statusFilter == 'hidden' && !isHidden) return false;

      // Star filter
      if (_starFilter != null) {
        final rating = (r['rating'] as num?)?.toDouble() ?? 5.0;
        if (_starFilter == 2) {
          if (rating > 2.0) return false;
        } else {
          if (rating.floor() != _starFilter) return false;
        }
      }

      // Search query
      final query = _searchController.text.trim().isNotEmpty
          ? _searchController.text.trim().toLowerCase()
          : globalSearch.trim().toLowerCase();

      if (query.isNotEmpty) {
        final comment = (r['comment'] ?? '').toString().toLowerCase();
        final cust = (r['customer'] is Map ? r['customer']['full_name'] : '')
            .toString()
            .toLowerCase();
        final srv = (r['service'] is Map ? r['service']['name'] : '')
            .toString()
            .toLowerCase();
        final prov = (r['service'] is Map && r['service']['provider'] is Map
                ? r['service']['provider']['business_name']
                : '')
            .toString()
            .toLowerCase();

        return comment.contains(query) ||
            cust.contains(query) ||
            srv.contains(query) ||
            prov.contains(query);
      }

      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner Card
          const AdminPageHeaderCard(
              // ظظظ//title: '',
              title: '',
              subtitle:
                  'مراجعة تقييمات العملاء للخدمات ومقدمي الخدمات والتحكم في ظهورها لضمان المصداقية',
              icon: Icons.rate_review_outlined,
              breadcrumb: 'إدارة التقييمات'),

          const SizedBox(height: 24),

          // 2. Four Summary Metric Cards
          AdminStatsRow(
            cards: [
              // Card 1: Total Reviews
              AdminStatCard(
                title: 'إجمالي التقييمات',
                value: '$totalCount',
                icon: Icons.rate_review_outlined,
                iconColor: const Color(0xFF681729),
                iconBg: const Color(0xFFFDF2F4),
                isSelected: _starFilter == null && _statusFilter == 'all',
                onTap: () => setState(() {
                  _starFilter = null;
                  _statusFilter = 'all';
                }),
              ),

              // Card 2: Average Rating
              AdminStatCard(
                title: 'متوسط التقييمات',
                value: totalCount > 0 ? avgRating.toStringAsFixed(1) : '0.0',
                subText: 'من 5 نجوم',
                subTextColor: const Color(0xFFD97706),
                valueColor: const Color(0xFFD97706),
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
                onTap: () {},
              ),

              // Card 3: Visible Reviews
              AdminStatCard(
                title: 'التقييمات الظاهرة',
                value: '$visibleCount',
                valueColor: const Color(0xFF059669),
                icon: Icons.visibility_outlined,
                iconColor: const Color(0xFF059669),
                iconBg: const Color(0xFFDCFCE7),
                activeBorderColor: const Color(0xFF059669),
                isSelected: _statusFilter == 'visible',
                onTap: () => setState(() => _statusFilter = 'visible'),
              ),

              // Card 4: Hidden Reviews
              AdminStatCard(
                title: 'التقييمات المخفية',
                value: '$hiddenCount',
                icon: Icons.visibility_off_outlined,
                iconColor: const Color(0xFF64748B),
                iconBg: const Color(0xFFF1F5F9),
                isSelected: _statusFilter == 'hidden',
                onTap: () => setState(() => _statusFilter = 'hidden'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Filter Bar (3 Dropdowns matching the image)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(16),
            //   border: Border.all(color: const Color(0xFFEBE6DF)),
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.black.withOpacity(0.02),
            //       blurRadius: 10,
            //       offset: const Offset(0, 3),
            //     ),
            //   ],
            // ),
            child: Row(
              children: [
                // Dropdown 1: Star Filter (Right)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'عدد النجوم',
                      //   style: GoogleFonts.cairo(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w700,
                      //     color: const Color(0xFF8C7B83),
                      //   ),
                      // ),
                      const SizedBox(height: 6),
                      _buildFilterDropdown<int?>(
                        value: _starFilter,
                        items: const [
                          DropdownMenuItem(
                              value: null,
                              child: Text('كافة التقييمات (الكل)')),
                          DropdownMenuItem(
                              value: 5, child: Text('5 نجوم ★★★★★')),
                          DropdownMenuItem(
                              value: 4, child: Text('4 نجوم ★★★★☆')),
                          DropdownMenuItem(
                              value: 3, child: Text('3 نجوم ★★★☆☆')),
                          DropdownMenuItem(
                              value: 2, child: Text('نجمتان أو أقل ★★☆☆☆')),
                        ],
                        onChanged: (val) => setState(() => _starFilter = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Dropdown 2: Status Filter (Center)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'حالة التقييم',
                      //   style: GoogleFonts.cairo(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w700,
                      //     color: const Color(0xFF8C7B83),
                      //   ),
                      // ),
                      const SizedBox(height: 6),
                      _buildFilterDropdown<String>(
                        value: _statusFilter,
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('كافة الحالات (الكل)')),
                          DropdownMenuItem(
                              value: 'visible',
                              child: Text('التقييمات الظاهرة فقط')),
                          DropdownMenuItem(
                              value: 'hidden',
                              child: Text('التقييمات المخفية فقط')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _statusFilter = val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Dropdown 3: Date Filter (Left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'تاريخ التقييم',
                      //   style: GoogleFonts.cairo(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w700,
                      //     color: const Color(0xFF8C7B83),
                      //   ),
                      // ),
                      const SizedBox(height: 6),
                      _buildFilterDropdown<String>(
                        value: _dateFilter,
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('كافة الفترات')),
                          DropdownMenuItem(
                              value: 'this_month',
                              child: Text('هذا الشهر (أكتوبر 2026)')),
                          DropdownMenuItem(
                              value: 'this_week', child: Text('آخر 7 أيام')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _dateFilter = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Data Table (Matching the image)
          Container(
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
                  final tableWidth = constraints.maxWidth < 980
                      ? 980.0
                      : constraints.maxWidth;
                  return Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: constraints.maxWidth < 980,
                    trackVisibility: constraints.maxWidth < 980,
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
                                  _buildTableHeader('اسم العميل', flex: 15),
                                  _buildTableHeader('اسم الخدمة', flex: 14),
                                  _buildTableHeader('اسم مقدم الخدمة', flex: 14),
                                  _buildTableHeader('عدد النجوم', flex: 10),
                                  _buildTableHeader('التعليق', flex: 18),
                                  _buildTableHeader('تاريخ التقييم', flex: 9),
                                  _buildTableHeader('الحالة', flex: 9),
                                  _buildTableHeader('الإجراءات',
                                      flex: 11, textAlign: TextAlign.center),
                                ],
                              ),
                            ),

                            // Data Rows or Loading/Empty State
                            if (adminData.isLoading && adminData.reviews.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(60),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF681729)),
                                ),
                              )
                            else if (filteredReviews.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(60),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.star_border_rounded,
                                          size: 48, color: Color(0xFFB0A4A7)),
                                      const SizedBox(height: 12),
                                      Text(
                                        'لا توجد تقييمات مطابقة للفلاتر المحددة',
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2D2327),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'جرب تغيير تصفية النجوم أو الحالة للاطلاع على التقييمات المسجلة.',
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: const Color(0xFF8C7B83),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredReviews.length,
                                separatorBuilder: (_, __) => const Divider(
                                    height: 1, color: Color(0xFFEBE6DF)),
                                itemBuilder: (context, index) {
                                  final r = filteredReviews[index];
                                  final isHidden = adminData
                                      .isReviewHidden(r['id'].toString());
                                  return _buildTableRow(
                                      context, r, index, isHidden);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEBE6DF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2327),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: Color(0xFF8C7B83)),
          items: items,
          onChanged: onChanged,
        ),
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

  Widget _buildTableRow(
      BuildContext context, Map<String, dynamic> r, int index, bool isHidden) {
    // Customer
    final cust = r['customer'] as Map<String, dynamic>?;
    final custName = cust?['full_name'] ?? 'سارة فهد العمودي';
    final custPhone = cust?['phone'] ?? '+967 771 567 234';

    // Service
    final srv = r['service'] as Map<String, dynamic>?;
    final srvName = srv?['name'] ?? 'صالة الديار الملكية';
    final srvCategory =
        (srv?['category'] is Map ? srv!['category']['name'] : null) ??
            'قاعات وأفراح';

    // Provider
    final provName =
        (srv?['provider'] is Map ? srv!['provider']['business_name'] : null) ??
            'مجموعة الديار للضيافة';

    // Stars
    final rating = (r['rating'] as num?)?.toDouble() ?? 5.0;

    // Comment
    final comment = r['comment']?.toString() ??
        'خدمة ممتازة والقاعة كانت مجهزة على أعلى مستوى...';

    // Date
    final date = _formatArabicDate(r['created_at']?.toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: isHidden ? const Color(0xFFFAFAFA) : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. اسم العميل
          Expanded(
            flex: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  custName,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2327),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  custPhone,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    color: const Color(0xFF8C7B83),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 2. اسم الخدمة (مع بادج التصنيف)
          Expanded(
            flex: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  srvName,
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
                    color: const Color(0xFFFEF9EE),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFDE8BA)),
                  ),
                  child: Text(
                    srvCategory,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8A5B00),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. اسم مقدم الخدمة
          Expanded(
            flex: 14,
            child: Text(
              provName,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2327),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 4. عدد النجوم
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 13.5,
                    );
                  }),
                ),
                const SizedBox(height: 1),
                Text(
                  '${rating.toStringAsFixed(1)} / 5.0',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8C7B83),
                  ),
                ),
              ],
            ),
          ),

          // 5. التعليق
          Expanded(
            flex: 18,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                comment,
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  color: const Color(0xFF4A3E44),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // 6. تاريخ التقييم
          Expanded(
            flex: 9,
            child: Text(
              date,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: const Color(0xFF6E6367),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 7. الحالة
          Expanded(
            flex: 9,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildStatusBadge(isHidden),
            ),
          ),

          // 8. الإجراءات (ظاهرة ومحاذاة بالكامل)
          Expanded(
            flex: 11,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Details Button
                    Tooltip(
                      message: 'عرض تفاصيل التقييم بالكامل',
                      child: InkWell(
                        onTap: () =>
                            _showReviewDetailsModal(context, r, isHidden),
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
                            child: Icon(Icons.visibility_outlined,
                                size: 15, color: Color(0xFF681729)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 2. Quick Toggle Visibility Button
                    Tooltip(
                      message: isHidden
                          ? 'إظهار التقييم للمستخدمين'
                          : 'إخفاء التقييم عن المنصة',
                      child: InkWell(
                        onTap: () {
                          context
                              .read<AdminDashboardProvider>()
                              .toggleReviewVisibility(r['id'].toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isHidden
                                    ? 'تم إظهار التقييم بنجاح'
                                    : 'تم إخفاء التقييم عن المنصة',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isHidden
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: isHidden
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isHidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 15,
                              color: isHidden
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 3. Delete Review Button
                    Tooltip(
                      message: 'حذف التقييم نهائياً',
                      child: InkWell(
                        onTap: () => _confirmDeleteReview(
                            context, r['id'].toString(), custName),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
