import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCity;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'قاعات وصالات أفراح',
    'تصوير وتوثيق مرئي واحترافي',
    'تنسيق ديكور، كوش وزهور',
    'بوفيه وضيافة فاخرة',
    'صوتيات وإضاءة وهندسة مسرح',
    'خدمات مناسبات أخرى',
  ];

  final List<String> _cities = [
    'صنعاء',
    'عدن',
    'المكلا وحضرموت',
    'تعز',
    'إب',
    'مدن ومناطق أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى الموافقة على الشروط والأحكام ومعايير الجودة للاستمرار',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    context.read<AuthProvider>().register(
      businessName: _businessNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      serviceType: _selectedCategory ?? 'خدمات مناسبات',
      city: _selectedCity ?? 'صنعاء',
      bio: _bioController.text.trim(),
    );

    setState(() => _isLoading = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Text(
              'تم استلام طلبك بنجاح!',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF2D2327),
              ),
            ),
          ],
        ),
        content: Text(
          'شكراً لانضمامك إلى شبكة مزودي خدمات خِدمتي. تم إنشاء حسابك واعتماد بياناتك الأولية للانتقال للوحة التحكم.',
          style: GoogleFonts.cairo(
            fontSize: 14,
            height: 1.6,
            color: const Color(0xFF6E6367),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
            child: Text(
              'الدخول إلى لوحة التحكم',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ambient soft light background glows
          Positioned(
            top: -80,
            right: size.width * 0.25,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withOpacity(0.09),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            left: 20,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.burgundy.withOpacity(0.04),
              ),
            ),
          ),

          // Main Form Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5DED4)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E2527).withOpacity(0.07),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Decorative Identity Strip
                          Container(
                            height: 6,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.burgundy,
                                  AppColors.gold,
                                  AppColors.burgundy,
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(isDesktop ? 36 : 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Form Header Section
                                  _buildHeader(),
                                  const SizedBox(height: 32),

                                  // Step 1: معلومات الحساب الأساسية
                                  _buildStep1Section(isDesktop),
                                  const SizedBox(height: 28),

                                  // Step 2: معلومات النشاط والخدمة
                                  _buildStep2Section(isDesktop),
                                  const SizedBox(height: 24),

                                  // Terms & Conditions Checkbox
                                  _buildTermsCheckbox(),
                                  const SizedBox(height: 28),

                                  // Submit CTA Button
                                  _buildSubmitButton(),
                                  const SizedBox(height: 24),

                                  // Footer Link: Login
                                  _buildLoginFooter(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Storefront Icon with star
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5DED4)),
              ),
              child: const Icon(
                Icons.storefront,
                color: AppColors.burgundy,
                size: 34,
              ),
            ),
            Positioned(
              bottom: -4,
              left: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Verified Partner Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE5DED4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 16, color: AppColors.burgundy),
              const SizedBox(width: 6),
              Text(
                'بوابة الشركاء ومزودي الخدمات الفاخرة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.burgundy,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Main Title
        Text(
          'إنشاء حساب مقدم خدمة',
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.burgundy,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'أنشئ حسابك وأرسل طلب الانضمام إلى شبكة مزودي خدمات المناسبات المعتمدة في منصة خِدمتي.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF6F6265),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Section(bool isDesktop) {
    final passwordMatch = _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;

    final passwordMismatch = _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DED4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.burgundy,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '١',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات الحساب الأساسية',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E2527),
                    ),
                  ),
                  Text(
                    'بيانات الاتصال ومسؤول إدارة الحساب والنشاط',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF6F6265),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Business Name (Full width)
          _buildFieldLabel('اسم مقدم الخدمة / اسم النشاط التجاري'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _businessNameController,
            decoration: _inputDecoration(
              hint: 'مثال: مؤسسة الأندلس لتنسيق المناسبات والأفراح',
              icon: Icons.badge_outlined,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال اسم النشاط' : null,
          ),
          const SizedBox(height: 16),

          // Email & Phone in 2 columns
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('البريد الإلكتروني للعمل'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        textDirection: TextDirection.ltr,
                        decoration: _inputDecoration(
                          hint: 'contact@alandalus.com',
                          icon: Icons.alternate_email,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'يرجى إدخال البريد';
                          if (!v.contains('@')) return 'صيغة البريد غير صحيحة';
                          return null;
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
                      _buildFieldLabel('رقم الهاتف / الواتساب'),
                      const SizedBox(height: 6),
                      _buildPhoneField(),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildFieldLabel('البريد الإلكتروني للعمل'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              textDirection: TextDirection.ltr,
              decoration: _inputDecoration(
                hint: 'contact@alandalus.com',
                icon: Icons.alternate_email,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'يرجى إدخال البريد';
                if (!v.contains('@')) return 'صيغة البريد غير صحيحة';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('رقم الهاتف / الواتساب'),
            const SizedBox(height: 6),
            _buildPhoneField(),
          ],

          const SizedBox(height: 16),

          // Passwords in 2 columns
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('كلمة المرور'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: const Color(0xFF6F6265),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور 6 أحرف على الأقل' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFieldLabel('تأكيد كلمة المرور'),
                          if (passwordMatch)
                            Text(
                              'متطابقة ✓',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            )
                          else if (passwordMismatch)
                            Text(
                              'غير متطابقة ✕',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: const Color(0xFF6F6265),
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'يرجى تأكيد كلمة المرور';
                          if (v != _passwordController.text) return 'كلمات المرور غير متطابقة';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildFieldLabel('كلمة المرور'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _inputDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: const Color(0xFF6F6265),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور 6 أحرف على الأقل' : null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFieldLabel('تأكيد كلمة المرور'),
                if (passwordMatch)
                  Text(
                    'متطابقة ✓',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  )
                else if (passwordMismatch)
                  Text(
                    'غير متطابقة ✕',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: _inputDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: const Color(0xFF6F6265),
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'يرجى تأكيد كلمة المرور';
                if (v != _passwordController.text) return 'كلمات المرور غير متطابقة';
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2Section(bool isDesktop) {
    final bioLength = _bioController.text.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DED4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.burgundy,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '٢',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات النشاط والخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E2527),
                    ),
                  ),
                  Text(
                    'تحديد التخصص الجغرافي ونوع الفعاليات التي تقدمها',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF6F6265),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dropdowns in 2 columns
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('نوع النشاط / الخدمة الرئيسية'),
                      const SizedBox(height: 6),
                      _buildCategoryDropdown(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('المدينة / منطقة التغطية'),
                      const SizedBox(height: 6),
                      _buildCityDropdown(),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildFieldLabel('نوع النشاط / الخدمة الرئيسية'),
            const SizedBox(height: 6),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildFieldLabel('المدينة / منطقة التغطية'),
            const SizedBox(height: 6),
            _buildCityDropdown(),
          ],

          const SizedBox(height: 16),

          // Bio Textarea with Live Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('وصف مختصر للنشاط وتاريخ التميز'),
              Text(
                '$bioLength / 300',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFF867275),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _bioController,
            maxLines: 3,
            maxLength: 300,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
            decoration: InputDecoration(
              hintText: 'نبذة موجزة عن خبراتكم في تنظيم الحفلات، سعة القاعة التقريبية أو التجهيزات الفنية المميزة التي تقدمونها لضيوفكم...',
              hintStyle: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF867275),
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5DED4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5DED4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2E2527),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: '770 000 000',
        hintStyle: GoogleFonts.cairo(
          fontSize: 13,
          color: const Color(0xFF867275),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5DED4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇾🇪', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '+967',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.burgundy,
                ),
              ),
            ],
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5DED4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5DED4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال رقم الهاتف' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(
            cat,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF2E2527)),
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
      decoration: _inputDecoration(
        hint: 'اختر مجال الخدمة الأساسي...',
        icon: Icons.category_outlined,
      ),
      validator: (val) => val == null ? 'يرجى اختيار نوع الخدمة' : null,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      items: _cities.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(
            city,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF2E2527)),
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCity = val),
      decoration: _inputDecoration(
        hint: 'حدد المدينة الرئيسية...',
        icon: Icons.location_on_outlined,
      ),
      validator: (val) => val == null ? 'يرجى تحديد المدينة' : null,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(
        fontSize: 13,
        color: const Color(0xFF867275),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6F6265), size: 20),
      suffixIcon: suffixIcon,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5DED4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5DED4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          activeColor: AppColors.burgundy,
          onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text.rich(
              TextSpan(
                text: 'أوافق على ',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF6F6265),
                ),
                children: [
                  TextSpan(
                    text: 'الشروط والأحكام',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E2527),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' و '),
                  TextSpan(
                    text: 'معايير جودة الخدمات والضيافة',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E2527),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(
                    text: ' المعتمدة في منصة خِدمتي لضمان تجربة استثنائية لجميع العملاء.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.burgundy.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جاري إرسال الطلب واعتماد البيانات...',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'إرسال طلب التسجيل والانضمام',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_back, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5DED4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'لديك حساب مسجل بالفعل كمزود خدمة؟ ',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF6F6265),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text(
              'تسجيل الدخول إلى حسابك',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.burgundy,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
