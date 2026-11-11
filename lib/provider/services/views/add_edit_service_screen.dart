import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:khadematy_web/core/constants/app_constants.dart';
import 'package:khadematy_web/core/services/storage_service.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/theme/app_text_styles.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_card.dart';
import 'package:khadematy_web/core/widgets/custom_text_field.dart';
import 'package:khadematy_web/provider/services/models/service_model.dart';

class ServiceImageEntry {
  final String id;
  String? url;
  Uint8List? bytes;
  String? fileName;
  bool isUploading;
  String? error;

  ServiceImageEntry({
    required this.id,
    this.url,
    this.bytes,
    this.fileName,
    this.isUploading = false,
    this.error,
  });
}

class AddEditServiceScreen extends StatefulWidget {
  final ServiceModel? serviceToEdit;
  final Future<void> Function(ServiceModel service) onSave;
  final VoidCallback onCancel;
  final List<String>? availableCategories;

  const AddEditServiceScreen({
    super.key,
    this.serviceToEdit,
    required this.onSave,
    required this.onCancel,
    this.availableCategories,
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

  late List<String> _categoriesList;
  late String _selectedCategory;
  late List<String> _occasionsList;
  late String _selectedOccasion;
  late bool _isAvailable;
  late List<ServiceImageEntry> _images;
  bool _isSaving = false;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    final s = widget.serviceToEdit;
    _nameController = TextEditingController(text: s?.name ?? '');
    _priceController = TextEditingController(
        text: s != null ? s.price.toStringAsFixed(0) : '');
    _durationController = TextEditingController(
        text: s != null ? s.executionTimeHours.toString() : '4');
    _descriptionController = TextEditingController(text: s?.description ?? '');

    final rawCategories = (widget.availableCategories != null &&
            widget.availableCategories!.isNotEmpty)
        ? widget.availableCategories!.where((c) => c != 'الكل').toList()
        : AppConstants.serviceCategories.where((c) => c != 'الكل').toList();

    _categoriesList = rawCategories.toSet().toList();

    if (s != null && s.category.isNotEmpty) {
      _selectedCategory = s.category;
      if (!_categoriesList.contains(_selectedCategory)) {
        _categoriesList.insert(0, _selectedCategory);
      }
    } else {
      _selectedCategory =
          _categoriesList.isNotEmpty ? _categoriesList.first : 'عام';
    }

    _occasionsList = List.from(AppConstants.eventTypes.toSet().toList());
    final rawOccasion = (s != null && s.occasion.isNotEmpty)
        ? s.occasion
        : AppConstants.eventTypes.first;
    if (!_occasionsList.contains(rawOccasion)) {
      _occasionsList.insert(0, rawOccasion);
    }
    _selectedOccasion = rawOccasion;

    _isAvailable = s?.isAvailable ?? true;

    // تهيئة الصور: لا نضيف صوراً ثابتة عند إضافة خدمة جديدة
    _images = (s?.imageUrls ?? [])
        .map((url) => ServiceImageEntry(
              id: UniqueKey().toString(),
              url: url,
            ))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// اختيار صور من داخل الجهاز ورفعها فورياً
  Future<void> _pickImages() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final pickedFiles = await StorageService.pickImagesFromDevice();
      if (pickedFiles.isEmpty) return;

      final List<ServiceImageEntry> newEntries = [];
      for (final file in pickedFiles) {
        final bytes = await file.readAsBytes();
        final entry = ServiceImageEntry(
          id: '${DateTime.now().microsecondsSinceEpoch}_${file.name}',
          bytes: bytes,
          fileName: file.name,
          isUploading: true,
        );
        newEntries.add(entry);
      }

      setState(() {
        _images.addAll(newEntries);
      });

      // رفع كل صورة إلى مساحة التخزين
      for (final entry in newEntries) {
        _uploadEntry(entry);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء اختيار الصور من الجهاز: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  /// رفع صورة فردية إلى مساحة تخزين Supabase
  Future<void> _uploadEntry(ServiceImageEntry entry) async {
    if (entry.bytes == null) return;
    try {
      final uploadedUrl = await StorageService.uploadServiceImage(
        bytes: entry.bytes!,
        originalName: entry.fileName ?? 'service_image.jpg',
      );

      if (!mounted) return;
      setState(() {
        entry.isUploading = false;
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          entry.url = uploadedUrl;
          entry.error = null;
        } else {
          entry.error = 'تعذر رفع الصورة إلى مساحة التخزين';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        entry.isUploading = false;
        entry.error = 'فشل الرفع: $e';
      });
    }
  }

  /// إعادة محاولة رفع صورة فشل رفعها
  void _retryUpload(ServiceImageEntry entry) {
    if (entry.bytes == null) return;
    setState(() {
      entry.isUploading = true;
      entry.error = null;
    });
    _uploadEntry(entry);
  }

  /// جعل الصورة في الفهرس المحدد صورة رئيسية
  void _setAsPrimary(int index) {
    if (index <= 0 || index >= _images.length) return;
    setState(() {
      final item = _images.removeAt(index);
      _images.insert(0, item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تعيين هذه الصورة كصورة رئيسية للخدمة بنجاح'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  /// حذف صورة من المعرض
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    // التحقق من اكتمال رفع الصور الجارية
    if (_images.any((img) => img.isUploading)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'يرجى الانتظار حتى تكتمل عملية رفع الصور المحددة من جهازك...'),
          backgroundColor: AppColors.burgundy,
        ),
      );
      return;
    }

    final validUrls = _images
        .where((img) => img.url != null && img.url!.trim().isNotEmpty)
        .map((img) => img.url!.trim())
        .toList();

    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final double price = double.tryParse(_priceController.text.trim()) ?? 0;
        final int duration = int.tryParse(_durationController.text.trim()) ?? 4;

        final updatedService = ServiceModel(
          id: widget.serviceToEdit?.id ?? '',
          name: _nameController.text.trim(),
          category: _selectedCategory,
          occasion: _selectedOccasion,
          price: price,
          executionTimeHours: duration,
          description: _descriptionController.text.trim(),
          imageUrls: validUrls,
          isAvailable: _isAvailable,
        );

        await widget.onSave(updatedService);
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
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
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.burgundy),
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
                        // Text(
                        //   'أدخل تفاصيل الخدمة والأسعار ومعرض الصور لعرضها على العملاء في منصة خِدمتي',
                        //   style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        // ),
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
                          subtitle: ''
                          //subtitle: 'البيانات الرئيسية للخدمة التي تظهر في نتائج البحث وقوائم الخدمات',
                          ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'اسم الخدمة',
                        hint: 'مثال: تنسيق كوشة ملكية فاخرة بالورود الطبيعية',
                        controller: _nameController,
                        isRequired: true,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'يرجى إدخال اسم الخدمة'
                                : null,
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
                                  style: AppTextStyles.labelLarge
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _categoriesList
                                          .contains(_selectedCategory)
                                      ? _selectedCategory
                                      : (_categoriesList.isNotEmpty
                                          ? _categoriesList.first
                                          : null),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.surfaceLow,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                  ),
                                  items: _categoriesList
                                      .toSet()
                                      .map((cat) => DropdownMenuItem(
                                          value: cat, child: Text(cat)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedCategory = val);
                                    }
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
                                  style: AppTextStyles.labelLarge
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value:
                                      _occasionsList.contains(_selectedOccasion)
                                          ? _selectedOccasion
                                          : (_occasionsList.isNotEmpty
                                              ? _occasionsList.first
                                              : null),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.surfaceLow,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                  ),
                                  items: _occasionsList
                                      .toSet()
                                      .map((evt) => DropdownMenuItem(
                                          value: evt, child: Text(evt)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedOccasion = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'وصف الخدمة ',
                        hint:
                            'اكتب وصفاً موجزاً ومميزاً لمكونات وتفاصيل الخدمة وما تشمله بالتفصيل...',
                        controller: _descriptionController,
                        maxLines: 4,
                        isRequired: true,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'يرجى كتابة وصف للخدمة'
                                : null,
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
                              subtitle: ''
                              //subtitle: 'اختر صوراً حقيقية من داخل جهازك لتقديم خدمتك بأفضل جودة وفخامة للعملاء',
                              ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          //   decoration: BoxDecoration(
                          //     color: _images.isEmpty ? AppColors.surfaceLow : AppColors.burgundyLight.withOpacity(0.3),
                          //     borderRadius: BorderRadius.circular(20),
                          //     border: Border.all(
                          //       color: _images.isEmpty ? AppColors.border : AppColors.burgundy.withOpacity(0.5),
                          //     ),
                          //   ),
                          //   child: Text(
                          //     _images.isEmpty
                          //         ? 'لا توجد صور'
                          //         : '${_images.where((i) => i.url != null).length} من ${_images.length} صور جاهزة',
                          //     style: AppTextStyles.labelSmall.copyWith(
                          //       color: _images.isEmpty ? AppColors.textSecondary : AppColors.burgundy,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Upload Area Dropzone - اختيار من الجهاز
                      InkWell(
                        onTap: _isPicking ? null : _pickImages,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.burgundy.withOpacity(0.4),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: AppColors.burgundy,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Text(
                              //   _isPicking
                              //       ? 'جارِ فتح نافذة اختيار الملفات...'
                              //       : 'اضغط هنا لاختيار صور من داخل جهازك (الكمبيوتر أو الهاتف)',
                              //   style: AppTextStyles.labelLarge.copyWith(
                              //     fontWeight: FontWeight.w700,
                              //     color: AppColors.textPrimary,
                              //   ),
                              // ),
                              // const SizedBox(height: 4),
                              Text(
                                'JPG, PNG أو WEBP — يمكنك تحديد صورة واحدة أو عدة صور معاً من جهازك',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.burgundy,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.folder_open_rounded,
                                        size: 16, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'تصفح ملفات جهازي',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Photos thumbnails row or empty state
                      if (_images.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.textSecondary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'لم تتم إضافة أي صور بعد. اضغط في الأعلى لاختيار صور المنتج أو الخدمة مباشرة من جهازك.',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ..._images.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              final isPrimary = idx == 0;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 135,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isPrimary
                                            ? AppColors.burgundy
                                            : AppColors.border,
                                        width: isPrimary ? 2 : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Display image: from memory bytes if freshly picked, or from network url
                                          if (item.bytes != null)
                                            Image.memory(
                                              item.bytes!,
                                              fit: BoxFit.cover,
                                            )
                                          else if (item.url != null &&
                                              item.url!.isNotEmpty)
                                            Image.network(
                                              item.url!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: AppColors.textMuted),
                                              ),
                                            )
                                          else
                                            const Center(
                                              child: Icon(Icons.image,
                                                  color: AppColors.textMuted),
                                            ),

                                          // Uploading indicator overlay
                                          if (item.isUploading)
                                            Container(
                                              color: Colors.black
                                                  .withOpacity(0.65),
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'جارِ الرفع...',
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                          // Error overlay
                                          if (item.error != null &&
                                              !item.isUploading)
                                            Container(
                                              color: Colors.black
                                                  .withOpacity(0.75),
                                              padding: const EdgeInsets.all(4),
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons.error_outline,
                                                        color: AppColors.error,
                                                        size: 20),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'فشل الرفع',
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    InkWell(
                                                      onTap: () =>
                                                          _retryUpload(item),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .burgundy,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Text(
                                                          'إعادة المحاولة',
                                                          style: AppTextStyles
                                                              .labelSmall
                                                              .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Primary Image Badge
                                  if (isPrimary)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.burgundy,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                size: 10,
                                                color: AppColors.gold),
                                            const SizedBox(width: 3),
                                            Text(
                                              'الرئيسية',
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else if (!item.isUploading)
                                    // Button to make this image primary
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: InkWell(
                                        onTap: () => _setAsPrimary(idx),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_border,
                                                  size: 12,
                                                  color: AppColors.textPrimary),
                                              const SizedBox(width: 2),
                                              Text(
                                                'تعيين كرئيسية',
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Delete Button
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: InkWell(
                                      onTap: () => _removeImage(idx),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.15),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.delete,
                                            size: 14, color: AppColors.error),
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
                        subtitle: '',
                        //subtitle: 'حدد التكلفة الإجمالية وفترة التجهيز وحالة ظهور الخدمة للعملاء',
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'سعر الخدمة',
                              hint: '450000',
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              suffixText: 'ر.ي (ريال يمني)',
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'يرجى تحديد السعر'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'مدة التنفيذ',
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
                        style: AppTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isAvailable = true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isAvailable
                                      ? AppColors.burgundy
                                      : AppColors.surfaceLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isAvailable
                                        ? AppColors.burgundy
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon(
                                    //   Icons.check_circle,
                                    //   size: 18,
                                    //   color: _isAvailable ? Colors.white : AppColors.textSecondary,
                                    // ),
                                    // const SizedBox(width: 8),
                                    Text(
                                      'متاحة للحجز المباشر',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: _isAvailable
                                            ? Colors.white
                                            : AppColors.textPrimary,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isAvailable
                                      ? AppColors.burgundy
                                      : AppColors.surfaceLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !_isAvailable
                                        ? AppColors.burgundy
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon(
                                    //   Icons.pause_circle_outline,
                                    //   size: 18,
                                    //   color: !_isAvailable ? Colors.white : AppColors.textSecondary,
                                    // ),
                                    // const SizedBox(width: 8),
                                    Text(
                                      'غير متاحة مؤقتاً',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: !_isAvailable
                                            ? Colors.white
                                            : AppColors.textPrimary,
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
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _submit,
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
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
