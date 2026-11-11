import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/services/storage_service.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_page_header_card.dart';
import 'package:khadematy_web/admin/shell/views/admin_stat_card.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  String _selectedStatusFilter = 'جميع الحالات (الكل)';

  void _showAddCategoryDialog(
      BuildContext context, AdminDashboardProvider adminData) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final imageController = TextEditingController();
    final sortController =
        TextEditingController(text: '${adminData.categories.length + 1}');
    bool isActive = true;
    Uint8List? pickedImageBytes;
    String? pickedImageName;
    bool isUploadingImage = false;
    bool showManualUrlField = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_box_outlined,
                    color: AppColors.burgundy, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'إضافة تصنيف مناسبات جديد',
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E2527),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. اسم التصنيف
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'اسم التصنيف *',
                      labelStyle: GoogleFonts.cairo(fontSize: 12),
                      hintText: 'مثال: القاعات الملكية / تصوير وتوثيق',
                      hintStyle: GoogleFonts.cairo(
                          fontSize: 12, color: AppColors.textMuted),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. الوصف التعريفي
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'الوصف التعريفي *',
                      labelStyle: GoogleFonts.cairo(fontSize: 12),
                      hintText:
                          'وصف يوضح طبيعة الخدمات المندرجة تحت هذا التصنيف...',
                      hintStyle: GoogleFonts.cairo(
                          fontSize: 12, color: AppColors.textMuted),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. رفع صورة من الجهاز
                  Text(
                    'صورة غلاف التصنيف:',
                    style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E2527)),
                  ),
                  const SizedBox(height: 6),
                  _buildImagePickerBox(
                    pickedBytes: pickedImageBytes,
                    imageUrl: imageController.text.trim(),
                    isUploading: isUploadingImage,
                    onPickImage: () async {
                      final file =
                          await StorageService.pickSingleImageFromDevice();
                      if (file != null) {
                        final bytes = await file.readAsBytes();
                        setDialogState(() {
                          pickedImageBytes = bytes;
                          pickedImageName = file.name;
                        });
                      }
                    },
                    onRemoveImage: () {
                      setDialogState(() {
                        pickedImageBytes = null;
                        pickedImageName = null;
                        imageController.clear();
                      });
                    },
                  ),

                  // خيار إدخال الرابط يدوياً إن رغب المستخدم
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setDialogState(() {
                        showManualUrlField = !showManualUrlField;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showManualUrlField
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.burgundy,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          showManualUrlField
                              ? 'إخفاء حقل الرابط المباشر'
                              : 'أو إدخال رابط صورة مباشرة (URL)',
                          style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: AppColors.burgundy,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (showManualUrlField) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageController,
                      style: GoogleFonts.cairo(fontSize: 12),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: 'رابط الصورة المباشر (URL)',
                        labelStyle: GoogleFonts.cairo(fontSize: 11),
                        hintText: 'https://...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 4. ترتيب العرض وحالة التفعيل
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: sortController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.cairo(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'ترتيب العرض في التطبيق *',
                                labelStyle: GoogleFonts.cairo(fontSize: 12),
                                hintText: '1, 2, 3...',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                suffixIcon: const Tooltip(
                                  message:
                                      'يحدد أولوية وموقع ظهور التصنيف للعملاء. الرقم 1 يظهر في أول القائمة الرئيسية، ويليه 2 ثم 3.',
                                  child: Icon(Icons.help_outline_rounded,
                                      size: 18, color: AppColors.burgundy),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'رقم 1 يظهر في مقدمة قائمة العملاء',
                              style: GoogleFonts.cairo(
                                  fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFEFE9E0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'حالة التفعيل:',
                                style: GoogleFonts.cairo(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: isActive,
                                activeColor: AppColors.burgundy,
                                onChanged: (val) {
                                  setDialogState(() {
                                    isActive = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploadingImage ? null : () => Navigator.pop(ctx),
              child: Text('إلغاء',
                  style: GoogleFonts.cairo(color: AppColors.textSecondary)),
            ),
            CustomButton(
              text: isUploadingImage ? 'جاري رفع الصورة...' : 'إضافة التصنيف',
              isLoading: isUploadingImage,
              variant: ButtonVariant.primary,
              onPressed: isUploadingImage
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final desc = descController.text.trim();
                      final order =
                          int.tryParse(sortController.text.trim()) ?? 1;
                      if (name.isEmpty) return;

                      String finalImageUrl = imageController.text.trim();

                      // رفع الصورة من الجهاز إلى سوبابيز إن وجدت
                      if (pickedImageBytes != null) {
                        setDialogState(() => isUploadingImage = true);
                        final uploadedUrl =
                            await StorageService.uploadServiceImage(
                          bytes: pickedImageBytes!,
                          originalName: pickedImageName ?? 'category.jpg',
                          customPath:
                              'categories/${DateTime.now().millisecondsSinceEpoch}_${pickedImageName ?? "cat.jpg"}',
                        );
                        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                          finalImageUrl = uploadedUrl;
                        }
                      }

                      if (context.mounted) Navigator.pop(ctx);
                      final ok = await adminData.addCategory(
                        name,
                        order,
                        description: desc,
                        imageUrl: finalImageUrl,
                        isActive: isActive,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'تم إضافة التصنيف "$name" بنجاح'
                                : 'تعذر إضافة التصنيف'),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Map<String, dynamic> cat,
      AdminDashboardProvider adminData) {
    final catId = cat['id'].toString();
    final nameController =
        TextEditingController(text: cat['name'] as String? ?? '');
    final descController =
        TextEditingController(text: cat['description'] as String? ?? '');
    final imageController =
        TextEditingController(text: cat['image_url'] as String? ?? '');
    final sortController =
        TextEditingController(text: '${cat['sort_order'] ?? 1}');
    bool isActive = cat['is_active'] as bool? ?? true;
    Uint8List? pickedImageBytes;
    String? pickedImageName;
    bool isUploadingImage = false;
    // bool showManualUrlField = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded,
                    color: AppColors.burgundy, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'تعديل بيانات التصنيف',
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E2527),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. اسم التصنيف
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'اسم التصنيف ',
                      labelStyle: GoogleFonts.cairo(fontSize: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. الوصف
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'الوصف التعريفي ',
                      labelStyle: GoogleFonts.cairo(fontSize: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. صورة التصنيف
                  Text(
                    'صورة غلاف التصنيف:',
                    style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E2527)),
                  ),
                  const SizedBox(height: 6),
                  _buildImagePickerBox(
                    pickedBytes: pickedImageBytes,
                    imageUrl: imageController.text.trim(),
                    isUploading: isUploadingImage,
                    onPickImage: () async {
                      final file =
                          await StorageService.pickSingleImageFromDevice();
                      if (file != null) {
                        final bytes = await file.readAsBytes();
                        setDialogState(() {
                          pickedImageBytes = bytes;
                          pickedImageName = file.name;
                        });
                      }
                    },
                    onRemoveImage: () {
                      setDialogState(() {
                        pickedImageBytes = null;
                        pickedImageName = null;
                        imageController.clear();
                      });
                    },
                  ),

                  // إدخال الرابط يدوياً إن رغب
                  const SizedBox(height: 8),
                  // InkWell(
                  //   onTap: () {
                  //     setDialogState(() {
                  //       showManualUrlField = !showManualUrlField;
                  //     });
                  //   },
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(
                  //         showManualUrlField ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  //         size: 18,
                  //         color: AppColors.burgundy,
                  //       ),
                  //       const SizedBox(width: 4),
                  //       Text(
                  //         showManualUrlField ? 'إخفاء حقل الرابط' : 'أو تعديل الرابط يدوياً (URL)',
                  //         style: GoogleFonts.cairo(fontSize: 11.5, color: AppColors.burgundy, fontWeight: FontWeight.w600),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // if (showManualUrlField) ...[
                  //   const SizedBox(height: 8),
                  //   TextField(
                  //     controller: imageController,
                  //     style: GoogleFonts.cairo(fontSize: 12),
                  //     onChanged: (_) => setDialogState(() {}),
                  //     decoration: InputDecoration(
                  //       labelText: 'رابط الصورة (URL)',
                  //       labelStyle: GoogleFonts.cairo(fontSize: 11),
                  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  //     ),
                  //   ),
                  // ],

                  const SizedBox(height: 16),

                  // 4. ترتيب العرض وحالة التفعيل
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: sortController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.cairo(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'ترتيب العرض في التطبيق ',
                                labelStyle: GoogleFonts.cairo(fontSize: 12),
                                hintText: '1, 2, 3...',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                suffixIcon: const Tooltip(
                                  message:
                                      'يحدد أولوية وموقع ظهور التصنيف للعملاء. الرقم 1 يظهر في أول القائمة الرئيسية، ويليه 2 ثم 3.',
                                  child: Icon(Icons.help_outline_rounded,
                                      size: 18, color: AppColors.burgundy),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'رقم 1 يظهر في مقدمة قائمة العملاء',
                              style: GoogleFonts.cairo(
                                  fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFEFE9E0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'حالة التفعيل:',
                                style: GoogleFonts.cairo(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: isActive,
                                activeColor: AppColors.burgundy,
                                onChanged: (val) {
                                  setDialogState(() {
                                    isActive = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploadingImage ? null : () => Navigator.pop(ctx),
              child: Text('إلغاء',
                  style: GoogleFonts.cairo(color: AppColors.textSecondary)),
            ),
            CustomButton(
              text: isUploadingImage ? 'جاري رفع الصورة...' : 'حفظ التعديلات',
              isLoading: isUploadingImage,
              variant: ButtonVariant.primary,
              onPressed: isUploadingImage
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final desc = descController.text.trim();
                      final order =
                          int.tryParse(sortController.text.trim()) ?? 1;
                      if (name.isEmpty) return;

                      String finalImageUrl = imageController.text.trim();

                      // رفع الصورة من الجهاز إن قام باختيار صورة جديدة
                      if (pickedImageBytes != null) {
                        setDialogState(() => isUploadingImage = true);
                        final uploadedUrl =
                            await StorageService.uploadServiceImage(
                          bytes: pickedImageBytes!,
                          originalName: pickedImageName ?? 'category.jpg',
                          customPath:
                              'categories/${DateTime.now().millisecondsSinceEpoch}_${pickedImageName ?? "cat.jpg"}',
                        );
                        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                          finalImageUrl = uploadedUrl;
                        }
                      }

                      if (context.mounted) Navigator.pop(ctx);
                      final ok = await adminData.updateCategory(
                        id: catId,
                        name: name,
                        description: desc,
                        imageUrl: finalImageUrl,
                        sortOrder: order,
                        isActive: isActive,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'تم تحديث التصنيف "$name" بنجاح'
                                : 'تعذر تحديث التصنيف'),
                            backgroundColor:
                                ok ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerBox({
    required Uint8List? pickedBytes,
    required String imageUrl,
    required bool isUploading,
    required VoidCallback onPickImage,
    required VoidCallback onRemoveImage,
  }) {
    final hasImage = pickedBytes != null || imageUrl.isNotEmpty;

    if (hasImage) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFE9E0)),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: pickedBytes != null
                  ? Image.memory(
                      pickedBytes,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF7F3EE),
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              size: 36, color: AppColors.textMuted),
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 14),
                    label:
                        Text('تغيير', style: GoogleFonts.cairo(fontSize: 11)),
                    onPressed: isUploading ? null : onPickImage,
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.85),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    tooltip: 'إزالة الصورة',
                    onPressed: isUploading ? null : onRemoveImage,
                  ),
                ],
              ),
            ),
            if (isUploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: isUploading ? null : onPickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5DDD2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.burgundy.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.burgundy, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              'اضغط لاختيار صورة التصنيف من جهازك',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.burgundy,
              ),
            ),
            Text(
              '(PNG, JPG, WebP من الكمبيوتر أو الهاتف)',
              style:
                  GoogleFonts.cairo(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetailsDialog(
      BuildContext context, Map<String, dynamic> cat) {
    final name = cat['name'] as String? ?? 'تفاصيل التصنيف';
    final desc =
        cat['description'] as String? ?? 'لا يوجد وصف متاح لهذا التصنيف.';
    final img = cat['image_url'] as String? ?? '';
    final count = cat['services_count'] ?? 0;
    final date = cat['created_at'] ?? '15/09/2026';
    final isActive = cat['is_active'] as bool? ?? true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.burgundy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline,
                  color: AppColors.burgundy, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E2527),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (img.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    img,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: const Color(0xFFF7F3EE),
                      child: const Center(
                        child: Icon(Icons.category_rounded,
                            size: 40, color: AppColors.burgundy),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'الوصف والتعريف:',
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A7F84)),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.cairo(
                    fontSize: 13, color: const Color(0xFF4A3E42), height: 1.5),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الخدمات المرتبطة:',
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: const Color(0xFF7A6F73))),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3EE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBE3D7)),
                    ),
                    child: Text(
                      '$count خدمة',
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.burgundy),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تاريخ الإدراج:',
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: const Color(0xFF7A6F73))),
                  Text('$date',
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E2527))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الحالة التشغيلية:',
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: const Color(0xFF7A6F73))),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF5F1EB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isActive
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFE5DDD3)),
                    ),
                    child: Text(
                      isActive ? 'نشط' : 'معطل',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF7A6F73),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'إغلاق',
            variant: ButtonVariant.primary,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, Map<String, dynamic> cat,
      AdminDashboardProvider adminData) {
    final name = cat['name'] as String? ?? 'التصنيف';
    final id = cat['id'].toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text(
              'تأكيد حذف التصنيف',
              style:
                  GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف تصنيف "$name"؟\nسيتم إخفاؤه من قوائم النظام الرئيسية.',
          style: GoogleFonts.cairo(
              fontSize: 13, height: 1.6, color: const Color(0xFF5A5054)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: const Color(0xFF7A6F73))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await adminData.deleteCategory(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        ok ? 'تم حذف تصنيف "$name" بنجاح' : 'تعذر حذف التصنيف'),
                    backgroundColor: ok ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: Text('تأكيد الحذف',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminData = context.watch<AdminDashboardProvider>();
    final globalSearch = context.watch<AdminNavigationProvider>().searchQuery;

    // Filter categories based on search & status
    final filteredCategories = adminData.categories.where((cat) {
      final isActive = cat['is_active'] as bool? ?? true;

      if (_selectedStatusFilter == 'نشط فقط' && !isActive) return false;
      if (_selectedStatusFilter == 'معطل فقط' && isActive) return false;

      final query = globalSearch.trim().toLowerCase();

      if (query.isNotEmpty) {
        final name = (cat['name'] ?? '').toString().toLowerCase();
        final desc = (cat['description'] ?? '').toString().toLowerCase();
        return name.contains(query) || desc.contains(query);
      }
      return true;
    }).toList();

    final totalCount = adminData.categories.length;
    final activeCount =
        adminData.categories.where((c) => c['is_active'] != false).length;
    final inactiveCount =
        adminData.categories.where((c) => c['is_active'] == false).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Title, Subtitle & Add Category Button inside Card)
          _buildHeaderRow(context, adminData),

          const SizedBox(height: 24),

          // 2. Top 3 Stat Cards (Exactly as in screenshot: إجمالي التصنيفات 12, التصنيفات النشطة 10, المعطلة 2)
          _buildTopStatCards(totalCount, activeCount, inactiveCount),

          const SizedBox(height: 24),

          // 3. Status Filter Bar
          _buildFilterBar(context, adminData),

          const SizedBox(height: 20),

          // 4. Categories Data Table (Exact table design with all columns)
          _buildCategoriesTable(context, filteredCategories, adminData),
        ],
      ),
    );
  }

  // 1. Header Banner Card with Add Category Button
  Widget _buildHeaderRow(BuildContext context, AdminDashboardProvider adminData) {
    return AdminPageHeaderCard(
      title: 'إدارة التصنيفات',
      subtitle:
          'تنظيم، ضبط، وإسناد الخدمات والمقدمين ضمن منظومة الفعاليات الحصرية',
      icon: Icons.category_outlined,
      action: ElevatedButton.icon(
        onPressed: () => _showAddCategoryDialog(context, adminData),
        icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
        label: Text(
          'إضافة تصنيف جديد',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.primaryDark.withOpacity(0.35),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // 2. Top 3 Stat Cards
  Widget _buildTopStatCards(
      int totalCount, int activeCount, int inactiveCount) {
    return AdminStatsRow(
      cards: [
        // Card 1: إجمالي التصنيفات
        AdminStatCard(
          title: 'إجمالي التصنيفات',
          value: '$totalCount',
          icon: Icons.account_tree_outlined,
          iconColor: AppColors.burgundy,
          iconBg: const Color(0xFFF9EEF1),
          isSelected: _selectedStatusFilter == 'جميع الحالات (الكل)',
          onTap: () => setState(() => _selectedStatusFilter = 'جميع الحالات (الكل)'),
        ),
        // Card 2: التصنيفات النشطة بالمنصة
        AdminStatCard(
          title: 'التصنيفات النشطة بالمنصة',
          value: '$activeCount',
          icon: Icons.verified_outlined,
          iconColor: const Color(0xFF059669),
          iconBg: const Color(0xFFECFDF5),
          isSelected: _selectedStatusFilter == 'التصنيفات النشطة فقط',
          onTap: () => setState(() => _selectedStatusFilter = 'التصنيفات النشطة فقط'),
        ),
        // Card 3: التصنيفات المعطلة أو المؤرشفة
        AdminStatCard(
          title: 'التصنيفات المعطلة أو المؤرشفة',
          value: '$inactiveCount',
          icon: Icons.pause_circle_outline,
          iconColor: const Color(0xFF8A7F84),
          iconBg: const Color(0xFFF4EFEA),
          isSelected: _selectedStatusFilter == 'التصنيفات المعطلة فقط',
          onTap: () => setState(() => _selectedStatusFilter = 'التصنيفات المعطلة فقط'),
        ),
      ],
    );
  }

  // 3. Status Filter Bar
  Widget _buildFilterBar(
      BuildContext context, AdminDashboardProvider adminData) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFE9E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_alt_outlined,
                size: 18, color: AppColors.burgundy),
            const SizedBox(width: 8),
            Text(
              'تصفية الحالة:',
              style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B5563)),
            ),
            const SizedBox(width: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatusFilter,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: Color(0xFF8A7F84)),
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E2527),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'جميع الحالات (الكل)',
                      child: Text('جميع الحالات (الكل)')),
                  DropdownMenuItem(
                      value: 'نشط فقط', child: Text('نشط فقط (المفعلة)')),
                  DropdownMenuItem(
                      value: 'معطل فقط', child: Text('معطل فقط (المؤرشفة)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedStatusFilter = val;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Categories Data Table
  Widget _buildCategoriesTable(
    BuildContext context,
    List<Map<String, dynamic>> categories,
    AdminDashboardProvider adminData,
  ) {
    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFE9E0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.category_outlined,
                  size: 40, color: Color(0xFF8A7F84)),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد تصنيفات مطابقة لخيارات البحث',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E2527),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'جرّب تغيير كلمات البحث أو إعادة ضبط خيارات التصفية بالأعلى.',
              style: GoogleFonts.cairo(
                  fontSize: 13, color: const Color(0xFF8A7F84)),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'إعادة ضبط البحث',
              variant: ButtonVariant.outline,
              onPressed: () {
                context.read<AdminNavigationProvider>().setSearchQuery('');
                setState(() {
                  _selectedStatusFilter = 'جميع الحالات (الكل)';
                });
              },
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE9E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth =
                constraints.maxWidth > 950 ? constraints.maxWidth : 950.0;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    // Table Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAF8F5),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEBE6DF)),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 52,
                            child: Text(
                              'الصورة',
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8A7F84),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'اسم التصنيف',
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8A7F84),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'الوصف التعريفي',
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8A7F84),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'الخدمات المرتبطة',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8A7F84),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'تاريخ الإدراج',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8A7F84),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'الحالة التشغيلية',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8A7F84),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                'الإجراءات',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8A7F84),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table Body Rows
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final catId = cat['id'].toString();
                        final name = cat['name'] as String? ?? 'بدون اسم';
                        final desc = cat['description'] as String? ??
                            'تصنيف خدمات المناسبات المعتمد في المنصة';
                        final imgUrl = cat['image_url'] as String? ?? '';
                        final servicesCount = cat['services_count'] ?? 0;
                        final dateAdded = cat['created_at'] ?? '15/09/2026';
                        final isActive = cat['is_active'] as bool? ?? true;
                        final isEven = index % 2 == 0;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          color:
                              isEven ? Colors.white : const Color(0xFFFDFBF9),
                          child: Row(
                            children: [
                              // 1. الصورة
                              SizedBox(
                                width: 52,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imgUrl.isNotEmpty
                                      ? Image.network(
                                          imgUrl,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _buildFallbackImage(),
                                        )
                                      : _buildFallbackImage(),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // 2. اسم التصنيف
                              Expanded(
                                flex: 3,
                                child: Text(
                                  name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2E2527),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // 3. الوصف التعريفي
                              Expanded(
                                flex: 4,
                                child: Text(
                                  desc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6F6265),
                                  ),
                                ),
                              ),

                              // 4. الخدمات المرتبطة
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F3EE),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFEBE3D7)),
                                    ),
                                    child: Text(
                                      '$servicesCount خدمة',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.burgundy,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 5. تاريخ الإدراج
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    '$dateAdded',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7A6F73),
                                    ),
                                  ),
                                ),
                              ),

                              // 6. الحالة التشغيلية
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFECFDF5)
                                          : const Color(0xFFF5F1EB),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isActive
                                            ? const Color(0xFFA7F3D0)
                                            : const Color(0xFFE5DDD3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF7A6F73),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isActive ? 'نشط' : 'معطل',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: isActive
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF7A6F73),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // 7. الإجراءات (4 Controls: Switch Toggle, Edit, Details, Delete)
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 1. Switch Toggle (تفعيل/تعطيل)
                                    Tooltip(
                                      message: isActive
                                          ? 'تعطيل التصنيف'
                                          : 'تفعيل التصنيف',
                                      child: SizedBox(
                                        width: 38,
                                        height: 24,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Switch(
                                            value: isActive,
                                            activeColor: AppColors.burgundy,
                                            onChanged: (val) async {
                                              await adminData
                                                  .toggleCategoryStatus(
                                                      catId, isActive);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // 2. Edit Category (تعديل)
                                    Tooltip(
                                      message: 'تعديل التصنيف',
                                      child: InkWell(
                                        onTap: () =>
                                            _showEditCategoryDialog(
                                                context, cat, adminData),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        hoverColor: const Color(0xFFF3EBE6),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7F3EE),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFEBE3D7)),
                                          ),
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: Color(0xFF6F6265),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // 3. Category Details (تفاصيل)
                                    Tooltip(
                                      message: 'تفاصيل التصنيف',
                                      child: InkWell(
                                        onTap: () =>
                                            _showCategoryDetailsDialog(
                                                context, cat),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        hoverColor: const Color(0xFFF3EBE6),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF7F3EE),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFEBE3D7)),
                                          ),
                                          child: const Icon(
                                            Icons.link_rounded,
                                            size: 16,
                                            color: Color(0xFF6F6265),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // 4. Delete Category (حذف)
                                    Tooltip(
                                      message: 'حذف التصنيف',
                                      child: InkWell(
                                        onTap: () =>
                                            _confirmDeleteCategory(
                                                context, cat, adminData),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        hoverColor: const Color(0xFFFEE2E2),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFFECACA)),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 16,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEFE9E0)),
      ),
      child: const Center(
        child:
            Icon(Icons.category_rounded, size: 22, color: AppColors.burgundy),
      ),
    );
  }
}
