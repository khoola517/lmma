import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/service_model.dart';

class AddEditServiceScreen extends StatefulWidget {
  final ServiceModel? serviceToEdit;
  final ValueChanged<ServiceModel> onSave;
  final VoidCallback onCancel;

  const AddEditServiceScreen({
    super.key,
    this.serviceToEdit,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;

  late String _selectedCategory;
  late String _selectedOccasion;
  late bool _isAvailable;
  late List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    final s = widget.serviceToEdit;
    _nameController = TextEditingController(text: s?.name ?? '');
    _priceController = TextEditingController(text: s != null ? s.price.toStringAsFixed(0) : '');
    _durationController = TextEditingController(text: s != null ? s.executionTimeHours.toString() : '4');
    _descriptionController = TextEditingController(text: s?.description ?? '');

    _selectedCategory = s?.category ?? AppConstants.serviceCategories[1];
    _selectedOccasion = s?.occasion ?? AppConstants.eventTypes.first;
    _isAvailable = s?.isAvailable ?? true;
    _imageUrls = List.from(
      s?.imageUrls ??
          [
            'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80',
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=600&q=80',
          ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double price = double.tryParse(_priceController.text.trim()) ?? 0;
      final int duration = int.tryParse(_durationController.text.trim()) ?? 4;

      final updatedService = ServiceModel(
        id: widget.serviceToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        occasion: _selectedOccasion,
        price: price,
        executionTimeHours: duration,
        description: _descriptionController.text.trim(),
        imageUrls: _imageUrls,
        isAvailable: _isAvailable,
      );

      widget.onSave(updatedService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.serviceToEdit != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Back & Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
                      onPressed: widget.onCancel,
                      tooltip: 'العودة لخدماتي',
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'تعديل الخدمة' : 'إضافة خدمة جديدة',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'أدخل تفاصيل الخدمة والأسعار ومعرض الصور لعرضها على العملاء في منصة خِدمتي',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section 1: المعلومات الأساسية
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.article_outlined,
                        title: 'المعلومات الأساسية',
                        subtitle: 'البيانات الرئيسية للخدمة التي تظهر في نتائج البحث وقوائم الخدمات',
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'اسم الخدمة',
                        hint: 'مثال: تنسيق كوشة ملكية فاخرة بالورود الطبيعية',
                        controller: _nameController,
                        isRequired: true,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'يرجى إدخال اسم الخدمة' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تصنيف الخدمة',
                                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.surfaceLow,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                  items: AppConstants.serviceCategories
                                      .where((c) => c != 'الكل')
                                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedCategory = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المناسبة المقترحة',
                                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _selectedOccasion,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.surfaceLow,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                  items: AppConstants.eventTypes
                                      .map((evt) => DropdownMenuItem(value: evt, child: Text(evt)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedOccasion = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'وصف الخدمة التفصيلي',
                        hint: 'اكتب وصفاً موجزاً ومميزاً لمكونات وتفاصيل الخدمة وما تشمله بالتفصيل...',
                        controller: _descriptionController,
                        maxLines: 4,
                        isRequired: true,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'يرجى كتابة وصف للخدمة' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 2: معرض الصور
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.photo_library_outlined,
                            title: 'معرض الصور',
                            subtitle: 'أضف صوراً عالية الجودة تبرز تفاصيل وفخامة عملك لجذب العملاء',
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '${_imageUrls.length} صور مرفوعة',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Upload Area Dropzone
                      InkWell(
                        onTap: () {
                          setState(() {
                            _imageUrls.add(
                              'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=600&q=80',
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إضافة صورة تجريبية بنجاح إلى المعرض'),
                              backgroundColor: AppColors.burgundy,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borderDark,
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: AppColors.cardBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: AppColors.burgundy,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اسحب الصور وأفلتها هنا، أو اضغط للتصفح وإضافة صور جديدة',
                                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG, PNG أو WEBP (الحد الأقصى 5 ميجابايت للصورة)',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Photos thumbnails row
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ..._imageUrls.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final url = entry.value;
                            final isPrimary = idx == 0;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 120,
                                    height: 90,
                                    color: AppColors.surfaceLow,
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Center(
                                        child: Icon(Icons.broken_image, color: AppColors.textMuted),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isPrimary)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.burgundy,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, size: 10, color: AppColors.gold),
                                          const SizedBox(width: 2),
                                          Text(
                                            'الرئيسية',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: Colors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => _imageUrls.removeAt(idx));
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.delete, size: 14, color: AppColors.error),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 3: التسعير وحالة الخدمة
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.payments_outlined,
                        title: 'التسعير وحالة الخدمة',
                        subtitle: 'حدد التكلفة الإجمالية وفترة التجهيز وحالة ظهور الخدمة للعملاء',
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'سعر الخدمة الإجمالي',
                              hint: '450000',
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              suffixText: 'ر.ي (ريال يمني)',
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty ? 'يرجى تحديد السعر' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'مدة التنفيذ والتجهيز',
                              hint: '5',
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              suffixText: 'ساعات',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'حالة ظهور الخدمة للعملاء',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isAvailable = true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isAvailable ? AppColors.burgundy : AppColors.surfaceLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isAvailable ? AppColors.burgundy : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color: _isAvailable ? Colors.white : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'متاحة للحجز المباشر',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: _isAvailable ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isAvailable = false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isAvailable ? AppColors.burgundy : AppColors.surfaceLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !_isAvailable ? AppColors.burgundy : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pause_circle_outline,
                                      size: 18,
                                      color: !_isAvailable ? Colors.white : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'غير متاحة مؤقتاً',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: !_isAvailable ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Save / Cancel Footer Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'إلغاء والعودة',
                      variant: ButtonVariant.ghost,
                      onPressed: widget.onCancel,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: isEditing ? 'حفظ التعديلات' : 'حفظ ونشر الخدمة',
                      icon: Icons.check,
                      variant: ButtonVariant.primary,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      onPressed: _submit,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
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
}
