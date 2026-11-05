import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetAudience = 'all'; // 'all', 'providers', 'customers'
  String _notificationType = 'announcement'; // 'announcement', 'warning', 'info'

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend(AdminDashboardProvider adminData) {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء عنوان الإشعار والرسالة أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    adminData.sendBroadcastNotification(
      title: title,
      message: message,
      targetAudience: _targetAudience,
      type: _notificationType,
    );

    _titleController.clear();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم بث الإشعار الإداري لجميع المستخدمين المستهدفين بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final notifications = adminData.broadcastNotifications;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner Card
          const AdminPageHeaderCard(
            title: 'إدارة الإشعارات والتعميمات',
            subtitle: 'بث تنبيهات وتوجيهات رسمية لجميع مستخدمي ومزودي منصة خِدمتي',
            icon: Icons.campaign_rounded,
            breadcrumb: 'لوحة التحكم / الإشعارات',
          ),

          const SizedBox(height: 24),

          // Notification Composer Card
          CustomCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.burgundyLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.campaign_rounded, color: AppColors.burgundy, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'إرسال إشعار تعميم جديد',
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Title
                TextField(
                  controller: _titleController,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الإشعار *',
                    hintText: 'مثال: تحديث شروط الحجز أو عطلة عيد الأضحى المبارك',
                  ),
                ),
                const SizedBox(height: 14),

                // Message
                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'نص الإشعار والتوجيهات *',
                    hintText: 'اكتب نص الرسالة التي ستصل في مركز إشعارات التطبيق...',
                  ),
                ),
                const SizedBox(height: 16),

                // Audience & Type
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _targetAudience,
                        decoration: const InputDecoration(labelText: 'الفئة المستهدفة'),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('كافة المستخدمين (عملاء + مزودين)')),
                          DropdownMenuItem(value: 'providers', child: Text('مقدمو الخدمات فقط')),
                          DropdownMenuItem(value: 'customers', child: Text('العملاء فقط')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _targetAudience = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _notificationType,
                        decoration: const InputDecoration(labelText: 'نوع الإشعار'),
                        items: const [
                          DropdownMenuItem(value: 'announcement', child: Text('إعلان رسمي عام')),
                          DropdownMenuItem(value: 'warning', child: Text('تنبيه هام ومستعجل')),
                          DropdownMenuItem(value: 'info', child: Text('إشعار توضيحي')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _notificationType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton(
                    text: 'إرسال وبث الإشعار الآن',
                    icon: Icons.send_rounded,
                    variant: ButtonVariant.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    onPressed: () => _handleSend(adminData),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Past Sent Notifications
          Text(
            'سجل التعميمات السابقة (${notifications.length})',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          if (notifications.isEmpty)
            CustomCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'لم يتم إرسال أي إشعارات تعميمية مؤخراً.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = notifications[index];
                final title = n['title'] as String;
                final msg = n['message'] as String;
                final aud = n['target_audience'] as String;

                return CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_outlined,
                            color: AppColors.burgundy, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(msg, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          aud == 'all'
                              ? 'الكل'
                              : (aud == 'providers' ? 'المزودين' : 'العملاء'),
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}