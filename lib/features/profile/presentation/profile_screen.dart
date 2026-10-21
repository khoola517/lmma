import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../models/provider_profile_model.dart';
import '../../../providers/profile_provider.dart';
import 'widgets/edit_profile_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEditDialog(BuildContext context, ProviderProfileModel profile, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => EditProfileDialog(
        profile: profile,
        onSave: (updated) {
          provider.updateProfile(
            businessName: updated.businessName,
            phone: updated.phone,
            email: updated.email,
            location: updated.location,
            category: updated.category,
            bio: updated.bio,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الملف الشخصي بنجاح'),
              backgroundColor: AppColors.burgundy,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'الملف الشخصي لمقدم الخدمة',
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: AppColors.burgundy, size: 22),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'البيانات والمعلومات الأساسية المسجلة لمقدم الخدمة في منصة خِدمتي',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: 'تعديل الملف الشخصي',
                    icon: Icons.edit,
                    variant: ButtonVariant.primary,
                    onPressed: () => _openEditDialog(context, profile, profileProvider),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main Profile Card
              CustomCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Logo & Brand Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.goldBorder, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(200, 169, 107, 0.15),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.diamond_outlined, color: AppColors.gold, size: 40),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    profile.businessName,
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.goldBorder),
                                    ),
                                    child: Text(
                                      'حساب معتمد',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.goldDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'البيانات الرسمية المعتمدة في منصة خِدمتي للمناسبات',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    const Divider(height: 1),
                    const SizedBox(height: 28),

                    // Grid of Key Information
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final colWidth = constraints.maxWidth > 600
                            ? (constraints.maxWidth - 24) / 2
                            : constraints.maxWidth;

                        return Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            SizedBox(
                              width: colWidth,
                              child: _buildInfoItem(
                                icon: Icons.phone_outlined,
                                label: 'رقم الهاتف للتواصل',
                                value: profile.phone,
                                isLtr: true,
                              ),
                            ),
                            SizedBox(
                              width: colWidth,
                              child: _buildInfoItem(
                                icon: Icons.email_outlined,
                                label: 'البريد الإلكتروني',
                                value: profile.email,
                                isLtr: true,
                              ),
                            ),
                            SizedBox(
                              width: colWidth,
                              child: _buildInfoItem(
                                icon: Icons.location_on_outlined,
                                label: 'المدينة والمنطقة',
                                value: profile.location,
                              ),
                            ),
                            SizedBox(
                              width: colWidth,
                              child: _buildInfoItem(
                                icon: Icons.category_outlined,
                                label: 'نوع الخدمة / التخصص الرئيسي',
                                value: profile.category,
                                valueColor: AppColors.burgundy,
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.description_outlined, size: 16, color: AppColors.burgundy),
                                      const SizedBox(width: 6),
                                      Text(
                                        'نبذة تعريفية عن مقدم الخدمة',
                                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      profile.bio,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        height: 1.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Badges and Guarantees
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.burgundyLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.burgundyLightBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.burgundy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined, color: AppColors.gold, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'وثيقة التزام الجودة والاعتماد',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.burgundy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'حسابك موثق رسمياً ويخضع لمعايير الجودة والضمان في منصة خِدمتي لخدمة العملاء بأعلى احترافية.',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isLtr = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.burgundy),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
          style: AppTextStyles.titleMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
