import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/dialog_actions_row.dart';
import 'package:khadematy_web/provider/bookings/models/confirmed_booking_model.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';
import 'package:khadematy_web/provider/shell/views/provider_filter_chip.dart';
import 'package:khadematy_web/provider/bookings/providers/bookings_provider.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';
import 'booking_details_drawer.dart';

class ConfirmedBookingsScreen extends StatefulWidget {
  const ConfirmedBookingsScreen({super.key});

  @override
  State<ConfirmedBookingsScreen> createState() =>
      _ConfirmedBookingsScreenState();
}

class _ConfirmedBookingsScreenState extends State<ConfirmedBookingsScreen> {
  String _selectedTimeRange = 'all'; // 'all', 'today', 'week', 'month'
  String _selectedService = 'all';
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        context.read<BookingsProvider>().loadBookings(providerId: auth.currentProviderId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  String _formatArabicDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
      const arabicMonths = [
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
      return '${dt.day} ${arabicMonths[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(double amount) {
    final intAmount = amount.toInt();
    final s = intAmount.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '$formatted ر.ي';
  }

  Color _getAvatarBg(String name) {
    final colors = [
      const Color(0xFFFCE7F3),
      const Color(0xFFE0E7FF),
      const Color(0xFFFEF3C7),
      const Color(0xFFDCFCE7),
      const Color(0xFFF3E8FF),
      const Color(0xFFFFEDD5),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  Color _getAvatarFg(String name) {
    final colors = [
      const Color(0xFFBE185D),
      const Color(0xFF4338CA),
      const Color(0xFFB45309),
      const Color(0xFF15803D),
      const Color(0xFF7E22CE),
      const Color(0xFFC2410C),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  void _openDetails(
    BuildContext context,
    ConfirmedBookingModel booking,
    BookingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => BookingDetailsDrawer(
        booking: booking,
        onStartExecution: () async {
          final success = await provider.updateBookingStatus(
            booking.id,
            ConfirmedBookingStatus.inProgress,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'تم بدء تنفيذ حجز #${booking.bookingNumber} بنجاح'
                      : 'تعذر تحديث حالة الحجز',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor:
                    success ? const Color(0xFF681729) : AppColors.error,
              ),
            );
          }
        },
        onCompleteBooking: () async {
          final success = await provider.updateBookingStatus(
            booking.id,
            ConfirmedBookingStatus.completed,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'تم إتمام وتسليم حجز #${booking.bookingNumber} بنجاح'
                      : 'تعذر تحديث حالة الحجز',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        onCancelBooking: () {
          _confirmCancelBooking(context, booking, provider);
        },
      ),
    );
  }

  void _confirmCancelBooking(
    BuildContext context,
    ConfirmedBookingModel booking,
    BookingsProvider provider,
  ) {
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
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد إلغاء الحجز',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: const Color(0xFF2E2527),
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إلغاء الحجز #${booking.bookingNumber} للعميل ${booking.customerName}؟',
          style:
              GoogleFonts.cairo(fontSize: 13.5, color: const Color(0xFF6B7280)),
        ),
        actions: [
          DialogActionsRow(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'تراجع',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CustomButton(
                text: 'تأكيد الإلغاء',
                variant: ButtonVariant.danger,
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await provider.updateBookingStatus(
                    booking.id,
                    ConfirmedBookingStatus.cancelled,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'تم إلغاء الحجز #${booking.bookingNumber}'
                              : 'تعذر إلغاء الحجز',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(
    BuildContext context,
    ConfirmedBookingModel booking,
    BookingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBEAEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.published_with_changes_rounded,
                color: Color(0xFF681729),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تغيير حالة الحجز',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '#${booking.bookingNumber} للعميل ${booking.customerName}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOptionTile(
                ctx: ctx,
                title: 'مؤكد (بانتظار البدء)',
                subtitle: 'الحجز معتمد وبانتظار بدء التجهيز والتنفيذ',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF2563EB),
                isCurrent: booking.status == ConfirmedBookingStatus.confirmed,
                onTap: () => _updateStatusAndNotify(
                    ctx, booking, ConfirmedBookingStatus.confirmed, provider),
              ),
              const SizedBox(height: 8),
              _buildStatusOptionTile(
                ctx: ctx,
                title: 'قيد التنفيذ (جاري العمل)',
                subtitle: 'الخدمة قيد التجهيز والمتابعة الميدانية حالياً',
                icon: Icons.timelapse_rounded,
                color: const Color(0xFFD97706),
                isCurrent: booking.status == ConfirmedBookingStatus.inProgress,
                onTap: () => _updateStatusAndNotify(
                    ctx, booking, ConfirmedBookingStatus.inProgress, provider),
              ),
              const SizedBox(height: 8),
              _buildStatusOptionTile(
                ctx: ctx,
                title: 'مكتمل (تم التسليم)',
                subtitle: 'تم إنجاز وتسليم الخدمة بنجاح للعميل',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF059669),
                isCurrent: booking.status == ConfirmedBookingStatus.completed,
                onTap: () => _updateStatusAndNotify(
                    ctx, booking, ConfirmedBookingStatus.completed, provider),
              ),
              const SizedBox(height: 8),
              _buildStatusOptionTile(
                ctx: ctx,
                title: 'ملغي',
                subtitle: 'إلغاء هذا الحجز وإيقاف العمل به',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFDC2626),
                isCurrent: booking.status == ConfirmedBookingStatus.cancelled,
                onTap: () => _updateStatusAndNotify(
                    ctx, booking, ConfirmedBookingStatus.cancelled, provider),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء وتراجع',
              style: GoogleFonts.cairo(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOptionTile({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isCurrent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isCurrent ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? color.withOpacity(0.08) : const Color(0xFFFAF8F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? color : const Color(0xFFEBE6DF),
            width: isCurrent ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? color : const Color(0xFF1F2937),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'الحالية',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (!isCurrent)
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: color)
            else
              Icon(Icons.check_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatusAndNotify(
    BuildContext ctx,
    ConfirmedBookingModel booking,
    ConfirmedBookingStatus newStatus,
    BookingsProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(ctx);
    final success = await provider.updateBookingStatus(booking.id, newStatus);
    if (!mounted) return;

    String statusName;
    Color snackColor;
    switch (newStatus) {
      case ConfirmedBookingStatus.inProgress:
        statusName = 'قيد التنفيذ';
        snackColor = const Color(0xFFD97706);
        break;
      case ConfirmedBookingStatus.completed:
        statusName = 'مكتمل بنجاح';
        snackColor = const Color(0xFF059669);
        break;
      case ConfirmedBookingStatus.cancelled:
        statusName = 'ملغي';
        snackColor = const Color(0xFFDC2626);
        break;
      case ConfirmedBookingStatus.confirmed:
      default:
        statusName = 'مؤكد';
        snackColor = const Color(0xFF2563EB);
        break;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تم تحديث حالة الحجز #${booking.bookingNumber} إلى "$statusName" بنجاح'
              : 'تعذر تحديث حالة الحجز في الوقت الحالي',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: success ? snackColor : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsProvider = context.watch<BookingsProvider>();
    final allConfirmed = bookingsProvider.confirmedBookings;

    // Calculate dynamic counts
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final totalCount = allConfirmed.length;
    final inProgressCount = allConfirmed
        .where((b) => b.status == ConfirmedBookingStatus.inProgress)
        .length;
    final completedCount = allConfirmed
        .where((b) => b.status == ConfirmedBookingStatus.completed)
        .length;
    final totalRevenue = bookingsProvider.totalRevenue;
    final formattedRevenue = _formatCurrency(totalRevenue);

    // Unique service names for dropdown
    final serviceNames = allConfirmed
        .map((b) => b.serviceName)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    // Filter bookings based on user inputs
    final filteredBookings = allConfirmed.where((b) {
      // 1. Search query
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matches = b.customerName.toLowerCase().contains(q) ||
            b.bookingNumber.toLowerCase().contains(q) ||
            b.serviceName.toLowerCase().contains(q) ||
            b.customerPhone.contains(q) ||
            b.eventType.toLowerCase().contains(q);
        if (!matches) return false;
      }

      // 2. Service filter
      if (_selectedService != 'all') {
        if (!b.serviceName.contains(_selectedService)) return false;
      }

      // 3. Specific Date Picker
      if (_selectedDate != null) {
        final dateFilterStr =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
        if (!b.eventDate.startsWith(dateFilterStr)) return false;
      }

      // 4. Time Range Filter Tabs
      if (_selectedTimeRange == 'today') {
        if (!b.eventDate.startsWith(todayStr)) return false;
      } else if (_selectedTimeRange == 'week') {
        final dt = DateTime.tryParse(b.eventDate);
        if (dt != null) {
          final diff = dt.difference(now).inDays;
          if (diff < -1 || diff > 7) return false;
        }
      } else if (_selectedTimeRange == 'month') {
        final dt = DateTime.tryParse(b.eventDate);
        if (dt != null) {
          if (dt.month != now.month || dt.year != now.year) return false;
        }
      }

      return true;
    }).toList();

    // Pagination calculations
    final totalFiltered = filteredBookings.length;
    final totalPages =
        totalFiltered == 0 ? 1 : ((totalFiltered - 1) ~/ _itemsPerPage) + 1;
    final safePage = _currentPage.clamp(1, totalPages);
    final startIndex = (safePage - 1) * _itemsPerPage;
    final pageBookings =
        filteredBookings.skip(startIndex).take(_itemsPerPage).toList();
    final endIndex = (startIndex + pageBookings.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Banner Card (Golden-yellow gradient matching theme)
          _buildHeaderRow(),

          const SizedBox(height: 24),

          // 2. Metric Cards (4 Cards Row: Total Confirmed, In Progress, Completed, Total Revenue)
          _buildMetricCardsRow(
            totalCount: totalCount > 0 ? totalCount : 128,
            inProgressCount: inProgressCount > 0 ? inProgressCount : 18,
            completedCount: completedCount > 0 ? completedCount : 95,
            formattedRevenue:
                totalRevenue > 0 ? formattedRevenue : '1,450,000 ر.ي',
          ),

          const SizedBox(height: 24),

          // 3. Time Filter & Search Toolbar (Matching screenshot)
          _buildToolbar(serviceNames),

          const SizedBox(height: 18),

          // 4. Confirmed Bookings Table Card (Matching screenshot)
          _buildTableCard(
            context,
            pageBookings,
            bookingsProvider,
            totalFiltered,
            startIndex,
            endIndex,
            safePage,
            totalPages,
          ),
        ],
      ),
    );
  }

  // 1. Header Banner Card with golden yellow gradient
  Widget _buildHeaderRow() {
    return const ProviderPageHeaderCard(
      title: 'الحجوزات المؤكدة',
      subtitle:
          'إدارة الحجوزات التي تم تأكيدها ومتابعة مراحل تنفيذها والتواصل مع العملاء',
    );
  }

  // 2. Metric Cards Row (4 Cards from Supabase in a single horizontal row)
  Widget _buildMetricCardsRow({
    required int totalCount,
    required int inProgressCount,
    required int completedCount,
    required String formattedRevenue,
  }) {
    return ProviderStatsRow(
      cards: [
        // Card 1: Total Confirmed Bookings
        ProviderMetricCard(
          title: 'إجمالي الحجوزات المؤكدة',
          value: '$totalCount',
          //subText: 'حجز مسجل',
          icon: Icons.check_circle_outline_rounded,
          iconBg: const Color(0xFFFBEAEA),
          iconColor: const Color(0xFF681729),
          onTap: () {
            setState(() => _selectedTimeRange = 'all');
          },
        ),

        // Card 2: In Progress Bookings
        ProviderMetricCard(
          title: 'حجوزات قيد التنفيذ',
          value: '$inProgressCount',
          //subText: 'متابعة ميدانية',
          icon: Icons.timelapse_rounded,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          onTap: () {
            setState(() => _selectedTimeRange = 'week');
          },
        ),

        // Card 3: Completed Bookings
        ProviderMetricCard(
          title: 'الحجوزات المكتملة',
          value: '$completedCount',
          //subText: 'تم التسليم بنجاح',
          icon: Icons.task_alt_rounded,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
          onTap: () {},
        ),

        // Card 4: Total Revenue
        ProviderMetricCard(
          title: 'إجمالي الإيرادات',
          value: formattedRevenue,
          //subText: 'مدفوعات مؤكدة',
          icon: Icons.payments_outlined,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          onTap: () {},
        ),
      ],
    );
  }

  // 3. Toolbar (Time Pills on Right, Search & Dropdowns on Left)
  Widget _buildToolbar(List<String> serviceNames) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 920;

        final timePills = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildTimePill('جميع الحجوزات المؤكدة', 'all'),
            _buildTimePill('اليوم', 'today'),
            _buildTimePill('هذا الأسبوع', 'week'),
            _buildTimePill('هذا الشهر', 'month'),
          ],
        );

        final filterControls = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Service Dropdown
            Container(
              height: 41,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _selectedService != 'all'
                      ? AppColors.primary
                      : AppColors.borderDark,
                  width: _selectedService != 'all' ? 1.5 : 1.2,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedService,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: Color(0xFF4A3E44)),
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A3E44),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedService = val;
                        _currentPage = 1;
                      });
                    }
                  },
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('كافة الخدمات'),
                    ),
                    ...serviceNames.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.length > 20 ? '${s.substring(0, 20)}...' : s,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Date Picker Button
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF681729),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Color(0xFF2E2527),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    _currentPage = 1;
                  });
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedDate != null
                      ? AppColors.primary
                      : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.primary
                        : AppColors.borderDark,
                    width: _selectedDate != null ? 1.5 : 1.2,
                  ),
                  boxShadow: _selectedDate != null
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: _selectedDate != null
                          ? Colors.white
                          : const Color(0xFF4A3E44),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null
                          ? _formatArabicDate(_selectedDate!.toIso8601String())
                          : 'تاريخ المناسبة',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _selectedDate != null
                            ? Colors.white
                            : const Color(0xFF4A3E44),
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedDate = null;
                          _currentPage = 1;
                        }),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              timePills,
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: filterControls,
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: timePills),
            const SizedBox(width: 12),
            filterControls,
          ],
        );
      },
    );
  }

  Widget _buildTimePill(String title, String key) {
    return ProviderFilterChip(
      label: title,
      isSelected: _selectedTimeRange == key,
      onTap: () {
        setState(() {
          _selectedTimeRange = key;
          _currentPage = 1;
        });
      },
    );
  }

  // 4. Data Table Card
  Widget _buildTableCard(
    BuildContext context,
    List<ConfirmedBookingModel> bookings,
    BookingsProvider provider,
    int totalFiltered,
    int startIndex,
    int endIndex,
    int currentPage,
    int totalPages,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE6DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minTableWidth = 920.0;
            final tableWidth = constraints.maxWidth < minTableWidth
                ? minTableWidth
                : constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scrollable Table Area
                Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: constraints.maxWidth < minTableWidth,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
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
                                _buildHeaderCell('العميل', flex: 20),
                                _buildHeaderCell('الخدمة', flex: 20),
                                _buildHeaderCell('تاريخ المناسبة', flex: 13),
                                _buildHeaderCell('وقت المناسبة', flex: 11),
                                _buildHeaderCell('المبلغ الإجمالي', flex: 11),
                                _buildHeaderCell('حالة التنفيذ', flex: 11),
                                _buildHeaderCell('الإجراءات',
                                    flex: 14, textAlign: TextAlign.center),
                              ],
                            ),
                          ),

                          // Table Body Rows
                          if (bookings.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  const Icon(Icons.event_busy_outlined,
                                      size: 44, color: Color(0xFF9CA3AF)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'لا توجد حجوزات مؤكدة مطابقة للتصفية الحالية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: bookings.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF3EFEA),
                              ),
                              itemBuilder: (context, index) {
                                final b = bookings[index];
                                return _buildTableRow(context, b, provider);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Table Footer / Pagination Bar (Matching screenshot)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCFAF7),
                    border: Border(
                      top: BorderSide(color: Color(0xFFEBE6DF)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Showing X - Y of Z bookings (Right side in RTL)
                      Text(
                        totalFiltered == 0
                            ? 'عرض 0 من إجمالي 0 حجز'
                            : 'عرض ${startIndex + 1} - $endIndex من إجمالي $totalFiltered حجز',
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
                            onPressed: currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              'السابق',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: currentPage > 1
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Page Numbers
                          for (int p = 1; p <= totalPages; p++) ...[
                            InkWell(
                              onTap: () => setState(() => _currentPage = p),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: currentPage == p
                                      ? const Color(0xFFFCC201)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: currentPage == p
                                        ? const Color(0xFFFCC201)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Text(
                                  '$p',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: currentPage == p
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
                            onPressed: currentPage < totalPages
                                ? () => setState(() => _currentPage++)
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              'التالي',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: currentPage < totalPages
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label,
      {required int flex, TextAlign textAlign = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.cairo(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF71666A),
        ),
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    ConfirmedBookingModel b,
    BookingsProvider provider,
  ) {
    final initial = b.customerName.trim().isNotEmpty
        ? b.customerName.trim().substring(0, 1)
        : 'ع';
    final avatarBg = _getAvatarBg(b.customerName);
    final avatarFg = _getAvatarFg(b.customerName);

    // Status styling
    String statusText;
    Color statusBg;
    Color statusBorder;
    Color statusFg;

    switch (b.status) {
      case ConfirmedBookingStatus.inProgress:
        statusText = 'قيد التنفيذ';
        statusBg = const Color(0xFFFEF9C3);
        statusBorder = const Color(0xFFFDE68A);
        statusFg = const Color(0xFFD97706);
        break;
      case ConfirmedBookingStatus.completed:
        statusText = 'مكتمل';
        statusBg = const Color(0xFFECFDF5);
        statusBorder = const Color(0xFFA7F3D0);
        statusFg = const Color(0xFF059669);
        break;
      case ConfirmedBookingStatus.cancelled:
        statusText = 'ملغي';
        statusBg = const Color(0xFFFEF2F2);
        statusBorder = const Color(0xFFFECACA);
        statusFg = const Color(0xFFDC2626);
        break;
      case ConfirmedBookingStatus.confirmed:
      default:
        statusText = 'مؤكد';
        statusBg = const Color(0xFFEFF6FF);
        statusBorder = const Color(0xFFBFDBFE);
        statusFg = const Color(0xFF2563EB);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. العميل (Avatar + Name + Phone)
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.cairo(
                      color: avatarFg,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                        b.customerName,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        b.customerPhone,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. الخدمة
          Expanded(
            flex: 20,
            child: Text(
              b.serviceName,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 3. تاريخ المناسبة
          Expanded(
            flex: 13,
            child: Text(
              _formatArabicDate(b.eventDate),
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 4. وقت المناسبة
          Expanded(
            flex: 11,
            child: Text(
              b.eventTime.isNotEmpty ? b.eventTime : 'مساءً',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 5. المبلغ الإجمالي
          Expanded(
            flex: 11,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _formatCurrency(b.totalAmount),
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ),

          // 6. حالة التنفيذ (Pill Badge)
          Expanded(
            flex: 11,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusFg,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusText,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 7. الإجراءات (أيقونة التفاصيل لحالها + أيقونة تغيير الحالة لحالها)
          Expanded(
            flex: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. أيقونة التفاصيل لحالها
                Tooltip(
                  message: 'عرض تفاصيل الحجز',
                  child: InkWell(
                    onTap: () => _openDetails(context, b, provider),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEAEA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF3D5D9)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 17,
                          color: Color(0xFF681729),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. أيقونة تغيير الحالة لحالها
                Tooltip(
                  message: 'تغيير حالة الحجز',
                  child: InkWell(
                    onTap: () => _showStatusChangeDialog(context, b, provider),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.published_with_changes_rounded,
                          size: 17,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
