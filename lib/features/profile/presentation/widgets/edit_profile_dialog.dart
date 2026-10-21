import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../models/provider_profile_model.dart';

class EditProfileDialog extends StatefulWidget {
  final ProviderProfileModel profile;
  final ValueChanged<ProviderProfileModel> onSave;

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.profile.copyWith(
        businessName: _businessNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        location: _locationController.text.trim(),
        category: _categoryController.text.trim(),
        bio: _bioController.text.trim(),
      );
      widget.onSave(updated);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBg,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.burgundyLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit, color: AppColors.burgundy, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'تعديل الملف الشخصي لمقدم الخدمة',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

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
                        validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال اسم المنشأة' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'رقم الهاتف للتواصل',
                              hint: '+967 770 123 456',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'البريد الإلكتروني الرسمي',
                              hint: 'lamasat.events@khidmati.ye',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'المدينة والمنطقة',
                              hint: 'حضرموت - المكلا (حي الديس)',
                              controller: _locationController,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'نوع الخدمة والتخصص الرئيسي',
                              hint: 'تنظيم وتنسيق كوشات وأفراح',
                              controller: _categoryController,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'نبذة تعريفية عن المنشأة وخبراتها',
                        hint: 'اكتب نبذة تعريفية مميزة عن تاريخ المنشأة وخبرات فريق العمل...',
                        controller: _bioController,
                        maxLines: 4,
                        isRequired: true,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'إلغاء',
                      variant: ButtonVariant.ghost,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    CustomButton(
                      text: 'حفظ التعديلات',
                      icon: Icons.check,
                      variant: ButtonVariant.primary,
                      onPressed: _submit,
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
