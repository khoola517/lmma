import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/provider/services/models/service_model.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';
import 'package:khadematy_web/provider/services/providers/services_provider.dart';
import 'package:khadematy_web/provider/shell/views/provider_page_header_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_metric_card.dart';
import 'package:khadematy_web/provider/shell/views/provider_stats_row.dart';
import 'add_edit_service_screen.dart';
import 'service_details_dialog.dart';
import 'service_image_carousel.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _isCreatingOrEditing = false;
  ServiceModel? _serviceToEdit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    context.read<ServicesProvider>().loadServices(
          providerId: auth.currentProviderId,
        );
  }

  void _openAddService() {
    setState(() {
      _serviceToEdit = null;
      _isCreatingOrEditing = true;
    });
  }

  void _openEditService(ServiceModel service) {
    setState(() {
      _serviceToEdit = service;
      _isCreatingOrEditing = true;
    });
  }

  void _closeForm() {
    setState(() {
      _isCreatingOrEditing = false;
      _serviceToEdit = null;
    });
  }

  void _confirmDelete(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.cardBg,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text('تأكيد حذف الخدمة', style: AppTextStyles.headlineSmall),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف خدمة "${service.name}"؟ لن تظهر الخدمة بعد ذلك للعملاء في نتائج البحث.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: AppTextStyles.labelMedium),
          ),
          CustomButton(
            text: 'حذف الخدمة',
            variant: ButtonVariant.danger,
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<ServicesProvider>();
              final success = await provider.deleteService(service.id);
              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ??
                          'تم حذف الخدمة بنجاح من قاعدة البيانات',
                    ),
                    backgroundColor: AppColors.burgundy,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ??
                          'فشل حذف الخدمة، يرجى المحاولة لاحقاً',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = context.watch<ServicesProvider>();
    final auth = context.watch<AuthProvider>();

    if (_isCreatingOrEditing) {
      return AddEditServiceScreen(
        serviceToEdit: _serviceToEdit,
        availableCategories: servicesProvider.availableCategories,
        onSave: (savedService) async {
          final messenger = ScaffoldMessenger.of(context);
          if (_serviceToEdit != null) {
            final success = await servicesProvider.updateService(savedService);
            if (!mounted) return;
            if (success) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('تم تحديث الخدمة بنجاح في قاعدة البيانات'),
                  backgroundColor: AppColors.burgundy,
                ),
              );
              _closeForm();
            } else {
              messenger.showSnackBar(
                SnackBar(
                  content:
                      Text(servicesProvider.errorMessage ?? 'فشل تحديث الخدمة'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          } else {
            final success = await servicesProvider.addService(
              savedService,
              providerId: auth.currentProviderId,
            );
            if (!mounted) return;
            if (success) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة الخدمة الجديدة بنجاح'),
                  backgroundColor: AppColors.burgundy,
                ),
              );
              _closeForm();
            } else {
              messenger.showSnackBar(
                SnackBar(
                  content:
                      Text(servicesProvider.errorMessage ?? 'فشل إضافة الخدمة'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        onCancel: _closeForm,
      );
    }

    final services = servicesProvider.services;
    final categories = servicesProvider.availableCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner Card with golden yellow gradient
          const ProviderPageHeaderCard(
            title: 'خدماتي',
            subtitle:
                'إدارة باقات وخدمات المناسبات المعروضة في منصة خِدمتي والأسعار المباشرة وتحديث الحالة',
            icon: Icons.category_outlined,
          ),

          const SizedBox(height: 24),

          // 2. 4 Metric Cards (Live from Supabase in a single horizontal row)
          Builder(
            builder: (context) {
              final activeCount = services.where((s) => s.isAvailable).length;
              final pausedCount = services.where((s) => !s.isAvailable).length;

              return ProviderStatsRow(
                cards: [
                  ProviderMetricCard(
                    title: 'إجمالي الخدمات',
                    value: '${services.length}',
                    subText: 'خدمة مسجلة',
                    icon: Icons.category_outlined,
                    iconBg: const Color(0xFFFBEAEA),
                    iconColor: const Color(0xFF681729),
                  ),
                  ProviderMetricCard(
                    title: 'الخدمات النشطة',
                    value: '$activeCount',
                    subText: 'معروضة للجمهور',
                    subTextColor: AppColors.success,
                    icon: Icons.check_circle_outline_rounded,
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF059669),
                  ),
                  ProviderMetricCard(
                    title: 'الخدمات المتوقفة',
                    value: '$pausedCount',
                    subText: 'معطلة مؤقتاً',
                    subTextColor: pausedCount > 0
                        ? AppColors.warning
                        : AppColors.textMuted,
                    icon: Icons.pause_circle_outline_rounded,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                  ),
                  ProviderMetricCard(
                    title: 'التصنيفات المتاحة',
                    value: '${categories.length}',
                    subText: 'تصنيف معتمد',
                    icon: Icons.grid_view_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 3. Actions & Categories Filter Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                text: 'إضافة خدمة جديدة',
                icon: Icons.add,
                variant: ButtonVariant.primary,
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                onPressed: _openAddService,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Categories Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = servicesProvider.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) servicesProvider.setCategory(cat);
                    },
                    selectedColor: AppColors.burgundy,
                    backgroundColor: AppColors.cardBg,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.burgundy : AppColors.border,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Loading Indicator or Grid
          if (servicesProvider.isLoading &&
              servicesProvider.allServices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.burgundy),
                    SizedBox(height: 16),
                    Text(
                      'جاري جلب الخدمات من قاعدة بيانات خِدمتي...',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Color(0xFF6E6367),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (services.isEmpty)
            CustomCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 54, color: AppColors.textMuted),
                    const SizedBox(height: 14),
                    Text(
                      'لم يتم إضافة خدمات بعد',
                      style: AppTextStyles.headlineSmall
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ بإضافة باقات وخدمات منشأتك لتظهر فوراً لعملاء خِدمتي عبر تطبيق الجوال.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'إضافة أول خدمة الآن',
                      //icon: Icons.add,
                      variant: ButtonVariant.primary,
                      onPressed: _openAddService,
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 3
                    : (constraints.maxWidth > 700 ? 2 : 1);
                final cardWidth =
                    (constraints.maxWidth - ((crossAxisCount - 1) * 20)) /
                        crossAxisCount;

                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: services.map((s) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildServiceCard(context, s),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(46, 37, 39, 0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Box Carousel with Category & Status Overlay
          ServiceImageCarousel(
            imageUrls: service.imageUrls,
            height: 180,
            onImageTap: () {
              showDialog(
                context: context,
                builder: (ctx) => ServiceDetailsDialog(
                  service: service,
                  onEdit: () {
                    Navigator.pop(ctx);
                    _openEditService(service);
                  },
                ),
              );
            },
            overlays: [
              // Availability Toggle Badge (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () {
                    context
                        .read<ServicesProvider>()
                        .toggleServiceAvailability(service.id);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: service.isAvailable
                          ? AppColors.success.withOpacity(0.92)
                          : const Color(0xFF6E6367).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          service.isAvailable
                              ? Icons.check_circle
                              : Icons.pause_circle_outline,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.isAvailable ? 'متاحة' : 'معطلة مؤقتاً',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Category Badge (Bottom Right)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    service.category,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Body Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'المناسبة: ${service.occasion}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Price & Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          '${service.price.toStringAsFixed(0)} ${service.currency}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Edit Button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: AppColors.textSecondary,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceLow,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          tooltip: 'تعديل الخدمة',
                          onPressed: () => _openEditService(service),
                        ),
                        const SizedBox(width: 6),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppColors.error,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.errorBg,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          tooltip: 'حذف الخدمة',
                          onPressed: () => _confirmDelete(context, service),
                        ),
                        const SizedBox(width: 8),
                        // Details Button
                        CustomButton(
                          text: 'التفاصيل',
                          variant: ButtonVariant.primary,
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => ServiceDetailsDialog(
                                service: service,
                                onEdit: () {
                                  Navigator.pop(ctx);
                                  _openEditService(service);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
