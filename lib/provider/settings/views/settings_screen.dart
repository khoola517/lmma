import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/core/services/live_notification_banner_service.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';
import 'package:khadematy_web/provider/profile/providers/profile_provider.dart';
import 'package:khadematy_web/provider/bookings/providers/bookings_provider.dart';
import 'package:khadematy_web/provider/settings/models/provider_settings_model.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showSaveResultMessage(
    bool success,
    ProfileProvider profileProvider, {
    String? successMessage,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (successMessage ?? 'تم حفظ تفضيلات الإعدادات والإشعارات بنجاح')
              : (profileProvider.errorMessage ??
                  'تعذر حفظ الإعدادات يرجى المحاولة مجدداً'),
        ),
        backgroundColor: success ? AppColors.burgundy : AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateNotificationSetting(
    ProfileProvider profileProvider,
    ProviderSettingsModel updated,
  ) async {
    final ok = await profileProvider.updateSettings(updated);
    _showSaveResultMessage(ok, profileProvider);
  }

  void _showDeadlineDialog(BuildContext context, ProfileProvider profileProvider) {
    final currentDeadline = profileProvider.settings.defaultResponseHours;
    final options = [
      {'hours': 12, 'title': '12 ساعة', 'desc': 'استجابة سريعة للطلبات المستعجلة'},
      {'hours': 24, 'title': '24 ساعة (الموصى به)', 'desc': 'المهلة المعيارية المثالية لتقييم الطلبات والرد'},
      {'hours': 48, 'title': '48 ساعة', 'desc': 'مرونة إضافية لتنسيق وحجز المناسبات الكبرى'},
      {'hours': 72, 'title': '72 ساعة', 'desc': '3 أيام لمقدمي الخدمات ذات التحضيرات الخاصة'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardBg,
        title: Row(
          children: [
            const Icon(Icons.timer_outlined, color: AppColors.burgundy),
            const SizedBox(width: 8),
            Text('تحديد المهلة الافتراضية للرد', style: AppTextStyles.headlineSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final hours = opt['hours'] as int;
            final isSelected = hours == currentDeadline;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.burgundyLight : AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.burgundy : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(
                  opt['title'] as String,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.burgundy : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  opt['desc'] as String,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.burgundy)
                    : null,
                onTap: () async {
                  final bookingsProvider = context.read<BookingsProvider>();
                  Navigator.pop(ctx);
                  final updated =
                      profileProvider.settings.copyWith(defaultResponseHours: hours);
                  final ok = await profileProvider.updateSettings(updated);
                  if (!mounted) return;
                  if (ok) {
                    bookingsProvider.setDefaultResponseHours(hours);
                  }
                  _showSaveResultMessage(
                    ok,
                    profileProvider,
                    successMessage:
                        'تم ضبط المهلة الافتراضية للرد إلى $hours ساعة وحفظها بنجاح',
                  );
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إغلاق', style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? dialogError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: AppColors.cardBg,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.burgundyLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_reset,
                      color: AppColors.burgundy, size: 22),
                ),
                const SizedBox(width: 10),
                Text('تغيير كلمة المرور', style: AppTextStyles.headlineSmall),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dialogError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.errorBorder),
                        ),
                        child: Text(
                          dialogError!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    TextFormField(
                      controller: currentPassController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الحالية ',
                        //prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onPressed: () => setDialogState(
                              () => obscureCurrent = !obscureCurrent),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'يرجى إدخال كلمة المرور الحالية';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPassController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الجديدة ',
                       // prefixIcon: const Icon(Icons.lock_open_outlined, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onPressed: () =>
                              setDialogState(() => obscureNew = !obscureNew),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                        }
                        if (val == currentPassController.text) {
                          return 'يجب أن تختلف كلمة المرور الجديدة عن الحالية';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPassController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور الجديدة ',
                        // prefixIcon:
                        //     const Icon(Icons.check_circle_outline, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onPressed: () => setDialogState(
                              () => obscureConfirm = !obscureConfirm),
                        ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                    child: Text('إلغاء', style: AppTextStyles.labelMedium),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: isSubmitting ? 'جاري التحديث...' : 'تأكيد التغيير',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setDialogState(() {
                              isSubmitting = true;
                              dialogError = null;
                            });

                            final auth = context.read<AuthProvider>();
                            final ok = await auth.updatePassword(
                              newPassController.text,
                              currentPassword: currentPassController.text,
                            );

                            if (!ctx.mounted) return;

                            if (ok) {
                              Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'تم تحديث كلمة المرور بنجاح'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } else {
                              setDialogState(() {
                                isSubmitting = false;
                                dialogError = auth.errorMessage ??
                                    'تعذر تحديث كلمة المرور، يرجى المحاولة لاحقاً';
                              });
                            }
                          },
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
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final settings = profileProvider.settings;

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
                //icon: Icons.settings_suggest_rounded,
              ),

              const SizedBox(height: 24),

              // 2. 4 Metric Cards (Live from Supabase in a single horizontal row)
              // Builder(
              //   builder: (context) {
              //     final bookingsProvider = context.watch<BookingsProvider>();
              //     return ProviderStatsRow(
              //       minWidth: 800,
              //       cards: [
              //         ProviderMetricCard(
              //           title: 'إجمالي الحجوزات',
              //           value: '${bookingsProvider.totalConfirmedCount}',
              //           subText: 'حجز مسجل',
              //           icon: Icons.event_available_outlined,
              //           iconBg: const Color(0xFFFBEAEA),
              //           iconColor: const Color(0xFF681729),
              //         ),
              //         ProviderMetricCard(
              //           title: 'قيد التنفيذ',
              //           value: '${bookingsProvider.inProgressCount}',
              //           subText: 'متابعة ميدانية',
              //           icon: Icons.timelapse_rounded,
              //           iconBg: const Color(0xFFFEF3C7),
              //           iconColor: const Color(0xFFD97706),
              //         ),
              //         ProviderMetricCard(
              //           title: 'متوسط التقييم',
              //           value:
              //               '${profile.overallRating.toStringAsFixed(1)} ★',
              //           subText: 'تقييم عام',
              //           icon: Icons.star_rounded,
              //           iconBg: const Color(0xFFECFDF5),
              //           iconColor: const Color(0xFF059669),
              //         ),
              //         ProviderMetricCard(
              //           title: 'حالة الحساب',
              //           value: profile.isVerified ? 'موثق' : 'نشط',
              //           subText: profile.isVerified ? 'معتمد رسمي' : 'مسجل',
              //           subTextColor: AppColors.success,
              //           icon: Icons.verified_user_outlined,
              //           iconBg: const Color(0xFFEFF6FF),
              //           iconColor: const Color(0xFF2563EB),
              //         ),
              //       ],
              //     );
              //   },
              // ),

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
                      subtitle:
                          'تحديث كلمة المرور الخاصة بحسابك لتأمين دخولك إلى المنصة',
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
                      value: settings.newOrderNotifications,
                      onChanged: (val) => _updateNotificationSetting(
                        profileProvider,
                        settings.copyWith(newOrderNotifications: val),
                      ),
                    ),
                    const Divider(height: 18),
                    _buildSwitchRow(
                      title: 'إشعارات وتحديثات الحجوزات',
                      subtitle: 'تنبيهك بتغييرات المواعيد، تأكيدات الدفع من الإدارة، أو إلغاء الحجز من العملاء',
                      value: settings.orderUpdatesNotifications,
                      onChanged: (val) => _updateNotificationSetting(
                        profileProvider,
                        settings.copyWith(orderUpdatesNotifications: val),
                      ),
                    ),
                    const Divider(height: 18),
                    _buildSwitchRow(
                      title: 'التنبيهات الصوتية للطلبات العاجلة',
                      subtitle: 'تشغيل نغمة تنبيه مميزة عند اقتراب انتهاء مهلة الرد على طلب الحجز',
                      value: settings.soundAlerts,
                      onChanged: (val) => _updateNotificationSetting(
                        profileProvider,
                        settings.copyWith(soundAlerts: val),
                      ),
                    ),
                    const Divider(height: 18),
                    _buildSwitchRow(
                      title: 'ملخص الأداء والتقارير الأسبوعية',
                      subtitle: 'استلام تقرير تحليلي دوري يلخص عدد الحجوزات ونسبة الرضا وإجمالي الإيرادات',
                      value: settings.weeklyDigest,
                      onChanged: (val) => _updateNotificationSetting(
                        profileProvider,
                        settings.copyWith(weeklyDigest: val),
                      ),
                    ),
                    const Divider(height: 18),
                    _buildSettingActionRow(
                      title: 'اختبار التنبيهات الصوتية واللافتة المباشرة',
                      subtitle: 'تشغيل رنين التنبيه وعرض اللافتة الفورية للتأكد من عملها في متصفحك',
                      actionText: 'اختبار الآن',
                      icon: Icons.volume_up_outlined,
                      onTap: () {
                        LiveNotificationBannerService.instance.triggerTestAlert();
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
                          InkWell(
                            onTap: () => _showDeadlineDialog(context, profileProvider),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المهلة الافتراضية للرد على طلبات الحجز',
                                        style: AppTextStyles.labelMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'انقر لتعديل المهلة المعتمدة للرد على الطلبات',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.burgundyLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.burgundyLightBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${settings.defaultResponseHours} ساعة كحد أقصى',
                                          style: AppTextStyles.labelLarge.copyWith(
                                            color: AppColors.burgundy,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.edit_outlined,
                                          size: 14,
                                          color: AppColors.burgundy,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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