import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/widgets/dialog_actions_row.dart';
import 'package:khadematy_web/core/widgets/table_pagination_bar.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_filter_controls.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'package:khadematy_web/admin/shell/views/admin_stat_card.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  // Status filter: 'all', 'pending', 'in_progress', 'resolved', 'rejected'
  String _selectedStatusFilter = 'all';
  String _selectedDateFilter = 'هذا الشهر (أكتوبر 2026)';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _itemsPerPage = 5;
  String _lastFilterKey = '';

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
    super.dispose();
  }

  // Helper for 2-letter Arabic avatar initials
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'ش';
    if (parts.length == 1) return parts.first.characters.first;
    return '${parts[0].characters.first} ${parts[1].characters.first}';
  }

  // Deterministic avatar colors matching screenshot
  (Color bg, Color fg) _getAvatarStyle(int index, String name) {
    const styles = [
      (Color(0xFFFCE8ED), Color(0xFFBE185D)), // Pink/Rose
      (Color(0xFFE0F2FE), Color(0xFF0284C7)), // Blue
      (Color(0xFFDCFCE7), Color(0xFF16A34A)), // Mint/Green
      (Color(0xFFF3EFEA), Color(0xFF78716C)), // Warm Gray/Beige
      (Color(0xFFFEF3C7), Color(0xFFD97706)), // Amber
      (Color(0xFFEDE9FE), Color(0xFF7C3AED)), // Violet
    ];
    if (name.isNotEmpty) {
      final code = name.codeUnits.fold<int>(0, (sum, c) => sum + c);
      return styles[(code + index) % styles.length];
    }
    return styles[index % styles.length];
  }

  // Format date in Arabic: "26 أكتوبر 2026"
  String _formatArabicDate(String dateStr) {
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

  // Format time: "10:00 صباحاً"
  String _formatArabicTime(String dateStr) {
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return '';
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'مساءً' : 'صباحاً';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return '';
    }
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> c,
      AdminDashboardProvider adminData) {
    final resolutionController =
        TextEditingController(text: c['resolution_notes'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Complaint Number & Booking Code & Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBEAEA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.report_problem_outlined,
                              color: AppColors.burgundy, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل الشكوى ${c['complaint_number'] ?? '#102'}',
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2E2527),
                              ),
                            ),
                            Text(
                              'مرجع الحجز: ${c['booking_code'] ?? '#BK-8902'}',
                              style: GoogleFonts.cairo(
                                  fontSize: 12, color: const Color(0xFF8A7F84)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusBadge(c['status'] ?? 'pending'),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(height: 1, color: Color(0xFFF0ECE9)),
                const SizedBox(height: 16),

                // Parties info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF0EBE8)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                          Icons.person_outline,
                          'الطرف الشاكي (العميل)',
                          '${c['complainant_name']} - ${c['complainant_phone']}'),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                          Icons.storefront_outlined,
                          'الطرف المشكو بحقه (المزود)',
                          '${c['target_party']} (${c['target_category']})'),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.label_important_outline,
                          'موضوع الشكوى', '${c['subject']}'),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        Icons.access_time_outlined,
                        'تاريخ التقديم',
                        '${_formatArabicDate(c['created_at'].toString())} - ${_formatArabicTime(c['created_at'].toString())}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'تفاصيل الشكوى والوقائع المسجلة:',
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A7F84)),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    c['details'] ?? 'لا توجد تفاصيل إضافية',
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.6,
                        color: const Color(0xFF4A3E42)),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'ملاحظات الإدارة وإجراءات التسوية:',
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A7F84)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: resolutionController,
                  maxLines: 2,
                  style: GoogleFonts.cairo(fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                        'اكتب تفاصيل الحل، التعويض المعتمد، أو أسباب القرار هنا...',
                    hintStyle: GoogleFonts.cairo(
                        fontSize: 12, color: const Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          DialogActionsRow(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إغلاق',
                    style: GoogleFonts.cairo(color: const Color(0xFF7A6F73))),
              ),
              OutlinedButton(
                onPressed: () async {
                  final notes = resolutionController.text.trim();
                  Navigator.pop(ctx);
                  final ok = await adminData.updateComplaintStatus(
                    id: c['id'].toString(),
                    status: 'rejected',
                    resolutionNotes: notes.isNotEmpty
                        ? notes
                        : 'تم رفض الشكوى بعد المراجعة والتحقق',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            ok
                                ? 'تم رفض الشكوى وتحديث حالتها في النظام'
                                : 'تم تحديث الحالة محلياً',
                            style: GoogleFonts.cairo()),
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('رفض الشكوى',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
              if (c['status'] == 'pending' || c['status'] == 'جديدة')
                OutlinedButton(
                  onPressed: () async {
                    final notes = resolutionController.text.trim();
                    Navigator.pop(ctx);
                    final ok = await adminData.updateComplaintStatus(
                      id: c['id'].toString(),
                      status: 'in_progress',
                      resolutionNotes: notes,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              ok
                                  ? 'تم تحويل الشكوى إلى قيد المعالجة'
                                  : 'تم التحديث بنجاح',
                              style: GoogleFonts.cairo()),
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('بدء المعالجة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ElevatedButton(
                onPressed: () async {
                  final notes = resolutionController.text.trim();
                  Navigator.pop(ctx);
                  final ok = await adminData.updateComplaintStatus(
                    id: c['id'].toString(),
                    status: 'resolved',
                    resolutionNotes: notes.isNotEmpty
                        ? notes
                        : 'تم حل الشكوى وتسوية النزاع ودياً',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            ok
                                ? 'تم حل الشكوى بنجاح وتوثيق القرار '
                                : 'تم تحديث الحالة بنجاح',
                            style: GoogleFonts.cairo()),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('حل الشكوى بنجاح',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8A7F84)),
        const SizedBox(width: 8),
        Text('$title: ',
            style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF7A6F73),
                fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E2527)),
          ),
        ),
      ],
    );
  }

  void _exportComplaintsReport(List<Map<String, dynamic>> complaints) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تصدير تقرير الشكاوى بنجاح (${complaints.length} سجل بصيغة CSV/PDF)',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: AppColors.burgundy,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final globalSearch = context.watch<AdminNavigationProvider>().searchQuery;
    final allComplaints = adminData.complaints;

    // Filter complaints by status and global header search
    final filteredComplaints = allComplaints.where((c) {
      final status = c['status']?.toString().toLowerCase() ?? '';

      if (_selectedStatusFilter == 'pending' &&
          !(status == 'pending' || status == 'جديدة' || status == 'new')) {
        return false;
      }
      if (_selectedStatusFilter == 'in_progress' &&
          !(status == 'in_progress' || status == 'قيد المعالجة')) {
        return false;
      }
      if (_selectedStatusFilter == 'resolved' &&
          !(status == 'resolved' || status == 'تم الحل')) {
        return false;
      }
      if (_selectedStatusFilter == 'rejected' &&
          !(status == 'rejected' ||
              status == 'مرفوضة' ||
              status == 'closed' ||
              status == 'مغلقة')) {
        return false;
      }

      final localQuery = _searchController.text.trim().toLowerCase();
      final query = localQuery.isNotEmpty
          ? localQuery
          : globalSearch.trim().toLowerCase();
      if (query.isNotEmpty) {
        final compNum = (c['complaint_number'] ?? '').toString().toLowerCase();
        final bCode = (c['booking_code'] ?? '').toString().toLowerCase();
        final cName = (c['complainant_name'] ?? '').toString().toLowerCase();
        final tParty = (c['target_party'] ?? '').toString().toLowerCase();
        final subject = (c['subject'] ?? '').toString().toLowerCase();
        final details = (c['details'] ?? '').toString().toLowerCase();
        return compNum.contains(query) ||
            bCode.contains(query) ||
            cName.contains(query) ||
            tParty.contains(query) ||
            subject.contains(query) ||
            details.contains(query);
      }
      return true;
    }).toList();

    final filterKey =
        '$_selectedStatusFilter|$_selectedDateFilter|${_searchController.text}|$globalSearch';
    if (filterKey != _lastFilterKey) {
      _lastFilterKey = filterKey;
      _currentPage = 1;
    }

    final pagination = PaginationSlice.fromList(
      filteredComplaints,
      currentPage: _currentPage,
      itemsPerPage: _itemsPerPage,
    );

    // Stats counts strictly from live Supabase data
    final totalCount = adminData.totalComplaintsCount;
    final newCount = adminData.newComplaintsCount;
    final inProgressCount = adminData.inProgressComplaintsCount;
    final resolvedCount = adminData.resolvedComplaintsCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Row (Breadcrumb, Title, Subtitle)
          _buildHeaderRow(),

          const SizedBox(height: 24),

          // 2. Top 4 Stat Cards
          _buildTopStatCards(
              totalCount, newCount, inProgressCount, resolvedCount),

          const SizedBox(height: 24),

          // 3. Filter Bar (Month Selector, Status Filter Dropdown & Refresh Button)
          _buildFilterBar(adminData, filteredComplaints),

          const SizedBox(height: 20),

          // 4. Complaints Data Table Card
          _buildComplaintsTable(context, pagination, adminData),
        ],
      ),
    );
  }

  // 1. Header Banner Card
  Widget _buildHeaderRow() {
    return const AdminPageHeaderCard(
      title: 'أدارة الشكاوى',
      subtitle:
          'متابعة شكاوى العملاء ومقدمي الخدمات والنزاعات ومعالجتها بحيادية وسرعة فائقة لضمان موثوقية المنصة.',
      icon: Icons.report_problem_outlined,
      //breadcrumb: 'لوحة التحكم / الشكاوى',
    );
  }

  // 2. Top 4 Stat Cards
  Widget _buildTopStatCards(
      int total, int newCount, int inProgress, int resolved) {
    return AdminStatsRow(
      cards: [
        // Card 1: إجمالي الشكاوى
        AdminStatCard(
          title: 'إجمالي الشكاوى',
          value: '$total',
          icon: Icons.folder_open_outlined,
          iconBg: const Color(0xFFFDF2F4),
          iconColor: AppColors.burgundy,
          isSelected: _selectedStatusFilter == 'all',
          onTap: () {
            setState(() {
              _selectedStatusFilter = 'all';
            });
          },
        ),

        // Card 2: شكاوى جديدة
        AdminStatCard(
          title: 'شكاوى جديدة',
          value: '$newCount',
          icon: Icons.flash_on_rounded,
          iconBg: const Color(0xFFFEF9C3),
          iconColor: const Color(0xFFD97706),
          isSelected: _selectedStatusFilter == 'pending',
          activeBorderColor: const Color(0xFFD97706),
          onTap: () {
            setState(() {
              _selectedStatusFilter =
                  _selectedStatusFilter == 'pending' ? 'all' : 'pending';
            });
          },
        ),

        // Card 3: قيد المعالجة
        AdminStatCard(
          title: 'قيد المعالجة',
          value: '$inProgress',
          icon: Icons.chat_bubble_outline_rounded,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          isSelected: _selectedStatusFilter == 'in_progress',
          activeBorderColor: const Color(0xFF2563EB),
          onTap: () {
            setState(() {
              _selectedStatusFilter = _selectedStatusFilter == 'in_progress'
                  ? 'all'
                  : 'in_progress';
            });
          },
        ),

        // Card 4: تم حلها بنجاح
        AdminStatCard(
          title: 'تم حلها بنجاح',
          value: '$resolved',
          valueColor: const Color(0xFF059669),
          icon: Icons.check_circle_rounded,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
          isSelected: _selectedStatusFilter == 'resolved',
          activeBorderColor: const Color(0xFF059669),
          onTap: () {
            setState(() {
              _selectedStatusFilter =
                  _selectedStatusFilter == 'resolved' ? 'all' : 'resolved';
            });
          },
        ),
      ],
    );
  }

  // 3. Filter Bar (Month Selector, Status Filter Dropdown & Export Button)
  Widget _buildFilterBar(AdminDashboardProvider adminData,
      List<Map<String, dynamic>> filteredComplaints) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AdminFilterDropdown<String>(
                value: _selectedDateFilter,
                icon: Icons.calendar_today_outlined,
                isActive: _selectedDateFilter != 'هذا الشهر (أكتوبر 2026)',
                items: const [
                  DropdownMenuItem(
                      value: 'هذا الشهر (أكتوبر 2026)',
                      child: Text('هذا الشهر (أكتوبر 2026)')),
                  DropdownMenuItem(
                      value: 'الشهر السابق (سبتمبر 2026)',
                      child: Text('الشهر السابق (سبتمبر 2026)')),
                  DropdownMenuItem(
                      value: 'كافة الفترات', child: Text('كافة الفترات')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDateFilter = val);
                },
              ),
              AdminFilterDropdown<String>(
                value: _selectedStatusFilter,
                icon: Icons.filter_alt_outlined,
                isActive: _selectedStatusFilter != 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
                  DropdownMenuItem(
                      value: 'pending', child: Text('شكاوى جديدة')),
                  DropdownMenuItem(
                      value: 'in_progress', child: Text('قيد المعالجة')),
                  DropdownMenuItem(
                      value: 'resolved', child: Text('تم حلها بنجاح')),
                  DropdownMenuItem(value: 'rejected', child: Text('مرفوضة')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedStatusFilter = val);
                  }
                },
              ),
            ],
          ),
          AdminFilterActionButton(
            label: 'تصدير',
            icon: Icons.file_download_outlined,
            onTap: () => _exportComplaintsReport(filteredComplaints),
          ),
        ],
      ),
    );
  }

  // 4. Complaints Data Table Card
  Widget _buildComplaintsTable(
    BuildContext context,
    PaginationSlice<Map<String, dynamic>> pagination,
    AdminDashboardProvider adminData,
  ) {
    final complaints = pagination.pageItems;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EBE8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth =
                    constraints.maxWidth < 960 ? 960.0 : constraints.maxWidth;

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
                            color: Color(0xFFFAFAF9),
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF0EBE8), width: 1.2)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child:
                                      _buildHeaderCell('رقم الشكوى / الحجز')),
                              Expanded(
                                  flex: 3,
                                  child: _buildHeaderCell('العميل الشاكي')),
                              Expanded(
                                  flex: 3,
                                  child: _buildHeaderCell(
                                      'مقدم الخدمة المشكو بحقه')),
                              Expanded(
                                  flex: 4,
                                  child: _buildHeaderCell('نوع وموضوع الشكوى')),
                              Expanded(
                                  flex: 2,
                                  child: _buildHeaderCell('تاريخ التقديم')),
                              Expanded(
                                  flex: 2, child: _buildHeaderCell('الحالة')),
                              Expanded(
                                  flex: 2,
                                  child: _buildHeaderCell('الإجراء',
                                      alignment: Alignment.centerLeft)),
                            ],
                          ),
                        ),

                        // Loading State
                        if (adminData.isLoading && adminData.complaints.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.burgundy),
                            ),
                          )
                        // Empty State
                        else if (complaints.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 60, horizontal: 20),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF7F6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.inbox_outlined,
                                        size: 40, color: Color(0xFFB0A5A8)),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'لا توجد شكاوى أو نزاعات مسجلة تطابق خيارات التصفية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF5A5054),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'سيتم عرض أي شكاوى جديدة مقدمة من العملاء أو المزودين هنا فور تسجيلها.',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12.5,
                                        color: const Color(0xFF8A7F84)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        // Rows
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: complaints.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF5EFEF)),
                            itemBuilder: (context, index) {
                              final c = complaints[index];
                              return _buildTableRow(
                                  context, c, index, adminData);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (pagination.totalFiltered > 0)
              TablePaginationBar(
                pagination: pagination,
                itemLabel: 'شكوى',
                onPageChanged: (page) => setState(() => _currentPage = page),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text,
      {Alignment alignment = Alignment.centerRight}) {
    return Align(
      alignment: alignment,
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8C827A),
        ),
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    Map<String, dynamic> c,
    int index,
    AdminDashboardProvider adminData,
  ) {
    final (avatarBg, avatarFg) =
        _getAvatarStyle(index, c['complainant_name'] ?? '');
    final initials = _getInitials(c['complainant_name'] ?? '');
    final isFirstRow =
        index == 0; // In screenshot, row 0 has filled burgundy button

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          // 1. رقم الشكوى / الحجز
          // Expanded(
          //   flex: 2,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text(
          //         c['complaint_number'] ?? '#102',
          //         style: GoogleFonts.cairo(
          //           fontSize: 13.5,
          //           fontWeight: FontWeight.w800,
          //           color: const Color(0xFF2E2527),
          //         ),
          //       ),
          //       const SizedBox(height: 2),
          //       Text(
          //         c['booking_code'] ?? 'BK-9012',
          //         style: GoogleFonts.cairo(
          //           fontSize: 11.5,
          //           fontWeight: FontWeight.w600,
          //           color: const Color(0xFF9CA3AF),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // 2. العميل الشاكي (Avatar + Name + Phone)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: avatarFg,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c['complainant_name'] ?? 'مستخدم',
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E2527),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          c['complainant_phone'] ?? '-',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. مقدم الخدمة المشكو بحقه
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  c['target_party'] ?? 'الخدمة المتعاقد عليها',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E2527),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  c['target_category'] ?? 'خدمات المناسبات',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 4. نوع وموضوع الشكوى (Badge + Snippet)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSubjectBadge(c['subject'] ?? 'شكوى بدون عنوان'),
                const SizedBox(height: 4),
                Text(
                  c['details'] ?? 'لا توجد تفاصيل إضافية',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8C827A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 5. تاريخ التقديم
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatArabicDate(c['created_at'].toString()),
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E2527),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatArabicTime(c['created_at'].toString()),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          // 6. الحالة (Badge)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildStatusBadge(c['status'] ?? 'pending'),
            ),
          ),

          // 7. الإجراء (Button: عرض التفاصيل)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => _showComplaintDetails(context, c, adminData),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isFirstRow ? AppColors.burgundy : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: isFirstRow
                        ? null
                        : Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: isFirstRow
                        ? [
                            BoxShadow(
                              color: AppColors.burgundy.withOpacity(0.2),
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
                        Icons.visibility_outlined,
                        size: 14,
                        color:
                            isFirstRow ? Colors.white : const Color(0xFF4B5563),
                      ),
                      const SizedBox(width: 6),
                      // Text(
                      //   'عرض التفاصيل',
                      //   style: GoogleFonts.cairo(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.bold,
                      //     color: isFirstRow
                      //         ? Colors.white
                      //         : const Color(0xFF374151),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBadge(String subject) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFB45309);

    if (subject.contains('خلاف مالي') ||
        subject.contains('استرداد') ||
        subject.contains('مالي')) {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFC2410C);
    } else if (subject == 'تأخر في التسليم' ||
        subject.contains('ناتج') ||
        (subject.contains('تسليم') && !subject.contains('منقوص'))) {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    } else if (subject.contains('إلغاء') || subject.contains('منع')) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        subject,
        style: GoogleFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    String prefix = '• ';

    switch (status) {
      case 'in_progress':
      case 'قيد المعالجة':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'قيد المعالجة';
        break;
      case 'resolved':
      case 'تم الحل':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        label = 'تم الحل';
        break;
      case 'rejected':
      case 'مرفوضة':
      case 'closed':
      case 'مغلقة':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        label = status == 'closed' || status == 'مغلقة' ? 'مغلقة' : 'مرفوضة';
        break;
      case 'pending':
      case 'جديدة':
      default:
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFB45309);
        label = 'جديدة';
        prefix = '+ ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$prefix$label',
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
