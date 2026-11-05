import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/provider/auth/models/provider_application_model.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'package:khadematy_web/admin/shell/views/admin_stat_card.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  // Filters: 'all', 'pending', 'approved', 'rejected'
  String _selectedFilter = 'all';

  // Deterministic avatar color palette
  Color _getAvatarColor(int index, String name) {
    const colors = [
      Color(0xFFD97706), // Amber / Warm Orange
      Color(0xFF059669), // Emerald / Green
      Color(0xFF4F46E5), // Indigo / Violet
      Color(0xFF651C32), // Burgundy
      Color(0xFF0284C7), // Sky Blue
      Color(0xFFBE185D), // Deep Rose
    ];
    if (name.isNotEmpty) {
      final code = name.codeUnits.fold<int>(0, (sum, c) => sum + c);
      return colors[(code + index) % colors.length];
    }
    return colors[index % colors.length];
  }

  String _getInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'م';
    return trimmed.characters.first;
  }

  void _handleApprove(BuildContext context, ProviderApplicationModel app,
      AdminDashboardProvider provider) {
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
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: Color(0xFF059669), size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد اعتماد مقدم الخدمة',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF2E2527)),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من اعتماد "${app.businessName}"؟\nسيتم منح الحساب صلاحية مزود خدمة معتمد وتفعيل نشاطه في منصة خِدمتي فوراً.',
          style: GoogleFonts.cairo(
              fontSize: 13, height: 1.6, color: const Color(0xFF5A5054)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: const Color(0xFF7A6F73))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.approveApplication(app.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'تم اعتماد نشاط "${app.businessName}" بنجاح وتحديث حالته'
                        : 'تعذر اعتماد الطلب',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor:
                      success ? const Color(0xFF059669) : AppColors.error,
                ),
              );
            },
            child: Text('تأكيد الاعتماد',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleReject(BuildContext context, ProviderApplicationModel app,
      AdminDashboardProvider provider) {
    final reasonController = TextEditingController();

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
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cancel_rounded,
                  color: Color(0xFFDC2626), size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'رفض طلب الانضمام',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF2E2527)),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'يرجى توضيح سبب رفض طلب نشاط "${app.businessName}" (سيظهر لمقدم الطلب في شاشة المتابعة):',
                style: GoogleFonts.cairo(
                    fontSize: 13, height: 1.6, color: const Color(0xFF5A5054)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: GoogleFonts.cairo(fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'مثال: نقص في وثائق النشاط أو عدم استيفاء معايير الجودة المطلوبة...',
                  hintStyle: GoogleFonts.cairo(
                      fontSize: 12, color: const Color(0xFF9CA3AF)),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: const Color(0xFFFAF7F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDC2626)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: AppColors.burgundy)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(ctx);
              final success = await provider.rejectApplication(app.id, reason);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'تم رفض طلب "${app.businessName}"'
                        : 'تعذر رفض الطلب',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor:
                      success ? const Color(0xFFDC2626) : AppColors.burgundy,
                ),
              );
            },
            child: Text('تأكيد الرفض',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetailsDialog(BuildContext context,
      ProviderApplicationModel app, AdminDashboardProvider adminData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 580,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar, Name, and Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _getAvatarColor(0, app.displayName),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getAvatarColor(0, app.displayName)
                              .withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitial(app.displayName),
                      style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                app.businessName,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2E2527),
                                ),
                              ),
                            ),
                            _buildStatusBadge(app.status),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'مقدم الطلب: ${app.displayName}',
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF0ECE9)),
              const SizedBox(height: 18),

              // Details Grid / Info Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF0EBE8)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                        Icons.phone_outlined, 'رقم الهاتف', app.displayPhone),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.email_outlined, 'البريد الإلكتروني',
                        app.applicantEmail ?? 'غير مسجل'),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.location_on_outlined,
                        'المدينة والعنوان', app.address ?? app.displayCity),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.category_outlined,
                        'نوع الخدمة والتصنيف', app.displayCategory),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'تاريخ تقديم الطلب',
                      '${app.createdAt.year}/${app.createdAt.month.toString().padLeft(2, '0')}/${app.createdAt.day.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),

              if (app.description != null &&
                  app.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'نبذة عن النشاط والخدمات المقدمة:',
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A7F84)),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    app.description!,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.5,
                        color: const Color(0xFF4A3E42)),
                  ),
                ),
              ],

              if (app.isRejected &&
                  app.rejectionReason != null &&
                  app.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'سبب الرفض: ${app.rejectionReason}',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFDC2626)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إغلاق',
                style: GoogleFonts.cairo(
                    color: AppColors.burgundy, fontWeight: FontWeight.bold)),
          ),
          if (app.isPending) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _handleReject(context, app, adminData);
              },
              icon: const Icon(Icons.close, size: 16),
              label: Text('رفض الطلب',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFECDD3)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _handleApprove(context, app, adminData);
              },
              icon: const Icon(Icons.check, size: 16),
              label: Text('قبول واعتماد الطلب',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF8A7F84)),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: GoogleFonts.cairo(
              fontSize: 12,
              color: const Color(0xFF7A6F73),
              fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E2527)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final globalSearch = context.watch<AdminNavigationProvider>().searchQuery;
    final allApps = adminData.applications;

    // Filter applications by search and selected status tab
    final filteredApps = allApps.where((app) {
      if (_selectedFilter == 'pending' && !app.isPending) return false;
      if (_selectedFilter == 'approved' && !app.isApproved) return false;
      if (_selectedFilter == 'rejected' && !app.isRejected) return false;

      final query = globalSearch.trim().toLowerCase();

      if (query.isNotEmpty) {
        final matchesBusiness = app.businessName.toLowerCase().contains(query);
        final matchesApplicant = app.displayName.toLowerCase().contains(query);
        final matchesPhone = app.displayPhone.contains(query);
        final matchesCity = app.displayCity.toLowerCase().contains(query);
        final matchesCategory =
            app.displayCategory.toLowerCase().contains(query);
        return matchesBusiness ||
            matchesApplicant ||
            matchesPhone ||
            matchesCity ||
            matchesCategory;
      }
      return true;
    }).toList();

    final totalCount = allApps.length;
    final pendingCount = allApps.where((a) => a.isPending).length;
    final approvedCount = allApps.where((a) => a.isApproved).length;
    final rejectedCount = allApps.where((a) => a.isRejected).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Banner Card
          const AdminPageHeaderCard(
            title: 'إدارة طلبات الانضمام',
            subtitle:
                'عرض ومراجعة طلبات انضمام مقدمي الخدمات الجدد والتحقق من البيانات والتراخيص الرسمية',
            icon: Icons.assignment_ind_outlined,
          ),

          const SizedBox(height: 24),

          // 2. 4 Application Stat Cards in a Single Row
          _buildStatCardsRow(
            total: totalCount,
            pending: pendingCount,
            approved: approvedCount,
            rejected: rejectedCount,
          ),

          const SizedBox(height: 10),

          // 3. Filter Bar (Status Filter Dropdown & Filter Buttons)
          _buildFilterBar(adminData, totalCount, pendingCount, approvedCount,
              rejectedCount),

          const SizedBox(height: 10),

          // 4. Applications Table Card
          _buildApplicationsTable(context, filteredApps, adminData),
        ],
      ),
    );
  }

  // 2. 4 Application Stat Cards in a Single Horizontal Row
  Widget _buildStatCardsRow({
    required int total,
    required int pending,
    required int approved,
    required int rejected,
  }) {
    return AdminStatsRow(
      cards: [
        // Card 1: Total Applications
        AdminStatCard(
          title: 'إجمالي الطلبات',
          value: '$total',
          //subText: 'طلب مسجل',
          icon: Icons.assignment_outlined,
          iconBg: const Color(0xFFFDF2F4),
          iconColor: AppColors.burgundy,
          isSelected: _selectedFilter == 'all',
          activeBorderColor: AppColors.burgundy,
          onTap: () {
            setState(() => _selectedFilter = 'all');
          },
        ),

        // Card 2: Pending Review
        AdminStatCard(
          title: 'بانتظار المراجعة',
          value: '$pending',
          //subText: pending > 0 ? 'تحتاج اتخاذ إجراء' : 'تم الرد على الكل',
          subTextColor:
              pending > 0 ? const Color(0xFFD97706) : AppColors.success,
          icon: Icons.hourglass_top_rounded,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          isSelected: _selectedFilter == 'pending',
          activeBorderColor: const Color(0xFFD97706),
          onTap: () {
            setState(() {
              _selectedFilter =
                  _selectedFilter == 'pending' ? 'all' : 'pending';
            });
          },
        ),

        // Card 3: Approved Applications
        AdminStatCard(
          title: 'الطلبات المقبولة',
          value: '$approved',
          //subText: 'مقدم خدمة معتمد',
          subTextColor: AppColors.success,
          icon: Icons.check_circle_outline_rounded,
          iconBg: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
          isSelected: _selectedFilter == 'approved',
          activeBorderColor: const Color(0xFF059669),
          onTap: () {
            setState(() {
              _selectedFilter =
                  _selectedFilter == 'approved' ? 'all' : 'approved';
            });
          },
        ),

        // Card 4: Rejected Applications
        AdminStatCard(
          title: 'الطلبات المرفوضة',
          value: '$rejected',
          //subText: 'غير مستوفٍ للشروط',
          subTextColor: const Color(0xFFDC2626),
          icon: Icons.cancel_outlined,
          iconBg: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          isSelected: _selectedFilter == 'rejected',
          activeBorderColor: const Color(0xFFDC2626),
          onTap: () {
            setState(() {
              _selectedFilter =
                  _selectedFilter == 'rejected' ? 'all' : 'rejected';
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterPill({
    required String label,
    required int count,
    required String filterKey,
    required Color activeBg,
    required Color activeFg,
    required Color inactiveBg,
    required Color inactiveFg,
  }) {
    final isSelected = _selectedFilter == filterKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeBg : const Color(0xFFEBE6DF),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBg.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                  color: isSelected ? activeFg : inactiveFg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : inactiveFg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? activeFg : inactiveFg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Filter Bar (Spread across the entire row)
  Widget _buildFilterBar(
    AdminDashboardProvider adminData,
    int total,
    int pending,
    int approved,
    int rejected,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Row(
          children: [
            // 1. All
            Expanded(
              child: _buildFilterPill(
                label: 'الكل',
                count: total,
                filterKey: 'all',
                activeBg: AppColors.burgundy,
                activeFg: Colors.white,
                inactiveBg: const Color(0xFFF7F4F2),
                inactiveFg: const Color(0xFF5A5054),
              ),
            ),
            const SizedBox(width: 20),

            // 2. Pending
            Expanded(
              child: _buildFilterPill(
                label: 'قيد المراجعة',
                count: pending,
                filterKey: 'pending',
                activeBg: const Color(0xFFD97706),
                activeFg: Colors.white,
                inactiveBg: const Color(0xFFFEF3C7),
                inactiveFg: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 8),

            // 3. Approved
            Expanded(
              child: _buildFilterPill(
                label: 'مقبول',
                count: approved,
                filterKey: 'approved',
                activeBg: const Color(0xFF059669),
                activeFg: Colors.white,
                inactiveBg: const Color(0xFFFEE2E2),
                inactiveFg: const Color(0xFF047857),
              ),
            ),
            const SizedBox(width: 8),

            // 4. Rejected
            Expanded(
              child: _buildFilterPill(
                label: 'مرفوض',
                count: rejected,
                filterKey: 'rejected',
                activeBg: const Color(0xFFDC2626),
                activeFg: Colors.white,
                inactiveBg: const Color(0xFFFEE2E2),
                inactiveFg: const Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(width: 20),

            // 5. Status Dropdown
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEBE6DF)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: Color(0xFF6B7280)),
                  style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E2527)),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedFilter = val);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'all', child: Text('كافة الحالات (الكل)')),
                    DropdownMenuItem(
                        value: 'pending', child: Text('قيد المراجعة فقط')),
                    DropdownMenuItem(
                        value: 'approved', child: Text('المقبولة فقط')),
                    DropdownMenuItem(
                        value: 'rejected', child: Text('المرفوضة فقط')),
                  ],
                ),
              ),
            ),
          ],
        );

        if (constraints.maxWidth >= 760) {
          return SizedBox(width: double.infinity, child: content);
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(width: 760, child: content),
        );
      },
    );
  }

  // 3. Applications Table Card
  Widget _buildApplicationsTable(
    BuildContext context,
    List<ProviderApplicationModel> applications,
    AdminDashboardProvider adminData,
  ) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth =
                constraints.maxWidth < 820 ? 820.0 : constraints.maxWidth;
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
                              flex: 3, child: _buildHeaderCell('مقدم الخدمة')),
                          Expanded(
                              flex: 3, child: _buildHeaderCell('اسم النشاط')),
                          Expanded(
                              flex: 2, child: _buildHeaderCell('نوع الخدمة')),
                          Expanded(flex: 2, child: _buildHeaderCell('المدينة')),
                          Expanded(
                              flex: 2, child: _buildHeaderCell('تاريخ الطلب')),
                          Expanded(flex: 2, child: _buildHeaderCell('الحالة')),
                          Expanded(
                              flex: 2,
                              child: _buildHeaderCell('الإجراء',
                                  alignment: Alignment.centerLeft)),
                        ],
                      ),
                    ),

                    // Loading state
                    if (adminData.isLoading && applications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.burgundy),
                        ),
                      )
                    // Empty state
                    else if (applications.isEmpty)
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
                                'لا توجد طلبات انضمام تطابق معايير البحث أو الفلتر',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5A5054),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'عند تقديم طلبات انضمام جديدة من قبل مقدمي الخدمات ستظهر في هذا الجدول مباشرة من قاعدة البيانات.',
                                style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    color: const Color(0xFF8A7F84)),
                              ),
                            ],
                          ),
                        ),
                      )
                    // Table Rows
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applications.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, thickness: 1, color: Color(0xFFF5EFEF)),
                        itemBuilder: (context, index) {
                          final app = applications[index];
                          return _buildTableRow(context, app, index, adminData);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
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
    ProviderApplicationModel app,
    int index,
    AdminDashboardProvider adminData,
  ) {
    final avatarColor = _getAvatarColor(index, app.displayName);
    final initial = _getInitial(app.displayName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          // 1. مقدم الخدمة (Avatar + Name + Phone)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                        app.displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E2527),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Directionality(
                      //   textDirection: TextDirection.ltr,
                      //   child: Text(
                      //     app.displayPhone,
                      //     style: GoogleFonts.cairo(
                      //       fontSize: 11.5,
                      //       fontWeight: FontWeight.w500,
                      //       color: const Color(0xFF9CA3AF),
                      //     ),
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. اسم النشاط
          Expanded(
            flex: 3,
            child: Text(
              app.businessName,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E2527),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 3. نوع الخدمة (Pastel Badge)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDE8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  app.displayCategory,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B5B52),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // 4. المدينة
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Icon(Icons.location_on_outlined,
                //     size: 15, color: Color(0xFF9CA3AF)),
                // const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    app.displayCity,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 5. تاريخ الطلب (YYYY/MM/DD)
          Expanded(
            flex: 2,
            child: Text(
              '${app.createdAt.year}/${app.createdAt.month.toString().padLeft(2, '0')}/${app.createdAt.day.toString().padLeft(2, '0')}',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),

          // 6. الحالة (Badge with colored dot)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildStatusBadge(app.status),
            ),
          ),

          // 7. الإجراء (عرض الطلب Button with Eye Icon)
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () =>
                    _showApplicationDetailsDialog(context, app, adminData),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    //color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    //border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 14, color: Color(0xFF4B5563)),
                      SizedBox(width: 6),
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'approved':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        label = 'مقبول';
        break;
      case 'rejected':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        label = 'مرفوض';
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        label = 'قيد المراجعة';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
