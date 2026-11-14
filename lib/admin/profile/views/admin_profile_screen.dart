import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/widgets/dialog_actions_row.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'admin_edit_profile_dialog.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String _formatArabicDate(DateTime? dt) {
    if (dt == null) return '-';
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
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final profile = auth.userProfile;
    final currentName = profile?.fullName ?? auth.displayName;
    final currentPhone = profile?.phone ?? auth.phone;
    final currentEmail = profile?.email ?? auth.email;
    final currentAvatar = profile?.avatarUrl ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AdminEditProfileDialog(
        currentFullName: currentName,
        currentPhone: currentPhone,
        currentEmail: currentEmail,
        currentAvatarUrl: currentAvatar,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider auth) {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.burgundy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_reset,
                      color: AppColors.burgundy, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'تغيير كلمة المرور',
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2527),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'أدخل كلمة المرور الجديدة لحساب المشرف لتأمين دخولك للنظام.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPassController,
                      obscureText: true,
                      style: GoogleFonts.cairo(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الجديدة *',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPassController,
                      obscureText: true,
                      style: GoogleFonts.cairo(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور *',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) {
                        if (val != newPassController.text) {
                          return 'كلمتا المرور غير متطابقتين';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              DialogActionsRow(
                children: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                    child: Text('إلغاء',
                        style: GoogleFonts.cairo(color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setDialogState(() => isSubmitting = true);
                            final success = await auth
                                .updatePassword(newPassController.text.trim());
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'تم تحديث كلمة المرور بنجاح في Supabase'
                                        : (auth.errorMessage ??
                                            'تعذر تغيير كلمة المرور'),
                                    style: GoogleFonts.cairo(),
                                  ),
                                  backgroundColor:
                                      success ? AppColors.success : AppColors.error,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('تحديث',
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final profile = auth.userProfile;
    final fullName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (auth.displayName.isNotEmpty ? auth.displayName : 'مشرف النظام العام');
    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : (auth.email.isNotEmpty ? auth.email : 'admin@khadematy.com');
    final phone = profile?.phone?.isNotEmpty == true
        ? profile!.phone!
        : (auth.phone.isNotEmpty ? auth.phone : '+967 770 000 000');
    final role = profile?.role ?? 'admin';
    final isActive = profile?.isActive ?? true;
    final userId = profile?.id ?? '';
    final avatarUrl = profile?.avatarUrl ?? '';
    final createdAt = profile?.createdAt;
    final updatedAt = profile?.updatedAt;

    final initial = fullName.trim().isNotEmpty ? fullName.trim().substring(0, 1) : 'م';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner Card (الكارد الكبيرة الصفراء المعتمدة)
          const AdminPageHeaderCard(
            title: 'الملف الشخصي للمشرف',
            subtitle: 'عرض وتعديل البيانات الشخصية ومعلومات الاتصال وإعدادات الأمان والحساب',
          ),

          const SizedBox(height: 24),

          // 2. بطاقة الملف الشخصي الموحدة (البيانات الشخصية وإعدادات الأمان)
          Center(
            child: Container(
              width:1110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEBE6DF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس البطاقة: الصورة الرمزية، الاسم، الشارات، وزر تعديل البيانات
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 20,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Avatar
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: AppColors.burgundy.withOpacity(0.08),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.burgundy, width: 2),
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
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.burgundy,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        initial,
                                        style: GoogleFonts.cairo(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.burgundy,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 18),
            
                            // Name and Badges
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      fullName,
                                      style: GoogleFonts.cairo(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2E2527),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFBEAEA),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: AppColors.burgundy.withOpacity(0.2)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.shield_outlined,
                                              size: 13, color: AppColors.burgundy),
                                          const SizedBox(width: 4),
                                          Text(
                                            'مشرف نظام عام',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.burgundy,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isActive ? 'الحساب نشط ومفعّل' : 'الحساب معطل',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 14, color: Color(0xFF9CA3AF)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'تاريخ الانضمام: ${_formatArabicDate(createdAt)}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
            
                        // Edit Profile Button
                        OutlinedButton.icon(
                          onPressed: () => _showEditProfileDialog(context, auth),
                          icon: const Icon(Icons.edit_note_rounded, size: 18),
                          label: Text('تعديل البيانات',
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.burgundy,
                            side: const BorderSide(color: AppColors.burgundy),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
            
                  const Divider(height: 1, color: Color(0xFFEBE6DF)),
            
                  // عنوان قسم: البيانات الشخصية ومعلومات الاتصال
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    color: const Color(0xFFFAF8F5),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 18, color: AppColors.burgundy),
                        const SizedBox(width: 10),
                        Text(
                          'البيانات الشخصية ومعلومات الاتصال',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E2527),
                          ),
                        ),
                      ],
                    ),
                  ),
            
                  const Divider(height: 1, color: Color(0xFFEBE6DF)),
            
                  // بنود البيانات الشخصية
                  _buildInfoTile('الاسم الكامل', fullName),
                  const Divider(height: 1, color: Color(0xFFF0EBE8)),
                  _buildInfoTile('البريد الإلكتروني', email,
                      isDirectionLtr: true, isCopyable: true),
                  const Divider(height: 1, color: Color(0xFFF0EBE8)),
                  _buildInfoTile('رقم الجوال', phone,
                      isDirectionLtr: true, isCopyable: true),
                  const Divider(height: 1, color: Color(0xFFF0EBE8)),
                  _buildInfoTile('الدور في المنصة',
                      role == 'admin' ? 'مشرف نظام (Full Admin)' : role),
                  const Divider(height: 1, color: Color(0xFFF0EBE8)),
                  _buildInfoTile(
                      'معرف الحساب (UUID)',
                      userId.isNotEmpty ? userId : 'Supabase Auth ID',
                      isDirectionLtr: true,
                      isCopyable: userId.isNotEmpty),
                  if (updatedAt != null) ...[
                    const Divider(height: 1, color: Color(0xFFF0EBE8)),
                    _buildInfoTile('آخر تحديث للملف', _formatArabicDate(updatedAt)),
                  ],
            
                  const Divider(height: 1, color: Color(0xFFEBE6DF)),
            
                  // عنوان قسم: الأمان وتسجيل الدخول
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    color: const Color(0xFFFAF8F5),
                    child: Row(
                      children: [
                        const Icon(Icons.security_outlined,
                            size: 18, color: AppColors.burgundy),
                        const SizedBox(width: 10),
                        Text(
                          'الأمان وتسجيل الدخول',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E2527),
                          ),
                        ),
                      ],
                    ),
                  ),
            
                  const Divider(height: 1, color: Color(0xFFEBE6DF)),
            
                  // تفاصيل الأمان وزر تغيير كلمة المرور
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.burgundy.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lock_outline,
                              size: 22, color: AppColors.burgundy),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'كلمة المرور والحساب',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF2E2527),
                                ),
                              ),
                              Text(
                                'كلمة المرور محمية ومشفّرة عبر Supabase Auth • متصل بنجاح ومؤمن',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: const Color(0xFF8A7F84),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _showChangePasswordDialog(context, auth),
                          icon: const Icon(Icons.lock_reset, size: 18),
                          label: Text(
                            'تغيير كلمة المرور',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.burgundy,
                            side: const BorderSide(color: AppColors.burgundy),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            
                  // شريط حالة الجلسة السفلي
                  // Container(
                  //   width: double.infinity,
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  //   decoration: const BoxDecoration(
                  //     color: Color(0xFFFAF8F5),
                  //     borderRadius:
                  //         BorderRadius.vertical(bottom: Radius.circular(17)),
                  //   ),
                    // child: Row(
                    //   children: [
                    //     Container(
                    //       width: 8,
                    //       height: 8,
                    //       decoration: const BoxDecoration(
                    //         color: Color(0xFF22C55E),
                    //         shape: BoxShape.circle,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 8),
                        // Text(
                        //   'حالة الجلسة: متصل بقاعدة بيانات Supabase والمصادقة نشطة ومؤمنة ببروتوكول SSL / JWT',
                        //   style: GoogleFonts.cairo(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w600,
                        //     color: const Color(0xFF15803D),
                        //   ),
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value, {
    bool isDirectionLtr = false,
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8A7F84),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Directionality(
                textDirection:
                    isDirectionLtr ? TextDirection.ltr : TextDirection.rtl,
                child: Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2527),
                  ),
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 8),
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
            ],
          ),
        ],
      ),
    );
  }
}

