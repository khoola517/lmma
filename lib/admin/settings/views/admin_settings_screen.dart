import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/config/supabase_config.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/dialog_actions_row.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late TextEditingController _commissionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late bool _autoApprove;
  late bool _maintenance;

  @override
  void initState() {
    super.initState();
    final p = context.read<AdminDashboardProvider>();
    _commissionController = TextEditingController(text: '${p.commissionRate.toInt()}');
    _emailController = TextEditingController(text: p.supportEmail);
    _phoneController = TextEditingController(text: p.supportPhone);
    _autoApprove = p.autoApproveProviders;
    _maintenance = p.maintenanceMode;
  }

  @override
  void dispose() {
    _commissionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveSettings(AdminDashboardProvider provider) {
    final comm = double.tryParse(_commissionController.text.trim()) ?? 10.0;
    provider.updateSettings(
      commissionRate: comm,
      autoApproveProviders: _autoApprove,
      maintenanceMode: _maintenance,
      supportEmail: _emailController.text.trim(),
      supportPhone: _phoneController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ وتحديث إعدادات منصة خِدمتي بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardBg,
        title: Row(
          children: [
            const Icon(Icons.lock_reset, color: AppColors.burgundy, size: 24),
            const SizedBox(width: 10),
            Text('تغيير كلمة مرور المشرف', style: AppTextStyles.headlineSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
            ),
          ],
        ),
        actions: [
          DialogActionsRow(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: AppTextStyles.labelMedium),
              ),
              CustomButton(
                text: 'تحديث كلمة المرور',
                variant: ButtonVariant.primary,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث كلمة مرور المشرف بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner Card
          const AdminPageHeaderCard(
            title: 'إعدادات النظام والمنصة',
            subtitle: 'ضبط المعايير العامة، سياسات العمولة، التنبيهات، والأمان الإداري',
            // icon: Icons.settings_suggest_rounded,
            // breadcrumb: 'لوحة التحكم / الإعدادات',
          ),

          const SizedBox(height: 24),

          // Platform Settings Card
          CustomCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المعايير التشغيلية والمالية',
                  style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commissionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'نسبة عمولة المنصة (%)',
                          hintText: 'مثال: 10',
                          suffixText: '%',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني للدعم الفني',
                          hintText: 'support@khidmati.ye',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم هاتف الدعم وخدمة العملاء',
                    hintText: '+967 770 000 000',
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(height: 1),
                const SizedBox(height: 16),

                // Toggles
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'الاعتماد التلقائي لمقدمي الخدمات الجدد',
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'عند تفعيل هذا الخيار سيتم قبول طلبات الانضمام تلقائياً دون الحاجة لمراجعة المشرف.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  activeColor: AppColors.burgundy,
                  value: _autoApprove,
                  onChanged: (val) => setState(() => _autoApprove = val),
                ),
                const Divider(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'وضع الصيانة المؤقتة (Maintenance Mode)',
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'إيقاف إمكانية إتمام الحجوزات مؤقتاً لعرض رسالة صيانة مجدولة للمستخدمين.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  activeColor: AppColors.error,
                  value: _maintenance,
                  onChanged: (val) => setState(() => _maintenance = val),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF0EBE8)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton(
                    text: 'حفظ كافة التغييرات',
                    icon: Icons.save_rounded,
                    variant: ButtonVariant.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    onPressed: () => _saveSettings(adminData),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Security & Server Info
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              final securityCard = CustomCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security_rounded, color: AppColors.burgundy),
                        const SizedBox(width: 8),
                        Text('الأمان وإدارة الحساب', style: AppTextStyles.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'يُنصح بتغيير كلمة مرور المشرف بشكل دوري لحماية بيانات المنصة والمدفوعات.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'تغيير كلمة المرور',
                      icon: Icons.key_outlined,
                      variant: ButtonVariant.outline,
                      onPressed: _showChangePasswordDialog,
                    ),
                  ],
                ),
              );

              final serverCard = CustomCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_done_outlined, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('حالة الاتصال والسيرفر', style: AppTextStyles.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('مزود قاعدة البيانات:', style: AppTextStyles.bodySmall),
                        Text('Supabase Cloud (PostgreSQL)', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('إصدار منصة خِدمتي:', style: AppTextStyles.bodySmall),
                        Text('v1.0.0 (Web Production)', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('حالة الاتصال المباشر:', style: AppTextStyles.bodySmall),
                        Text(SupabaseConfig.hasClient ? 'متصل بنجاح ✓' : 'غير متصل',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: securityCard),
                    const SizedBox(width: 16),
                    Expanded(child: serverCard),
                  ],
                );
              } else {
                return Column(
                  children: [
                    securityCard,
                    const SizedBox(height: 16),
                    serverCard,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}