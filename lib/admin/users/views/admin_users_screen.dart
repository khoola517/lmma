import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _selectedRole = 'all'; // 'all', 'customer', 'provider', 'admin'
  String _selectedStatusFilter = 'all'; // 'all', 'active', 'inactive'
  int _currentPage = 1;
  static const int _itemsPerPage = 5;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminDashboardProvider>().loadAllAdminData();
      }
    });
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

  void _showChangeRoleDialog(
    BuildContext context,
    Map<String, dynamic> user,
    AdminDashboardProvider adminData,
  ) {
    String currentRole = user['role'] ?? 'customer';
    String selectedRole = currentRole;
    final userId = user['id']?.toString() ?? '';
    final fullName = user['full_name']?.toString() ?? 'المستخدم';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.burgundy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.manage_accounts_outlined,
                      color: AppColors.burgundy, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'تغيير صلاحية المستخدم',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعديل دور وصلاحية الحساب لـ: $fullName',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: Text('عميل (Customer)',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    subtitle: Text('حجز الخدمات ومتابعة المناسبات',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppColors.textMuted)),
                    value: 'customer',
                    groupValue: selectedRole,
                    activeColor: AppColors.burgundy,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('مقدم خدمة (Provider)',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    subtitle: Text('إدارة الخدمات والطلبات والعروض',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppColors.textMuted)),
                    value: 'provider',
                    groupValue: selectedRole,
                    activeColor: AppColors.burgundy,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('مشرف نظام (Admin)',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    subtitle: Text('صلاحيات كاملة لإدارة لوحة التحكم',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppColors.textMuted)),
                    value: 'admin',
                    groupValue: selectedRole,
                    activeColor: AppColors.burgundy,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              DialogActionsRow(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('إلغاء',
                        style: GoogleFonts.cairo(color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    onPressed: selectedRole == currentRole
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(ctx);
                            final ok = await adminData.updateUserRole(
                                userId, selectedRole);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'تم تحديث صلاحية $fullName بنجاح في Supabase'
                                      : 'فشل تحديث الصلاحية',
                                  style: GoogleFonts.cairo(),
                                ),
                                backgroundColor:
                                    ok ? AppColors.success : AppColors.error,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('حفظ التعديل',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUserDetailsDialog(
    BuildContext context,
    Map<String, dynamic> user,
    AdminDashboardProvider adminData,
  ) {
    final fullName = user['full_name'] as String? ?? 'مستخدم خِدمتي';
    final email = user['email'] as String? ?? '-';
    final phone = user['phone'] as String? ?? '-';
    final role = user['role'] as String? ?? 'customer';
    final isActive = user['is_active'] != false;
    final userId = user['id'] as String? ?? '';
    final createdAt = user['created_at']?.toString() ?? '';
    final updatedAt = user['updated_at']?.toString() ?? '';
    final avatarUrl = user['avatar_url'] as String? ?? '';

    String roleLabel = 'عميل';
    Color roleBg = const Color(0xFFEFF6FF);
    Color roleFg = const Color(0xFF2563EB);

    if (role == 'admin') {
      roleLabel = 'مشرف نظام';
      roleBg = const Color(0xFFFBEAEA);
      roleFg = AppColors.burgundy;
    } else if (role == 'provider') {
      roleLabel = 'مقدم خدمة';
      roleBg = const Color(0xFFFEF9C3);
      roleFg = const Color(0xFFD97706);
    }

    final initial =
        fullName.trim().isNotEmpty ? fullName.trim().substring(0, 1) : 'م';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: roleBg,
                shape: BoxShape.circle,
                border: Border.all(color: roleFg.withOpacity(0.3), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.cairo(
                            color: roleFg,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.cairo(
                          color: roleFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E2527),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          roleLabel,
                          style: GoogleFonts.cairo(
                            color: roleFg,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isActive ? 'نشط' : 'معطل',
                          style: GoogleFonts.cairo(
                            color: isActive
                                ? const Color(0xFF15803D)
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: Color(0xFFEBE6DF)),
              const SizedBox(height: 8),
              _buildDialogDetailRow('معرف المستخدم (ID):', userId,
                  isCopyable: true),
              _buildDialogDetailRow('البريد الإلكتروني:', email,
                  isCopyable: true),
              _buildDialogDetailRow('رقم الهاتف:', phone),
              _buildDialogDetailRow('الدور والصلاحية:', roleLabel),
              _buildDialogDetailRow('حالة الحساب:',
                  isActive ? 'نشط (مسموح بالدخول)' : 'معطل (موقوف)'),
              _buildDialogDetailRow(
                  'تاريخ التسجيل:', _formatArabicDate(createdAt)),
              if (updatedAt.isNotEmpty)
                _buildDialogDetailRow(
                    'آخر تحديث:', _formatArabicDate(updatedAt)),
            ],
          ),
        ),
        actions: [
          DialogActionsRow(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.manage_accounts_outlined, size: 16),
                label: Text('تعديل الصلاحية',
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4B5563),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showChangeRoleDialog(context, user, adminData);
                },
              ),
              OutlinedButton.icon(
                icon: Icon(
                  isActive
                      ? Icons.block_outlined
                      : Icons.check_circle_outline,
                  size: 16,
                ),
                label: Text(
                  isActive ? 'تعطيل الحساب' : 'تنشيط الحساب',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isActive ? AppColors.error : AppColors.success,
                  side: BorderSide(
                    color: isActive
                        ? AppColors.errorBorder
                        : AppColors.successBorder,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await adminData.toggleUserStatus(userId, isActive);
                  if (ok) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم ${isActive ? 'تعطيل' : 'تنشيط'} حساب $fullName بنجاح في Supabase',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor:
                            isActive ? AppColors.error : AppColors.success,
                      ),
                    );
                  }
                },
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('إغلاق',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDetailRow(String label, String value,
      {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A7F84),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E2527),
                    ),
                  ),
                ),
                if (isCopyable && value.isNotEmpty && value != '-')
                  IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        size: 15, color: Color(0xFF9CA3AF)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'نسخ',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectRole(String roleKey) {
    setState(() {
      _selectedRole = roleKey;
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final globalSearch = context.watch<AdminNavigationProvider>().searchQuery;

    if (globalSearch != _lastSearchQuery) {
      _lastSearchQuery = globalSearch;
      _currentPage = 1;
    }

    final allUsers = adminData.users;
    final totalUsers = allUsers.length;
    final customersCount =
        allUsers.where((u) => u['role'] == 'customer').length;
    final providersCount =
        allUsers.where((u) => u['role'] == 'provider').length;
    final adminsCount = allUsers.where((u) => u['role'] == 'admin').length;

    // Filter users list based on role, status and global search query
    final filteredUsers = allUsers.where((user) {
      if (_selectedRole != 'all' && user['role'] != _selectedRole) return false;

      final isActive = user['is_active'] != false;
      if (_selectedStatusFilter == 'active' && !isActive) return false;
      if (_selectedStatusFilter == 'inactive' && isActive) return false;

      final query = globalSearch.trim().toLowerCase();
      if (query.isNotEmpty) {
        final name = (user['full_name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final phone = (user['phone'] ?? '').toString().toLowerCase();
        final id = (user['id'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            id.contains(query);
      }
      return true;
    }).toList();

    // Pagination calculations (5 users per page matching provider tables)
    final pagination = PaginationSlice.fromList(
      filteredUsers,
      currentPage: _currentPage,
      itemsPerPage: _itemsPerPage,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Banner Card
          const AdminPageHeaderCard(
            title: 'إدارة المستخدمين',
            subtitle:
                'عرض وتدقيق حسابات المستخدمين ومقدمي الخدمات والتحكم بالصلاحيات',
            icon: Icons.people_alt_outlined,
          ),

          const SizedBox(height: 24),

          // 2. Stat Cards (Live from Supabase)
          AdminStatsRow(
            cards: [
              AdminStatCard(
                title: 'إجمالي المستخدمين',
                value: '$totalUsers',
                icon: Icons.people_alt_outlined,
                iconBg: const Color(0xFFFDF2F4),
                iconColor: AppColors.burgundy,
                isSelected: _selectedRole == 'all',
                onTap: () => _selectRole('all'),
              ),
              AdminStatCard(
                title: 'العملاء المسجلون',
                value: '$customersCount',
                icon: Icons.person_outline,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                isSelected: _selectedRole == 'customer',
                onTap: () => _selectRole('customer'),
              ),
              AdminStatCard(
                title: 'مقدمو الخدمات',
                value: '$providersCount',
                icon: Icons.storefront_outlined,
                iconBg: const Color(0xFFFEF9C3),
                iconColor: const Color(0xFFD97706),
                isSelected: _selectedRole == 'provider',
                onTap: () => _selectRole('provider'),
              ),
              AdminStatCard(
                title: 'مشرفو النظام',
                value: '$adminsCount',
                icon: Icons.admin_panel_settings_outlined,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                isSelected: _selectedRole == 'admin',
                onTap: () => _selectRole('admin'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Unified Filter Bar (Role Filter Chips & Status Dropdown)
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: _buildRoleFilterChip('الكل ($totalUsers)', 'all'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRoleFilterChip(
                      'العملاء ($customersCount)', 'customer'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRoleFilterChip(
                      'مقدمو الخدمات ($providersCount)', 'provider'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRoleFilterChip('المشرفون ($adminsCount)', 'admin'),
                ),
                const SizedBox(width: 12),
                AdminFilterDropdown<String>(
                  value: _selectedStatusFilter,
                  icon: Icons.filter_alt_outlined,
                  isActive: _selectedStatusFilter != 'all',
                  items: const [
                    DropdownMenuItem(
                        value: 'all', child: Text('كافة الحالات (الكل)')),
                    DropdownMenuItem(
                        value: 'active', child: Text('الحسابات النشطة فقط')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('الحسابات المعطلة فقط')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedStatusFilter = val;
                        _currentPage = 1;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Active filter banner (if any search or filter is applied)
          if (globalSearch.isNotEmpty ||
              _selectedRole != 'all' ||
              _selectedStatusFilter != 'all')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_outlined,
                      size: 18, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'التصفية الحالية: '
                      '${_selectedRole != 'all' ? 'الدور: $_selectedRole | ' : ''}'
                      '${_selectedStatusFilter != 'all' ? 'الحالة: ${_selectedStatusFilter == 'active' ? 'نشط' : 'معطل'} | ' : ''}'
                      '${globalSearch.isNotEmpty ? 'بحث: "$globalSearch"' : ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedRole = 'all';
                        _selectedStatusFilter = 'all';
                        _currentPage = 1;
                      });
                      context
                          .read<AdminNavigationProvider>()
                          .setSearchQuery('');
                    },
                    icon: const Icon(Icons.clear_all,
                        size: 16, color: Color(0xFFB45309)),
                    label: Text(
                      'إلغاء التصفية وعرض الكل',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 4. Users Data Table (Directly from Supabase)
          if (adminData.isLoading && allUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.burgundy)),
            )
          else if (filteredUsers.isEmpty)
            _buildEmptyUsersState()
          else
            _buildUsersTable(context, pagination, adminData),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String label, String roleKey) {
    return AdminFilterChip(
      label: label,
      isSelected: _selectedRole == roleKey,
      expand: true,
      onTap: () => _selectRole(roleKey),
    );
  }

  Widget _buildUsersTable(
    BuildContext context,
    PaginationSlice<Map<String, dynamic>> pagination,
    AdminDashboardProvider adminData,
  ) {
    final users = pagination.pageItems;
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
        child: Column(
          children: [
            // Table Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF8F5),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEBE6DF)),
                ),
              ),
              child: Row(
                children: [
                  _buildTableHeader('المستخدم', flex: 3),
                  _buildTableHeader('البريد الإلكتروني', flex: 3),
                  _buildTableHeader('رقم الهاتف', flex: 2),
                  _buildTableHeader('نوع الحساب', flex: 2),
                  _buildTableHeader('حالة الحساب', flex: 2),
                  _buildTableHeader('تاريخ التسجيل', flex: 2),
                  _buildTableHeader('الإجراءات',
                      flex: 2, textAlign: TextAlign.center),
                ],
              ),
            ),

            // Table Body Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFEBE6DF)),
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserTableRow(context, user, index, adminData);
              },
            ),

            // Table Footer / Pagination Bar (Matching provider screens)
            TablePaginationBar(
              pagination: pagination,
              itemLabel: 'مستخدم',
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
          ],
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
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8C7B83),
        ),
      ),
    );
  }

  Widget _buildUserTableRow(
    BuildContext context,
    Map<String, dynamic> user,
    int index,
    AdminDashboardProvider adminData,
  ) {
    final fullName = user['full_name'] as String? ?? 'مستخدم خِدمتي';
    final email = user['email'] as String? ?? '-';
    final role = user['role'] as String? ?? 'customer';
    final isActive = user['is_active'] != false;
    final userId = user['id'] as String? ?? '';
    final createdAt = user['created_at']?.toString() ?? '';
    final avatarUrl = user['avatar_url'] as String? ?? '';

    String roleLabel = 'عميل';
    Color roleBg = const Color(0xFFEFF6FF);
    Color roleFg = const Color(0xFF2563EB);
    IconData roleIcon = Icons.person_outline;

    if (role == 'admin') {
      roleLabel = 'مشرف نظام';
      roleBg = const Color(0xFFFBEAEA);
      roleFg = AppColors.burgundy;
      roleIcon = Icons.admin_panel_settings_outlined;
    } else if (role == 'provider') {
      roleLabel = 'مقدم خدمة';
      roleBg = const Color(0xFFFEF9C3);
      roleFg = const Color(0xFFD97706);
      roleIcon = Icons.storefront_outlined;
    }

    final initial =
        fullName.trim().isNotEmpty ? fullName.trim().substring(0, 1) : 'م';

    final isEven = index % 2 == 0;

    return InkWell(
      onTap: () => _showUserDetailsDialog(context, user, adminData),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isEven ? Colors.white : const Color(0xFFFDFBF9),
        child: Row(
          children: [
            // 1. المستخدم (Avatar + Name)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: roleBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: roleFg.withOpacity(0.3), width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarUrl.isNotEmpty
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.cairo(
                                  color: roleFg,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.cairo(
                                color: roleFg,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
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
                          fullName,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: const Color(0xFF2E2527),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // if (userId.isNotEmpty)
                        //   Text(
                        //     'ID: ${userId.length > 8 ? userId.substring(0, 8) : userId}...',
                        //     style: GoogleFonts.cairo(
                        //       fontSize: 11,
                        //       color: const Color(0xFF9CA3AF),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. البريد الإلكتروني
          Expanded(
  flex: 3,
  child: Row(
    children: [
      const Icon(
        Icons.email_outlined,
        size: 14,
        color: Color(0xFF9CA3AF),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          email,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: const Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
),

            // 3. رقم الهاتف
            // Expanded(
            //   flex: 2,
            //   child: Row(
            //     children: [
            //       const Icon(Icons.phone_outlined,
            //           size: 14, color: Color(0xFF9CA3AF)),
            //       const SizedBox(width: 2),
            //       Expanded(
            //         child: Directionality(
            //           textDirection: TextDirection.ltr,
            //           child: Text(
            //             phone,
            //             style: GoogleFonts.cairo(
            //               fontSize: 12.5,
            //               color: const Color(0xFF4B5563),
            //               fontWeight: FontWeight.w500,
            //             ),
            //             maxLines: 1,
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
Expanded(
  flex: 3,
  child: Row(
    children: [
      const Icon(
        Icons.email_outlined,
        size: 14,
        color: Color(0xFF9CA3AF),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          email,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: const Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
),
            // 4. نوع الحساب / الدور
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: roleFg.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 13, color: roleFg),
                      const SizedBox(width: 5),
                      Text(
                        roleLabel,
                        style: GoogleFonts.cairo(
                          color: roleFg,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 5. حالة الحساب
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? 'نشط' : 'معطل',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? const Color(0xFF15803D)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 6. تاريخ التسجيل
            Expanded(
              flex: 2,
              child: Text(
                _formatArabicDate(createdAt),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // 7. الإجراءات
            Expanded(
  flex: 2,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Change Role Button
      Tooltip(
        message: 'تعديل الصلاحية',
        child: InkWell(
          onTap: () => _showChangeRoleDialog(context, user, adminData),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(7),
            child: Icon(
              Icons.manage_accounts_outlined,
              size: 17,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ),
      const SizedBox(width: 6),

      // Toggle Status Button
      Tooltip(
        message: isActive ? 'تعطيل الحساب' : 'تنشيط الحساب',
        child: InkWell(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final ok = await adminData.toggleUserStatus(userId, isActive);
            if (ok) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'تم ${isActive ? 'تعطيل' : 'تنشيط'} حساب $fullName ',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor:
                      isActive ? AppColors.error : AppColors.success,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              isActive ? Icons.block_outlined : Icons.check_circle_outline,
              size: 17,
              color: isActive ? AppColors.error : AppColors.success,
            ),
          ),
        ),
      ),
      const SizedBox(width: 6),

      // View Details Button
      Tooltip(
        message: 'تفاصيل المستخدم',
        child: InkWell(
          onTap: () => _showUserDetailsDialog(context, user, adminData),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(7),
            child: Icon(
              Icons.visibility_outlined,
              size: 17,
              color: AppColors.burgundy,
            ),
          ),
        ),
      ),
    ],
  ),
),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyUsersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EBE8), width: 1.2),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_search_outlined,
                  size: 44, color: Color(0xFFB0A5A8)),
            ),
            const SizedBox(height: 14),
            Text(
              'لا يوجد مستخدمون مطابقون لمعايير الفلترة المحددة',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E2527)),
            ),
            const SizedBox(height: 6),
            Text(
              'جرب اختيار دور مستخدم مختلف أو تغيير حالة الحساب.',
              style: GoogleFonts.cairo(
                  fontSize: 13, color: const Color(0xFF8A7F84)),
            ),
          ],
        ),
      ),
    );
  }
}
