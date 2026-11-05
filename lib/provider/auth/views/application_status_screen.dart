import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  bool _isRefreshing = false;

  void _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await context.read<AuthProvider>().restoreSession();
    if (!mounted) return;
    setState(() => _isRefreshing = false);

    final status = context.read<AuthProvider>().status;
    if (status == AuthStatus.providerApproved) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isRejected = authProvider.isRejected;
    final app = authProvider.currentApplication;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 42),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isRejected
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.gold.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Icon Badge
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRejected
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.gold.withOpacity(0.12),
                    ),
                    child: Center(
                      child: Icon(
                        isRejected
                            ? Icons.cancel_outlined
                            : Icons.hourglass_top_rounded,
                        size: 46,
                        color: isRejected ? AppColors.error : AppColors.goldDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header Title
                  Text(
                    isRejected
                        ? 'نعتذر، لم تتم الموافقة على الطلب'
                        : 'طلب انضمامك قيد المراجعة والتدقيق',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isRejected ? AppColors.error : AppColors.burgundy,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    isRejected
                        ? 'قام فريق إدارة خِدمتي بمراجعة بيانات طلبك، وللأسف لم يتم اعتماد الحساب في الوقت الحالي.'
                        : 'شكراً لانضمامك إلى شبكة مزودي خدمات خِدمتي! طلبك الآن لدى فريق الإدارة للتحقق من البيانات ومعايير الجودة المعتمدة.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      height: 1.7,
                      color: const Color(0xFF6E6367),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Application Details Card
                  if (app != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF9F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEBE3D7)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('النشاط التجاري:', app.businessName),
                          const Divider(height: 20, color: Color(0xFFECE4D9)),
                          if (app.phone != null && app.phone!.isNotEmpty) ...[
                            _buildDetailRow('رقم التواصل:', app.phone!),
                            const Divider(height: 20, color: Color(0xFFECE4D9)),
                          ],
                          if (app.address != null && app.address!.isNotEmpty) ...[
                            _buildDetailRow('المدينة / المنطقة:', app.address!),
                            const Divider(height: 20, color: Color(0xFFECE4D9)),
                          ],
                          _buildDetailRow(
                            'حالة الطلب الحالية:',
                            isRejected ? 'مرفوض' : 'قيد المراجعة والتدقيق',
                            valueColor: isRejected
                                ? AppColors.error
                                : const Color(0xFFB8860B),
                            isBold: true,
                          ),
                          if (isRejected &&
                              app.rejectionReason != null &&
                              app.rejectionReason!.isNotEmpty) ...[
                            const Divider(height: 20, color: Color(0xFFECE4D9)),
                            _buildDetailRow(
                              'سبب الرفض:',
                              app.rejectionReason!,
                              valueColor: AppColors.error,
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Refresh / Check Status Button
                      ElevatedButton.icon(
                        onPressed: _isRefreshing ? null : _handleRefresh,
                        icon: _isRefreshing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 20),
                        label: Text(
                          _isRefreshing ? 'جاري الفحص...' : 'تحديث حالة الطلب',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.burgundy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Sign Out Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          await context.read<AuthProvider>().signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: Text(
                          'تسجيل الخروج',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6E6367),
                          side: const BorderSide(color: Color(0xFFD6CBC3)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF7A6F73),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? const Color(0xFF2E2527),
          ),
        ),
      ],
    );
  }
}