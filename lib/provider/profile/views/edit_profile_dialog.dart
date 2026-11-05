import 'package:flutter/material.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/widgets/custom_button.dart';
import 'package:khadematy_web/core/widgets/custom_text_field.dart';
import 'package:khadematy_web/provider/profile/models/provider_profile_model.dart';

class EditProfileDialog extends StatefulWidget {
  final ProviderProfileModel profile;
  final Future<bool> Function(ProviderProfileModel) onSave;

  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _businessNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _categoryController;
  late TextEditingController _bioController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _businessNameController = TextEditingController(text: p.businessName);
    _phoneController = TextEditingController(text: p.phone);
    _emailController = TextEditingController(text: p.email);
    _locationController = TextEditingController(text: p.location);
    _categoryController = TextEditingController(text: p.category);
    _bioController = TextEditingController(text: p.bio);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final updated = widget.profile.copyWith(
      businessName: _businessNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      location: _locationController.text.trim(),
      category: _categoryController.text.trim(),
      bio: _bioController.text.trim(),
    );

    try {
      final success = await widget.onSave(updated);
      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isSaving = false;
            _errorMessage =
                'فشل حفظ التعديلات في السيرفر، يرجى المحاولة لاحقاً';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'حدث خطأ غير متوقع أثناء الحفظ: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 780),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              // Row(
              //   children: [
              //     Container(
              //       width: 36,
              //       height: 36,
              //       decoration: BoxDecoration(
              //         color: AppColors.burgundyLight,
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       child: const Icon(Icons.edit, color: AppColors.burgundy, size: 20),
              //     ),
              //     const SizedBox(width: 12),
              //     Text(
              //       'تعديل الملف الشخصي لمقدم الخدمة',
              //       style: AppTextStyles.headlineSmall.copyWith(
              //         fontWeight: FontWeight.w800,
              //         color: AppColors.textPrimary,
              //       ),
              //     ),
              //   ],
              // ),
              //       IconButton(
              //         icon: const Icon(Icons.close, color: AppColors.textSecondary),
              //         onPressed: _isSaving ? null : () => Navigator.pop(context),
              //       ),
              //     ],
              //   ),
              // ),

              // const Divider(height: 1),

              // Error banner if any
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'اسم المنشأة أو مقدم الخدمة',
                        hint: 'مؤسسة لمسات لتنظيم وتنسيق الحفلات',
                        controller: _businessNameController,
                        isRequired: true,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'يرجى إدخال اسم المنشأة'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'رقم الهاتف',
                              hint: '+967 770 123 456',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'يرجى إدخال رقم الهاتف'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'البريد الألكتروني',
                              hint: 'lamasat.events@khidmati.ye',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'يرجى إدخال البريد الإلكتروني'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'المدينة',
                              hint: 'حضرموت - المكلا (حي الديس)',
                              controller: _locationController,
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'يرجى إدخال المدينة'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'نوع الخدمة',
                              hint: 'تنظيم وتنسيق كوشات وأفراح',
                              controller: _categoryController,
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'يرجى إدخال التخصص'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'نبذة تعريفية عن المنشأة وخبراتها',
                        hint:
                            'اكتب نبذة تعريفية مميزة عن تاريخ المنشأة وخبرات فريق العمل...',
                        controller: _bioController,
                        maxLines: 4,
                        isRequired: true,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'يرجى إدخال النبذة التعريفية'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              //const Divider(height: 1),

              // Footer
              const SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'إلغاء',
                      variant: ButtonVariant.ghost,
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    CustomButton(
                      text: _isSaving
                          ? 'جاري الحفظ في Supabase...'
                          : 'حفظ التعديلات',
                      //icon: _isSaving ? null : Icons.check,
                      variant: ButtonVariant.primary,
                      onPressed: _isSaving ? null : _submit,
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
}
