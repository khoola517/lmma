import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: 'contact@alandalus.com');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate pleasant network transition
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    context.read<AuthProvider>().login(
      email: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 860;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Stack(
        children: [
          // Background ambient soft radial glows
          Positioned(
            top: -100,
            right: size.width * 0.2,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.burgundy.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: size.width * 0.15,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withOpacity(0.07),
              ),
            ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.burgundy.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.burgundy.withOpacity(0.08),
                        blurRadius: 36,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Right Side (RTL): Platform Info & Branding
                              Expanded(
                                flex: 5,
                                child: _buildBrandingSide(),
                              ),
                              // Vertical divider
                              Container(
                                width: 1,
                                height: 420,
                                color: AppColors.burgundy.withOpacity(0.08),
                              ),
                              // Left Side (RTL): Login Form
                              Expanded(
                                flex: 6,
                                child: _buildFormSide(),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBrandingSide(isCompact: true),
                              Divider(
                                color: AppColors.burgundy.withOpacity(0.08),
                                height: 1,
                              ),
                              _buildFormSide(),
                            ],
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

  Widget _buildBrandingSide({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 24 : 36),
      color: const Color(0xFFFCFAF7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Icon Container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.burgundy.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.burgundy.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 30,
              color: AppColors.burgundy,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'خِدمتي',
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.burgundy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            'بوابة شركاء النجاح',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2327),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'أهلاً بك مجدداً. سجّل الدخول لإدارة حجوزاتك، وتخصيص باقاتك، والتواصل المباشر مع العملاء بكل سلاسة ورقي.',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6E6367),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Security Trust Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.burgundy.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 18,
                  color: AppColors.burgundy,
                ),
                const SizedBox(width: 8),
                Text(
                  'منصة آمنة وموثوقة',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8C7B83),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSide() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تسجيل الدخول',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2327),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أدخل بيانات حسابك للمتابعة للوحة التحكم',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF8C7B83),
              ),
            ),
            const SizedBox(height: 24),

            // Identifier
            Text(
              'اسم المستخدم أو البريد الإلكتروني',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A3E44),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _identifierController,
              decoration: InputDecoration(
                hintText: 'اسم المستخدم أو البريد الإلكتروني',
                hintStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF8C7B83),
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF8C7B83),
                  size: 20,
                ),
                fillColor: const Color(0xFFFAF7F2),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.burgundy.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.burgundy.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال اسم المستخدم أو البريد';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'كلمة المرور',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A3E44),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: AppColors.burgundy,
                      ),
                    );
                  },
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.burgundy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF8C7B83),
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF8C7B83),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF8C7B83),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  tooltip: _obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
                ),
                fillColor: const Color(0xFFFAF7F2),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.burgundy.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.burgundy.withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'يرجى إدخال كلمة المرور';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_back, size: 18), // Arrow pointing in reading flow
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Registration Footer Link
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.burgundy.withOpacity(0.08)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب بعد؟ ',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF6E6367),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text(
                      'إنشاء حساب جديد',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.burgundy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
