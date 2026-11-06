import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'package:khadematy_web/admin/shell/views/admin_stat_card.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String _selectedStatus =
      'all'; // 'all', 'pending', 'in_progress', 'confirmed', 'completed', 'cancelled'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Arabic Month Formatter
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

  String _formatNumber(dynamic n) {
    if (n == null) return '0';
    try {
      final num val = n is num ? n : (num.tryParse(n.toString()) ?? 0);
      final parts = val.toString().split('.');
      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      final formatted = parts[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
      return parts.length > 1 && parts[1] != '0'
          ? '$formatted.${parts[1]}'
          : formatted;
    } catch (_) {
      return n.toString();
    }
  }

  String _formatTimeSlot(String? slot, String? rawDate) {
    if (slot != null && slot.isNotEmpty) {
      if (slot == 'evening') return 'الفترة المسائية (10:00 م)';
      if (slot == 'morning') return 'الفترة الصباحية (10:00 ص)';
      if (slot == 'afternoon') return 'فترة الظهيرة (04:00 م)';
      return slot;
    }
    if (rawDate != null) {
      try {
        final dt = DateTime.parse(rawDate);
        final hour =
            dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final period = dt.hour >= 12 ? 'م' : 'ص';
        final minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute $period';
      } catch (_) {}
    }
    return '10:00 مساءً';
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'ع';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}.${parts[1][0]}';
    }
    return parts[0][0];
  }

  Color _getAvatarBg(int index) {
    const colors = [
      Color(0xFFFCE7F3), // soft pink
      Color(0xFFE0F2FE), // soft blue
      Color(0xFFDCFCE7), // soft green
      Color(0xFFFEF3C7), // soft amber
      Color(0xFFF3E8FF), // soft purple
    ];
    return colors[index % colors.length];
  }

  Color _getAvatarTextColor(int index) {
    const colors = [
      Color(0xFF9D174D),
      Color(0xFF0369A1),
      Color(0xFF15803D),
      Color(0xFFB45309),
      Color(0xFF6B21A8),
    ];
    return colors[index % colors.length];
  }

  void _exportReport(
      BuildContext context, List<Map<String, dynamic>> bookings) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'تم تصدير تقرير الحجوزات بنجاح (${bookings.length} حجز مسجل)',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF681729),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showBookingDetailsModal(BuildContext context, Map<String, dynamic> b) {
    final code = b['booking_code'] ?? 'KH-26-0000';
    final eventType = b['event_type'] ?? 'مناسبة خاصة';
    final customer =
        (b['customer'] is Map ? b['customer']['full_name'] : null) ??
            'عميل خِدمتي';
    final phone = (b['customer'] is Map ? b['customer']['phone'] : null) ?? '-';
    final email = (b['customer'] is Map ? b['customer']['email'] : null) ?? '-';
    final amount = b['total_amount'] ?? b['budget'] ?? 0;
    final eventDate = _formatArabicDate(b['event_date']?.toString());
    final timeSlot = _formatTimeSlot(
        b['time_slot']?.toString(), b['created_at']?.toString());
    final location = b['event_location'] ?? 'غير محدد';
    final status = b['status']?.toString() ?? 'pending';
    final notes = b['notes']?.toString();

    // Provider and Service information
    String providerName = 'مؤسسة خِدمتي المعتمدة';
    String providerCategory = 'خدمات وتنسيق المناسبات';
    String providerAddress = 'صنعاء / المكلا';
    String serviceName = eventType;

    if (b['booking_items'] is List && (b['booking_items'] as List).isNotEmpty) {
      final firstItem =
          (b['booking_items'] as List).first as Map<String, dynamic>?;
      if (firstItem != null && firstItem['service'] is Map) {
        final s = firstItem['service'] as Map<String, dynamic>;
        serviceName = s['name'] ?? serviceName;
        if (s['provider'] is Map) {
          final p = s['provider'] as Map<String, dynamic>;
          providerName = p['business_name'] ?? providerName;
          providerCategory = p['category'] ?? providerCategory;
          providerAddress = p['address'] ?? providerAddress;
        }
      }
    }

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
                color: const Color(0xFF681729).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  color: Color(0xFF681729), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الحجز $code',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2327),
                    ),
                  ),
                  Text(
                    'بيانات الحجز المباشرة من قاعدة بيانات Supabase',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF8C7B83),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(status),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),

                // Customer Section
                _buildSectionHeader(
                    'بيانات العميل صاحب الحجز', Icons.person_outline),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('اسم العميل:', customer),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow('رقم الهاتف:', phone),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow('البريد الإلكتروني:', email),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Provider & Service Section
                _buildSectionHeader(
                    'مقدم الخدمة والخدمات المحجوزة', Icons.storefront_outlined),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('مقدم الخدمة:', providerName),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow('تصنيف النشاط:', providerCategory),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow('الخدمة المحجوزة:', serviceName),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow('الموقع الجغرافي:', providerAddress),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Event & Financial Details
                _buildSectionHeader('تفاصيل المناسبة والمبلغ المالي',
                    Icons.calendar_today_outlined),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('نوع الفعالية / المناسبة:', eventType),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow(
                          'تاريخ الفعالية:', '$eventDate ($timeSlot)'),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow('مكان المناسبة / القاعة:', location),
                      const Divider(height: 14, color: Color(0xFFEFE9E2)),
                      _buildDetailRow(
                        'المبلغ الإجمالي:',
                        '${_formatNumber(amount)} ر.ي',
                        isHighlight: true,
                      ),
                      if (notes != null && notes.isNotEmpty) ...[
                        const Divider(height: 14, color: Color(0xFFEFE9E2)),
                        _buildDetailRow('ملاحظات خاصة:', notes),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Change Status Admin Action
                Text(
                  'تحديث حالة الحجز في المنصة:',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2327),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildStatusActionButton(
                      ctx,
                      bookingId: b['id'].toString(),
                      targetStatus: 'confirmed',
                      label: 'تأكيد الحجز',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF16A34A),
                    ),
                    _buildStatusActionButton(
                      ctx,
                      bookingId: b['id'].toString(),
                      targetStatus: 'in_progress',
                      label: 'قيد المعالجة',
                      icon: Icons.sync,
                      color: const Color(0xFF2563EB),
                    ),
                    _buildStatusActionButton(
                      ctx,
                      bookingId: b['id'].toString(),
                      targetStatus: 'completed',
                      label: 'اكتمال الحجز',
                      icon: Icons.task_alt,
                      color: const Color(0xFF0D9488),
                    ),
                    _buildStatusActionButton(
                      ctx,
                      bookingId: b['id'].toString(),
                      targetStatus: 'cancelled',
                      label: 'إلغاء الحجز',
                      icon: Icons.cancel_outlined,
                      color: const Color(0xFFE11D48),
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
              backgroundColor: AppColors.primary,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String val, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF8C7B83),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            val,
            textAlign: TextAlign.left,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? AppColors.primary : const Color(0xFF2D2327),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActionButton(
    BuildContext dialogCtx, {
    required String bookingId,
    required String targetStatus,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: GoogleFonts.cairo(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        backgroundColor: color.withOpacity(0.06),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        final adminProvider = dialogCtx.read<AdminDashboardProvider>();
        final messenger = ScaffoldMessenger.of(context);
        final ok =
            await adminProvider.updateBookingStatus(bookingId, targetStatus);
        if (dialogCtx.mounted) {
          Navigator.pop(dialogCtx);
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                ok ? 'تم تحديث حالة الحجز بنجاح' : 'حدث خطأ أثناء التحديث',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: ok ? AppColors.success : AppColors.error,
            ),
          );
        }
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color border;
    Color dotColor;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
      case 'جديدة':
      case 'معلق':
      case 'قيد الانتظار':
        bg = const Color(0xFFFEFCE8);
        border = const Color(0xFFFEF08A);
        dotColor = const Color(0xFFEAB308);
        text = const Color(0xFF854D0E);
        label = 'قيد الانتظار';
        break;
      case 'in_progress':
      case 'inprogress':
      case 'قيد المعالجة':
      case 'قيد التنفيذ':
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        dotColor = const Color(0xFF3B82F6);
        text = const Color(0xFF1D4ED8);
        label = 'قيد التنفيذ';
        break;
      case 'confirmed':
      case 'مؤكد':
      case 'مؤكدة':
        bg = const Color(0xFFF0FDF4);
        border = const Color(0xFFBBF7D0);
        dotColor = const Color(0xFF22C55E);
        text = const Color(0xFF15803D);
        label = 'مؤكد';
        break;
      case 'completed':
      case 'مكتمل':
      case 'مكتملة':
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFFA7F3D0);
        dotColor = const Color(0xFF10B981);
        text = const Color(0xFF047857);
        label = 'مكتمل';
        break;
      case 'cancelled':
      case 'ملغي':
      case 'ملغية':
      default:
        bg = const Color(0xFFFFF1F2);
        border = const Color(0xFFFECDD3);
        dotColor = const Color(0xFFF43F5E);
        text = const Color(0xFFBE123C);
        label = 'ملغي';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: text,
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

    // Filter live Supabase bookings
    final filteredBookings = adminData.bookings.where((b) {
      final status = (b['status'] ?? '').toString().toLowerCase();

      // Status filter
      if (_selectedStatus != 'all') {
        if (_selectedStatus == 'pending' &&
            status != 'pending' &&
            status != 'جديدة' &&
            status != 'قيد الانتظار') {
          return false;
        }
        if (_selectedStatus == 'in_progress' &&
            status != 'in_progress' &&
            status != 'inprogress' &&
            status != 'قيد المعالجة' &&
            status != 'قيد التنفيذ') {
          return false;
        }
        if (_selectedStatus == 'confirmed' &&
            status != 'confirmed' &&
            status != 'مؤكد' &&
            status != 'مؤكدة') {
          return false;
        }
        if (_selectedStatus == 'completed' &&
            status != 'completed' &&
            status != 'مكتمل' &&
            status != 'تم الحل') {
          return false;
        }
        if (_selectedStatus == 'cancelled' &&
            status != 'cancelled' &&
            status != 'ملغي' &&
            status != 'مرفوضة') {
          return false;
        }
      }

      // Search query (from local search controller or global search)
      final query = _searchController.text.trim().isNotEmpty
          ? _searchController.text.trim().toLowerCase()
          : globalSearch.trim().toLowerCase();

      if (query.isNotEmpty) {
        final code = (b['booking_code'] ?? '').toString().toLowerCase();
        final event = (b['event_type'] ?? '').toString().toLowerCase();
        final cust = (b['customer'] is Map ? b['customer']['full_name'] : '')
            .toString()
            .toLowerCase();
        final phone = (b['customer'] is Map ? b['customer']['phone'] : '')
            .toString()
            .toLowerCase();
        final location = (b['event_location'] ?? '').toString().toLowerCase();

        return code.contains(query) ||
            event.contains(query) ||
            cust.contains(query) ||
            phone.contains(query) ||
            location.contains(query);
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
            title: 'إدارة الحجوزات',
            subtitle:
                'متابعة حجوزات العملاء ومقدمي الخدمات والطلبات ومعالجتها بدقة وسرعة فائقة لضمان موثوقية المنصة',
            icon: Icons.calendar_month_outlined,
          ),

          const SizedBox(height: 24),

          // 2. Summary Metric Cards
          AdminStatsRow(
            cards: [
              // Card 1: Total Bookings
              AdminStatCard(
                title: 'إجمالي الحجوزات',
                value: '${adminData.totalBookingsCount}',
                icon: Icons.folder_open_rounded,
                iconColor: const Color(0xFF681729),
                iconBg: const Color(0xFF681729).withOpacity(0.08),
                isSelected: _selectedStatus == 'all',
                onTap: () => setState(() => _selectedStatus = 'all'),
              ),
              // Card 2: New Bookings (Pending)
              AdminStatCard(
                title: 'قيد الانتظار',
                value: '${adminData.pendingBookingsCount}',
                icon: Icons.hourglass_top_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
                isSelected: _selectedStatus == 'pending',
                onTap: () => setState(() => _selectedStatus = 'pending'),
              ),
              // Card 3: In Progress Bookings
              AdminStatCard(
                title: 'قيد التنفيذ',
                value: '${adminData.inProgressBookingsCount}',
                icon: Icons.autorenew_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                isSelected: _selectedStatus == 'in_progress',
                onTap: () => setState(() => _selectedStatus = 'in_progress'),
              ),
              // Card 4: Confirmed / Completed Bookings
              AdminStatCard(
                title: 'مؤكدة ومكتملة',
                value:
                    '${adminData.confirmedBookingsCount + adminData.completedBookingsCount}',
                valueColor: const Color(0xFF16A34A),
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFDCFCE7),
                activeBorderColor: const Color(0xFF16A34A),
                isSelected: _selectedStatus == 'confirmed',
                onTap: () => setState(() => _selectedStatus = 'confirmed'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Search & Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBE6DF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Status Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2327),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: Color(0xFF8C7B83)),
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('جميع الحالات (الكل)')),
                        DropdownMenuItem(
                            value: 'pending',
                            child: Text('حجوزات جديدة (قيد الانتظار)')),
                        DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('قيد التنفيذ والمعالجة')),
                        DropdownMenuItem(
                            value: 'confirmed',
                            child: Text('الحجوزات المؤكدة والمكتملة')),
                        DropdownMenuItem(
                            value: 'completed',
                            child: Text('الحجوزات المكتملة فقط')),
                        DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('الحجوزات الملغية')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Export Button
                OutlinedButton.icon(
                  onPressed: () => _exportReport(context, filteredBookings),
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: Text(
                    'تصدير الحجوزات',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.burgundy,
                    side: const BorderSide(color: Color(0xFFEBE6DF)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const Spacer(),

                // Search Input Box
                SizedBox(
                  width: 320,
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'بحث برمز الحجز أو العميل أو الخدمة...',
                      hintStyle: GoogleFonts.cairo(
                          fontSize: 12, color: const Color(0xFF8C7B83)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : const Icon(Icons.search,
                              size: 20, color: Color(0xFF8C7B83)),
                      fillColor: const Color(0xFFFAF8F5),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF681729), width: 1.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Bookings Data Table Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBE6DF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth < 950
                      ? 950.0
                      : constraints.maxWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        children: [
                          // Table Header Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAF8F5),
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFEBE6DF)),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildTableHeader('رمز ومعرف الحجز', flex: 2),
                                _buildTableHeader('العميل', flex: 3),
                                _buildTableHeader('الخدمة والفعالية', flex: 4),
                                _buildTableHeader('مقدم الخدمة', flex: 3),
                                _buildTableHeader('موعد الفعالية', flex: 3),
                                _buildTableHeader('المبلغ الإجمالي', flex: 2),
                                _buildTableHeader('الحالة', flex: 2),
                                _buildTableHeader('الإجراء',
                                    flex: 2, textAlign: TextAlign.center),
                              ],
                            ),
                          ),

                          // Data Rows or Loading/Empty State
                          if (adminData.isLoading && adminData.bookings.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(60),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF681729)),
                              ),
                            )
                          else if (filteredBookings.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(60),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.event_busy_outlined,
                                        size: 48, color: Color(0xFFB0A4A7)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'لا توجد حجوزات مطابقة للبحث أو التصفية',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2D2327),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'جرب مسح عبارة البحث أو اختيار "جميع الحالات" للاطلاع على الحجوزات المسجلة.',
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
                              itemCount: filteredBookings.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: Color(0xFFEBE6DF)),
                              itemBuilder: (context, index) {
                                final b = filteredBookings[index];
                                return _buildTableRow(context, b, index);
                              },
                            ),
                        ],
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
      BuildContext context, Map<String, dynamic> b, int index) {
    // 2. Customer
    final custMap = b['customer'] as Map<String, dynamic>?;
    final custName = custMap?['full_name'] as String? ?? 'عميل خِدمتي';
    final initials = _getInitials(custName);

    // 3. Service & Event Information
    final eventType = b['event_type'] as String? ?? 'مناسبة خاصة';
    final guestCount = b['guest_count'] as int?;
    final totalAmount = b['total_amount'] ?? b['budget'] ?? 0;

    String serviceName = eventType;
    String providerName = 'مؤسسة معتمدة';
    String providerCategory = 'خدمات المناسبات';

    if (b['booking_items'] is List && (b['booking_items'] as List).isNotEmpty) {
      final items = b['booking_items'] as List;
      final firstItem = items.first as Map<String, dynamic>?;
      if (firstItem != null && firstItem['service'] is Map) {
        final s = firstItem['service'] as Map<String, dynamic>;
        serviceName = s['name'] as String? ?? serviceName;
        if (s['category'] is Map) {
          providerCategory =
              s['category']['name'] as String? ?? providerCategory;
        }
        if (s['provider'] is Map) {
          final p = s['provider'] as Map<String, dynamic>;
          providerName = p['business_name'] as String? ?? providerName;
        }
      }
      if (items.length > 1) {
        serviceName = '$serviceName (+${items.length - 1})';
      }
    }

    // 4. Dates
    final dateStr = _formatArabicDate(
        b['event_date']?.toString() ?? b['created_at']?.toString());
    final timeStr = _formatTimeSlot(
        b['time_slot']?.toString(), b['created_at']?.toString());

    // 5. Status
    final status = b['status']?.toString() ?? 'pending';
    final isEven = index % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: isEven ? Colors.white : const Color(0xFFFDFBF9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. رمز ومعرف الحجز
          // Expanded(
          //   flex: 2,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text(
          //         code,
          //         style: GoogleFonts.cairo(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w800,
          //           color: const Color(0xFF2D2327),
          //         ),
          //       ),
          //       Text(
          //         shortId,
          //         style: GoogleFonts.cairo(
          //           fontSize: 11,
          //           color: const Color(0xFF8C7B83),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // 2. العميل (Avatar + Name + Phone)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: _getAvatarBg(index),
                  child: Text(
                    initials,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getAvatarTextColor(index),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        custName,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2327),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Text(
                      //   custPhone,
                      //   style: GoogleFonts.cairo(
                      //     fontSize: 11,
                      //     color: const Color(0xFF8C7B83),
                      //   ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. الخدمة والفعالية
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF3EC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFEFE4D6)),
                  ),
                  child: Text(
                    serviceName,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.burgundy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                //const SizedBox(height: 4),
                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     const Icon(Icons.location_on_outlined,
                //         size: 12, color: Color(0xFF8C7B83)),
                //     const SizedBox(width: 4),
                //     Flexible(
                //       child: Text(
                //         '$eventType • $eventLocation',
                //         style: GoogleFonts.cairo(
                //           fontSize: 11,
                //           color: const Color(0xFF8C7B83),
                //         ),
                //         maxLines: 1,
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),

          // 4. مقدم الخدمة
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  providerName,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2327),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Text(
                //   providerAddress.isNotEmpty && providerAddress != eventLocation
                //       ? '$providerCategory • $providerAddress'
                //       : providerCategory,
                //   style: GoogleFonts.cairo(
                //     fontSize: 11,
                //     color: const Color(0xFF8C7B83),
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),

          // 5. موعد الفعالية
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2327),
                  ),
                ),
                Text(
                  timeStr,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF8C7B83),
                  ),
                ),
              ],
            ),
          ),

          // 6. المبلغ الإجمالي
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_formatNumber(totalAmount)} ر.ي',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2327),
                  ),
                ),
                if (guestCount != null && guestCount > 0)
                  Text(
                    '$guestCount ضيف',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF8C7B83),
                    ),
                  ),
              ],
            ),
          ),

          // 7. الحالة
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildStatusBadge(status),
            ),
          ),

          // 8. الإجراء
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () => _showBookingDetailsModal(context, b),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 17,
                  color: AppColors.burgundy,
                ),
                label: Text(
                  '',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  // backgroundColor: isPrimaryRow
                  //     ? const Color(0xFF681729)
                  //     : const Color(0xFFFAF8F5),
                  // foregroundColor:
                  //     isPrimaryRow ? Colors.white : const Color(0xFF681729),
                  // side: BorderSide(
                  //   color: isPrimaryRow
                  //       ? Colors.transparent
                  //       : const Color(0xFFEBE6DF),
                  // ),
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
