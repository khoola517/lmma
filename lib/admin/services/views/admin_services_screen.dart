import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'package:khadematy_web/admin/shell/views/admin_stat_card.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  String _selectedCategory = 'الكل';
  String _selectedStatus = 'الكل'; // 'الكل', 'نشطة', 'متوقفة'

  void _showServiceDetails(BuildContext context, Map<String, dynamic> s) {
    final name = s['name'] as String? ?? 'تفاصيل الخدمة';
    final desc = s['description'] as String? ?? 'لا يوجد وصف متاح للخدمة.';
    final price = s['price'] ?? 0;
    final cat =
        (s['categories'] is Map ? s['categories']['name'] : s['category']) ??
            'عام';
    final providerName = (s['provider_profiles'] is Map
            ? s['provider_profiles']['business_name']
            : s['provider_name']) ??
        'مقدم خدمة معتمد';
    final location = s['location'] ?? 'غير محدد';
    final isAvailable = s['is_available'] != false && s['status'] != 'paused';

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
                color: const Color(0xFF651C32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.miscellaneous_services_outlined,
                  color: Color(0xFF651C32), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E2527),
                ),
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
              _buildDetailRow('مزود الخدمة:', '$providerName'),
              const Divider(height: 16),
              _buildDetailRow('التصنيف:', '$cat'),
              const Divider(height: 16),
              _buildDetailRow('الموقع:', '$location'),
              const Divider(height: 16),
              _buildDetailRow('السعر المعتمد:', '${_formatNumber(price)} ر.ي'),
              const Divider(height: 16),
              _buildDetailRow('الحالة الحالية:',
                  isAvailable ? 'نشطة (متاحة للطلب)' : 'متوقفة'),
              const Divider(height: 16),
              Text(
                'الوصف والمواصفات:',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8A7F84),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEFE9E0)),
                ),
                child: Text(
                  desc,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF4A3E42),
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'إغلاق',
            variant: ButtonVariant.primary,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteService(BuildContext context, Map<String, dynamic> s,
      AdminDashboardProvider adminData) {
    final name = s['name'] as String? ?? 'الخدمة';
    final id = s['id'].toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text('تأكيد حذف الخدمة',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف خدمة "$name"؟\nسيتم إخفاؤها نهائياً من نتائج البحث والمنصة.',
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
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await adminData.deleteService(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف خدمة "$name" بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text('تأكيد الحذف',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 12.5, color: const Color(0xFF8A7F84))),
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E2527))),
      ],
    );
  }

  String _formatNumber(dynamic number) {
    final n = int.tryParse(number.toString()) ?? 0;
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final globalSearch = context.watch<AdminNavigationProvider>().searchQuery;

    final filteredServices = adminData.services.where((s) {
      // Category filter
      final cat =
          (s['categories'] is Map ? s['categories']['name'] : s['category']) ??
              '';
      if (_selectedCategory != 'الكل' && cat != _selectedCategory) return false;

      // Status filter
      final isAvailable = s['is_available'] != false && s['status'] != 'paused';
      if (_selectedStatus == 'نشطة' && !isAvailable) return false;
      if (_selectedStatus == 'متوقفة' && isAvailable) return false;

      // Search query from header
      final query = globalSearch.trim().toLowerCase();

      if (query.isNotEmpty) {
        final name = (s['name'] ?? '').toString().toLowerCase();
        final prov = (s['provider_profiles'] is Map
                ? s['provider_profiles']['business_name']
                : s['provider_name'] ?? '')
            .toString()
            .toLowerCase();
        final loc = (s['location'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            prov.contains(query) ||
            loc.contains(query) ||
            cat.toLowerCase().contains(query);
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
            title: 'إدارة الخدمات',
            subtitle:
                'استعراض وإدارة جميع باقات وخدمات المناسبات والفعاليات المتاحة في المنصة.',
            icon: Icons.miscellaneous_services_outlined,
            //breadcrumb: 'لوحة التحكم / الخدمات',
          ),

          const SizedBox(height: 24),

          // 2. Top 3 Stat Cards (Exactly as in the screenshot)
          _buildTopStatCards(adminData),

          const SizedBox(height: 20),

          // 3. Search & Filter Bar (Single full-width white card)
          _buildSearchAndFilterBar(adminData),

          const SizedBox(height: 20),

          // 4. Services Data Table (Exact table design with all columns)
          _buildServicesTable(context, filteredServices, adminData),
        ],
      ),
    );
  }

  // 1. Top 3 Stat Cards
  Widget _buildTopStatCards(AdminDashboardProvider adminData) {
    return AdminStatsRow(
      cards: [
        // Card 1: إجمالي الخدمات
        AdminStatCard(
          title: 'إجمالي الخدمات',
          value: '${adminData.totalServicesCount}',
          icon: Icons.grid_view_rounded,
          iconColor: const Color(0xFF7A6F6D),
          iconBg: const Color(0xFFF3EFE9),
          isSelected: _selectedStatus == 'الكل',
          onTap: () => setState(() => _selectedStatus = 'الكل'),
        ),

        // Card 2: الخدمات المتاحة للعملاء
        AdminStatCard(
          title: 'الخدمات المتاحة للعملاء',
          value: '${adminData.activeServicesCount}',
          icon: Icons.verified_user_outlined,
          iconColor: const Color(0xFF10B981),
          iconBg: const Color(0xFFE8F7EE),
          isSelected: _selectedStatus == 'نشطة',
          activeBorderColor: const Color(0xFF10B981),
          onTap: () => setState(() => _selectedStatus = 'نشطة'),
        ),

        // Card 3: الخدمات الموقوفة من الأدمن
        AdminStatCard(
          title: 'الخدمات الموقوفة من الأدمن',
          value: '${adminData.pausedServicesCount}',
          valueColor: const Color(0xFFE11D48),
          icon: Icons.block_outlined,
          iconColor: const Color(0xFFE11D48),
          iconBg: const Color(0xFFFDECEE),
          isSelected: _selectedStatus == 'متوقفة',
          activeBorderColor: const Color(0xFFE11D48),
          onTap: () => setState(() => _selectedStatus = 'متوقفة'),
        ),
      ],
    );
  }

  // 2. Search & Filter Bar
  Widget _buildSearchAndFilterBar(AdminDashboardProvider adminData) {
    final categories = <String>[
      'الكل',
      ...adminData.categories
          .map((c) => c['name'] as String? ?? '')
          .where((c) => c.isNotEmpty)
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16),
      //   border: Border.all(color: const Color(0xFFEFE9E0)),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.015),
      //       blurRadius: 8,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Row(
        children: [
          // Dropdown 1: جميع الحالات
          _buildFilterDropdown(
            value: _selectedStatus == 'الكل' ? 'جميع الحالات' : _selectedStatus,
            items: const ['جميع الحالات', 'نشطة', 'متوقفة'],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedStatus = val == 'جميع الحالات' ? 'الكل' : val;
                });
              }
            },
          ),
          const SizedBox(width: 12),

          // Dropdown 2: جميع التصنيفات
          _buildFilterDropdown(
            value: _selectedCategory == 'الكل'
                ? 'جميع التصنيفات'
                : _selectedCategory,
            items: ['جميع التصنيفات', ...categories.where((c) => c != 'الكل')],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCategory = val == 'جميع التصنيفات' ? 'الكل' : val;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5DDD2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: Color(0xFF8A7F84)),
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A3E42),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // 3. Services Data Table
  Widget _buildServicesTable(
    BuildContext context,
    List<Map<String, dynamic>> services,
    AdminDashboardProvider adminData,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE9E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFCFAF7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEE6DC)),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Text(
                      'صورة\nالخدمة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A7F84),
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 35,
                  child: Text(
                    'اسم الخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A7F84),
                    ),
                  ),
                ),
                Expanded(
                  flex: 18,
                  child: Center(
                    child: Text(
                      'التصنيف',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A7F84),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 22,
                  child: Text(
                    'مقدم الخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A7F84),
                    ),
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: Text(
                    'الموقع',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A7F84),
                    ),
                  ),
                ),
                Expanded(
                  flex: 16,
                  child: Text(
                    'السعر',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A7F84),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: Center(
                    child: Text(
                      'الحالة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A7F84),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: Center(
                    child: Text(
                      'الإجراءات',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A7F84),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          if (services.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 40, color: Color(0xFFB5A89E)),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد خدمات مطابقة للبحث أو التصنيف المختار',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5A5054),
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
              itemCount: services.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF2ECE4)),
              itemBuilder: (context, index) {
                final s = services[index];
                return _buildServiceTableRow(context, s, adminData);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceTableRow(
    BuildContext context,
    Map<String, dynamic> s,
    AdminDashboardProvider adminData,
  ) {
    final id = s['id'].toString();
    final name = s['name'] as String? ?? 'خدمة مناسبة';
    final subtitle = s['subtitle'] as String?;
    final price = s['price'] ?? 0;
    final cat =
        (s['categories'] is Map ? s['categories']['name'] : s['category']) ??
            'عام';
    final providerName = (s['provider_profiles'] is Map
            ? s['provider_profiles']['business_name']
            : s['provider_name']) ??
        'مؤسسة معتمدة';
    final location = s['location'] ?? 'صنعاء - حدة';
    final isAvailable = s['is_available'] != false && s['status'] != 'paused';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // 1. صورة الخدمة
          SizedBox(
            width: 50,
            child: Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE8F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2DBEC)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: Color(0xFF9E8EC0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // 2. اسم الخدمة
          Expanded(
            flex: 35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: const Color(0xFF2E2527),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFFA69A9E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 3. التصنيف (Pill Tag)
          Expanded(
            flex: 18,
            child: Center(
              child: _buildCategoryPill(cat.toString()),
            ),
          ),

          // 4. مقدم الخدمة
          Expanded(
            flex: 22,
            child: Text(
              providerName.toString(),
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3E3336),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 5. الموقع
          Expanded(
            flex: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFFC6A15B),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location.toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF6F6265),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 6. السعر
          Expanded(
            flex: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatNumber(price),
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E2527),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ر.ي',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A7F84),
                  ),
                ),
              ],
            ),
          ),

          // 7. الحالة
          Expanded(
            flex: 14,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFFE8F8F0)
                      : const Color(0xFFF4F1ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAvailable
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFE2DDD5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFF10B981)
                            : const Color(0xFF8A7F84),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAvailable ? 'نشطة' : 'متوقفة',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? const Color(0xFF10B981)
                            : const Color(0xFF8A7F84),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 8. الإجراءات (3 Icons: View, Pause, Delete)
          Expanded(
            flex: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // View Details
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  color: const Color(0xFF8A7F84),
                  tooltip: 'عرض التفاصيل',
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  onPressed: () => _showServiceDetails(context, s),
                ),
                const SizedBox(width: 4),

                // Toggle / Block
                IconButton(
                  icon: Icon(
                    isAvailable
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 17,
                  ),
                  color: isAvailable
                      ? const Color(0xFFC48B28)
                      : const Color(0xFF10B981),
                  tooltip: isAvailable ? 'إيقاف الخدمة' : 'تفعيل الخدمة',
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final ok = await adminData.toggleServiceAvailability(
                        id, isAvailable);
                    if (context.mounted && ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAvailable
                                ? 'تم إيقاف خدمة "$name"'
                                : 'تم تفعيل خدمة "$name"',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: isAvailable
                              ? const Color(0xFF651C32)
                              : const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 4),

                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 17),
                  color: const Color(0xFF8A7F84),
                  hoverColor: AppColors.errorBg,
                  tooltip: 'حذف الخدمة',
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  onPressed: () => _confirmDeleteService(context, s, adminData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Colored Category Pill Tag
  Widget _buildCategoryPill(String category) {
    Color bg;
    Color border;
    Color text;

    if (category.contains('قاعات') || category.contains('مواقع')) {
      bg = const Color(0xFFEBF2FD);
      border = const Color(0xFFC7DCFA);
      text = const Color(0xFF2563EB);
    } else if (category.contains('تصوير') || category.contains('توثيق')) {
      bg = const Color(0xFFE6F6FD);
      border = const Color(0xFFBAE6FD);
      text = const Color(0xFF0284C7);
    } else if (category.contains('ديكور') || category.contains('كوش')) {
      bg = const Color(0xFFFEF9E7);
      border = const Color(0xFFFDE68A);
      text = const Color(0xFFD97706);
    } else if (category.contains('كيك') || category.contains('حلويات')) {
      bg = const Color(0xFFFDF2F4);
      border = const Color(0xFFFECDD3);
      text = const Color(0xFFE11D48);
    } else if (category.contains('ورد') || category.contains('تنسيق')) {
      bg = const Color(0xFFFEECEB);
      border = const Color(0xFFFECACA);
      text = const Color(0xFFDC2626);
    } else if (category.contains('صوت') || category.contains('إضاءة')) {
      bg = const Color(0xFFF3E8FF);
      border = const Color(0xFFDDD6FE);
      text = const Color(0xFF9333EA);
    } else if (category.contains('أزياء') ||
        category.contains('مكياج') ||
        category.contains('فساتين')) {
      bg = const Color(0xFFE6FFFA);
      border = const Color(0xFFA7F3D0);
      text = const Color(0xFF0D9488);
    } else {
      bg = const Color(0xFFF3F0EB);
      border = const Color(0xFFE5DFD7);
      text = const Color(0xFF5A5054);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.5,
            height: 4.5,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            category,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
