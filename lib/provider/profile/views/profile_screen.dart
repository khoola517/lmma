import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/services/storage_service.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/provider/profile/models/provider_profile_model.dart';
import 'package:khadematy_web/provider/profile/providers/profile_provider.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';
import 'edit_profile_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingLogo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> _pickAndUploadLogo(ProfileProvider provider) async {
    try {
      final image = await StorageService.pickSingleImageFromDevice();
      if (image == null) return;

      setState(() => _isUploadingLogo = true);

      final bytes = await image.readAsBytes();
      final url = await provider.uploadProfileLogo(
        bytes: bytes,
        fileName: image.name,
      );

      if (!mounted) return;

      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع وتحديث شعار المنشأة بنجاح في Supabase'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                provider.errorMessage ?? 'فشل رفع الشعار إلى مساحة التخزين'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء اختيار أو رفع الصورة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingLogo = false);
      }
    }
  }

  Future<void> _openEditDialog(
      ProviderProfileModel profile, ProfileProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EditProfileDialog(
        profile: profile,
        onSave: (updated) => provider.updateProfile(
          businessName: updated.businessName,
          phone: updated.phone,
          email: updated.email,
          location: updated.location,
          category: updated.category,
          bio: updated.bio,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      try {
        context.read<AuthProvider>().restoreSession();
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ وتحديث بيانات الملف الشخصي بنجاح في '),
          backgroundColor: AppColors.burgundy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final isLoading = profileProvider.isLoading && profile.id == null;

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.burgundy),
            SizedBox(height: 16),
            Text(
              'جاري تحميل البيانات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

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
                title: 'الملف الشخصي لمقدم الخدمة',
                subtitle:
                    'البيانات الرسمية ومعلومات التواصل والنشاط التجاري المعتمدة في منصة خِدمتي',
                icon: Icons.account_circle_outlined,
              ),

              const SizedBox(height: 24),

              // 2. 4 Metric Cards (Live from Supabase in a single horizontal row)
              ProviderStatsRow(
                minWidth: 800,
                cards: [
                  ProviderMetricCard(
                    title: 'الحجوزات المكتملة',
                    value: '${profile.completedBookingsCount}',
                    subText: 'حجز منفذ',
                    icon: Icons.task_alt_rounded,
                    iconBg: const Color(0xFFFBEAEA),
                    iconColor: const Color(0xFF681729),
                  ),
                  ProviderMetricCard(
                    title: 'متوسط التقييم',
                    value: '${profile.overallRating.toStringAsFixed(1)} ★',
                    subText: 'تقييم عام',
                    icon: Icons.star_rounded,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                  ),
                  ProviderMetricCard(
                    title: 'تصنيف النشاط',
                    value: profile.category.isNotEmpty
                        ? profile.category
                        : 'تنظيم مناسبات',
                    subText: 'المجال المعتمد',
                    icon: Icons.category_outlined,
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
              ),

              const SizedBox(height: 24),

              // Edit Action Button Row
              Align(
                alignment: Alignment.centerLeft,
                child: CustomButton(
                  text: 'تعديل الملف الشخصي',
                  icon: Icons.edit_note_rounded,
                  variant: ButtonVariant.primary,
                  onPressed: () => _openEditDialog(profile, profileProvider),
                ),
              ),

              const SizedBox(height: 24),

              // Error notification if present
              if (profileProvider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profileProvider.errorMessage!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            profileProvider.loadProfile(force: true),
                        child: const Text('إعادة المحاولة',
                            style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ],
                  ),
                ),

              // Main Profile Card
              CustomCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Logo & Brand Header with Upload Trigger
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLow,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.goldBorder, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(200, 169, 107, 0.15),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: _isUploadingLogo
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.burgundy,
                                        ),
                                      )
                                    : (profile.logoUrl != null &&
                                            profile.logoUrl!.isNotEmpty)
                                        ? Image.network(
                                            profile.logoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Center(
                                              child: Icon(
                                                Icons.diamond_outlined,
                                                color: AppColors.gold,
                                                size: 40,
                                              ),
                                            ),
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.diamond_outlined,
                                              color: AppColors.gold,
                                              size: 40,
                                            ),
                                          ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: InkWell(
                                onTap: _isUploadingLogo
                                    ? null
                                    : () => _pickAndUploadLogo(profileProvider),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.burgundy,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      profile.businessName,
                                      style:
                                          AppTextStyles.headlineMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 10, vertical: 3),
                                  //   decoration: BoxDecoration(
                                  //     color: profile.isVerified
                                  //         ? AppColors.goldLight
                                  //         : AppColors.surfaceLow,
                                  //     borderRadius: BorderRadius.circular(12),
                                  //     border: Border.all(
                                  //       color: profile.isVerified
                                  //           ? AppColors.goldBorder
                                  //           : AppColors.border,
                                  //     ),
                                  //   ),
                                  //   child: Text(
                                  //     profile.isVerified
                                  //         ? 'حساب معتمد وموثق'
                                  //         : 'قيد المراجعة',
                                  //     style: AppTextStyles.labelSmall.copyWith(
                                  //       color: profile.isVerified
                                  //           ? AppColors.goldDark
                                  //           : AppColors.textSecondary,
                                  //       fontWeight: FontWeight.w700,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'حساب مزود خدمات مسجل في منصة خِدمتي للمناسبات والأفراح',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Stats Chips Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            label: 'التقييم العام',
                            value:
                                '★ ${profileProvider.averageRating.toStringAsFixed(1)}',
                            color: AppColors.goldDark,
                          ),
                          Container(
                              width: 1, height: 32, color: AppColors.border),
                          _buildStatItem(
                            label: 'إجمالي التقييمات',
                            value: '${profileProvider.totalReviewsCount} تقييم',
                            color: AppColors.burgundy,
                          ),
                          Container(
                              width: 1, height: 32, color: AppColors.border),
                          _buildStatItem(
                            label: 'الحجوزات المكتملة',
                            value: '${profile.completedBookingsCount} حجز',
                            color: Colors.green.shade800,
                          ),
                        ],
                      ),
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
                                value: profile.phone.isNotEmpty
                                    ? profile.phone
                                    : 'غير محدد',
                                isLtr: true,
                              ),
                            ),
                            SizedBox(
                              width: colWidth,
                              child: _buildInfoItem(
                                icon: Icons.email_outlined,
                                label: 'البريد الإلكتروني',
                                value: profile.email.isNotEmpty
                                    ? profile.email
                                    : 'غير محدد',
                                isLtr: true,
                              ),
                            ),
                            SizedBox(
                              width: colWidth,
                              child: _buildInfoItem(
                                icon: Icons.location_on_outlined,
                                label: 'المدينة والمنطقة',
                                value: profile.location.isNotEmpty
                                    ? profile.location
                                    : 'غير محدد',
                              ),
                            ),
                            SizedBox(
                              width: colWidth,
                              child: _buildInfoItem(
                                icon: Icons.category_outlined,
                                label: 'نوع الخدمة / التخصص الرئيسي',
                                value: profile.category.isNotEmpty
                                    ? profile.category
                                    : 'خدمات عامة',
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
                                      const Icon(Icons.description_outlined,
                                          size: 16, color: AppColors.burgundy),
                                      const SizedBox(width: 6),
                                      Text(
                                        'نبذة تعريفية عن مقدم الخدمة',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                                color: AppColors.textMuted),
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
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      profile.bio.isNotEmpty
                                          ? profile.bio
                                          : 'لم يتم إضافة نبذة تعريفية بعد. يمكنك الضغط على "تعديل الملف الشخصي" لإضافتها.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: profile.bio.isNotEmpty
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
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
                        border:
                            Border.all(color: AppColors.burgundyLightBorder),
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
                            child: const Icon(Icons.shield_outlined,
                                color: AppColors.gold, size: 24),
                          ),
                          const SizedBox(width: 16),
                          // Expanded(
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         'وثيقة التزام الجودة والاعتماد',
                          //         style: AppTextStyles.labelLarge.copyWith(
                          //           color: AppColors.burgundy,
                          //           fontWeight: FontWeight.w800,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 2),
                          //       Text(
                          //         'بيانات ملفك الشخصي متزامنة لحظياً مع خوادم خِدمتي وتخضع لمعايير الجودة والضمان لخدمة العملاء بأعلى احترافية.',
                          //         style: AppTextStyles.bodySmall
                          //             .copyWith(color: AppColors.textSecondary),
                          //       ),
                          //     ],
                          //   ),
                          // ),
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

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
            Text(label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textMuted)),
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
