import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../models/service_model.dart';
import '../../../providers/services_provider.dart';
import 'add_edit_service_screen.dart';
import 'widgets/service_details_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _isCreatingOrEditing = false;
  ServiceModel? _serviceToEdit;

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
              child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
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
            onPressed: () {
              context.read<ServicesProvider>().deleteService(service.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الخدمة بنجاح'),
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
    final servicesProvider = context.watch<ServicesProvider>();

    if (_isCreatingOrEditing) {
      return AddEditServiceScreen(
        serviceToEdit: _serviceToEdit,
        onSave: (savedService) {
          if (_serviceToEdit != null) {
            servicesProvider.updateService(savedService);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الخدمة بنجاح'),
                backgroundColor: AppColors.burgundy,
              ),
            );
          } else {
            servicesProvider.addService(savedService);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة الخدمة الجديدة بنجاح ونشرها'),
                backgroundColor: AppColors.burgundy,
              ),
            );
          }
          _closeForm();
        },
        onCancel: _closeForm,
      );
    }

    final services = servicesProvider.services;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
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
                        'خدماتي',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.burgundyLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${servicesProvider.totalServicesCount} خدمات',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إدارة باقات وخدمات المناسبات المعروضة لعملائك وتعديل تفاصيلها والأسعار',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              CustomButton(
                text: 'إضافة خدمة جديدة',
                icon: Icons.add,
                variant: ButtonVariant.primary,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                onPressed: _openAddService,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Categories Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.serviceCategories.map((cat) {
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
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.burgundy : AppColors.border,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Services Grid
          if (services.isEmpty)
            CustomCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'لم يتم العثور على خدمات مطابقة',
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'جرّب تغيير خيارات البحث أو التصنيفات لعرض الخدمات المتوفرة.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
                final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 20)) / crossAxisCount;

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
          // Image Box with Category & Status Overlay
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: AppColors.surfaceLow,
                child: service.imageUrls.isNotEmpty
                    ? Image.network(
                        service.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.celebration, size: 48, color: AppColors.burgundy),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.celebration, size: 48, color: AppColors.burgundy),
                      ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 12, color: AppColors.goldDark),
                      const SizedBox(width: 4),
                      Text(
                        '1/${service.imageUrls.length}',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          '${service.price.toStringAsFixed(0)} ر.ي',
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                onEdit: () => _openEditService(service),
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
