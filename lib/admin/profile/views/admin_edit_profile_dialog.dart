import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/services/storage_service.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';

class AdminEditProfileDialog extends StatefulWidget {
  final String currentFullName;
  final String currentPhone;
  final String currentEmail;
  final String currentAvatarUrl;

  const AdminEditProfileDialog({
    super.key,
    required this.currentFullName,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentAvatarUrl,
  });

  @override
  State<AdminEditProfileDialog> createState() => _AdminEditProfileDialogState();
}

class _AdminEditProfileDialogState extends State<AdminEditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _avatarUrlController;

  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentFullName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _avatarUrlController = TextEditingController(text: widget.currentAvatarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final image = await StorageService.pickSingleImageFromDevice();
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await image.readAsBytes();
      final url = await StorageService.uploadServiceImage(
        bytes: bytes,
        originalName: image.name,
        customPath: 'admin_avatars/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
      );

      if (url != null && url.isNotEmpty) {
        setState(() {
          _avatarUrlController.text = url;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع الصورة الرمزية بنجاح'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصورة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();

    final success = await auth.updateUserProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث بيانات الملف الشخصي للمشرف بنجاح في Supabase'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'تعذر تحديث البيانات، يرجى المحاولة لاحقاً'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            child: const Icon(Icons.edit_note_rounded,
                color: AppColors.burgundy, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'تعديل بيانات الملف الشخصي',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E2527),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar preview and picker
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.burgundy.withOpacity(0.2), width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _avatarUrlController.text.isNotEmpty
                            ? Image.network(
                                _avatarUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.admin_panel_settings,
                                      size: 40, color: AppColors.burgundy),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.admin_panel_settings,
                                    size: 40, color: AppColors.burgundy),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: InkWell(
                          onTap: _isUploadingImage ? null : _pickAndUploadAvatar,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.burgundy,
                              shape: BoxShape.circle,
                            ),
                            child: _isUploadingImage
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: _isUploadingImage ? null : _pickAndUploadAvatar,
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: Text(
                      _isUploadingImage ? 'جاري رفع الصورة...' : 'رفع صورة من الجهاز',
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(foregroundColor: AppColors.burgundy),
                  ),
                ),
                const SizedBox(height: 16),

                // Full Name field
                Text(
                  'الاسم الكامل *',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2527),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.cairo(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'أدخل الاسم الكامل للمشرف...',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone field
                Text(
                  'رقم الجوال / الهاتف',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E2527),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '+967 770 000 000',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Email field (Readonly note)
                Text(
                  'البريد الإلكتروني (مرتبط بالحساب ولا يمكن تعديله هنا)',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A7F84),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: widget.currentEmail,
                  readOnly: true,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF6B7280)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFAF8F5),
                    prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Avatar URL field (Optional direct URL)
                Text(
                  'أو أدخل رابط مباشر للصورة الرمزية (اختياري)',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A7F84),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _avatarUrlController,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(fontSize: 12),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'https://example.com/avatar.jpg',
                    prefixIcon: const Icon(Icons.link_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'إلغاء',
            style: GoogleFonts.cairo(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.burgundy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'حفظ التعديلات',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}

