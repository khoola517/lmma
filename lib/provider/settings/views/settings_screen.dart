import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/provider/profile/providers/profile_provider.dart';
import 'package:khadematy_web/provider/bookings/providers/bookings_provider.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _newOrderNotifications = true;
  bool _orderUpdatesNotifications = true;
  bool _soundAlerts = true;
  bool _weeklyDigest = false;

  void _saveNotificationPreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ تفضيلات الإعدادات والإشعارات بنجاح'),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardBg,
        title: Text('تغيير كلمة المرور', style: AppTextStyles.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: AppTextStyles.labelMedium),
          ),
          CustomButton(
            text: 'تأكيد التغيير',
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تغيير كلمة المرور بنجاح'),
                  backgroundColor: AppColors.burgundy,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Banner Card with golden yellow gradient
              const ProviderPageHeaderCard(
                title: 'إعدادات الحساب والنظام',
                subtitle:
                    'التحكم في خيارات الأمان والإشعارات والتنبيهات المباشرة وسياسة الحجز',
                icon: Icons.settings_suggest_rounded,
              ),

              const SizedBox(height: 24),

              // 2. 4 Metric Cards (Live from Supabase in a single horizontal row)
              Builder(
                builder: (context) {
                  final bookingsProvider = context.watch<BookingsProvider>();
                  return ProviderStatsRow(
                    minWidth: 800,
                    cards: [
                      ProviderMetricCard(
                        title: 'إجمالي الحجوزات',
                        value: '${bookingsProvider.totalConfirmedCount}',
                        subText: 'حجز مسجل',
                        icon: Icons.event_available_outlined,
                        iconBg: const Color(0xFFFBEAEA),
                        iconColor: const Color(0xFF681729),
                      ),
                      ProviderMetricCard(
                        title: 'قيد التنفيذ',
                        value: '${bookingsProvider.inProgressCount}',
                        subText: 'متابعة ميدانية',
                        icon: Icons.timelapse_rounded,
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFD97706),
                      ),
                      ProviderMetricCard(
                        title: 'متوسط التقييم',
                        value:
                            '${profile.overallRating.toStringAsFixed(1)} ★',
                        subText: 'تقييم عام',
                        icon: Icons.star_rounded,
                        iconBg: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF059669),
                      ),
                      ProviderMetricCard(
                        title: 'حالة الحساب',
                        value: profile.isVerified ? 'موثق' : 'نشط',
                        subText: profile.isVerified ? 'معتمد رسمي' : 'مسجل',
                        subTextColor: AppColors.success,
                        icon: Icons.verified_user_outlined,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // 1. Account & Security Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.security_outlined,
                      title: 'إعدادات الحساب والأمان',
                      subtitle: 'إدارة بيانات تسجيل الدخول وكلمة المرور ووسائل التواصل المعتمدة',
                    ),
                    const SizedBox(height: 18),
                    _buildSettingActionRow(
                      title: 'كلمة المرور',
                      subtitle: 'آخر تحديث لكلمة المرور كان قبل شهرين',
                      actionText: 'تغيير كلمة المرور',
                      icon: Icons.lock_outline,
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(height: 16),
                    _buildSettingActionRow(
                      title: 'البريد الإلكتروني المعتمد',
                      subtitle: profile.email,
                      actionText: 'تحديث البريد',
                      icon: Icons.email_outlined,
                      badge: 'مؤكد',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يمكنك تحديث البريد من صفحة الملف الشخصي'),
                            backgroundColor: AppColors.burgundy,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 16),
                    _buildSettingActionRow(
                      title: 'رقم الهاتف والتواصل',
                      subtitle: profile.phone,
                      actionText: 'تحديث الهاتف',
                      icon: Icons.phone_outlined,
                      badge: 'مفعّل',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يمكنك تحديث رقم الهاتف من صفحة الملف الشخصي'),
                            backgroundColor: AppColors.burgundy,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Notification Preferences
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.notifications_active_outlined,
                      title: 'تفضيلات الإشعارات والتنبيهات',
                      subtitle: 'التحكم في وصول التنبيهات الخاصة بالطلبات والمواعيد على الفور',
                    ),
                    const SizedBox(height: 18),
                    _buildSwitchRow(
                      title: 'إشعارات الطلبات الجديدة',
                      subtitle: 'استلام تنبيه فوري وصوتي عند إرسال عميل لطلب حجز جديد للخدمات أو القاعات',
                      value: _newOrderNotifications,
                      onChanged: (val) {
                        setState(() => _newOrderNotifications = val);
                        _saveNotificationPreferences();
                      },
                    ),
                    const Divider(height: 18),
                    _buildSwitchRow(
                      title: 'إشعارات وتحديثات الحجوزات',
                      subtitle: 'تنبيهك بتغييرات المواعيد، تأكيدات الدفع من الإدارة، أو إلغاء الحجز من العملاء',
                      value: _orderUpdatesNotifications,
                      onChanged: (val) {
                        setState(() => _orderUpdatesNotifications = val);
                        _saveNotificationPreferences();
                      },
                    ),
                    const Divider(height: 18),
                    _buildSwitchRow(
                      title: 'التنبيهات الصوتية للطلبات العاجلة',
                      subtitle: 'تشغيل نغمة تنبيه مميزة عند اقتراب انتهاء مهلة الرد على طلب الحجز',
                      value: _soundAlerts,
                      onChanged: (val) {
                        setState(() => _soundAlerts = val);
                        _saveNotificationPreferences();
                      },
                    ),
                    const Divider(height: 18),
                    _buildSwitchRow(
                      title: 'ملخص الأداء والتقارير الأسبوعية',
                      subtitle: 'استلام تقرير تحليلي دوري يلخص عدد الحجوزات ونسبة الرضا وإجمالي الإيرادات',
                      value: _weeklyDigest,
                      onChanged: (val) {
                        setState(() => _weeklyDigest = val);
                        _saveNotificationPreferences();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Booking Policies
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.gavel_outlined,
                      title: 'سياسة الحجز والمواعيد',
                      subtitle: 'القواعد العامة المطبقة على طلبات الحجز والعربون وفترات التنفيذ',
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المهلة الافتراضية للرد على طلبات الحجز',
                                style: AppTextStyles.labelMedium,
                              ),
                              Text(
                                '24 ساعة كحد أقصى',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'نسبة العربون المطلوب لتأكيد الحجز',
                                style: AppTextStyles.labelMedium,
                              ),
                              Text(
                                '50% عبر المنصة',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.w800,
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.burgundyLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.burgundy, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingActionRow({
    required String title,
    required String subtitle,
    required String actionText,
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.burgundy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        CustomButton(
          text: actionText,
          variant: ButtonVariant.outline,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onPressed: onTap,
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.burgundy,
        ),
      ],
    );
  }
}