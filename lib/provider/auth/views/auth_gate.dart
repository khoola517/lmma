import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/provider/auth/providers/auth_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_shell_screen.dart';
import 'package:khadematy_web/provider/shell/views/provider_shell_screen.dart';
import 'application_status_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.status == AuthStatus.initial) {
        auth.restoreSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          backgroundColor: Color(0xFFFAF7F2),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.burgundy,
                  strokeWidth: 3,
                ),
                SizedBox(height: 18),
                Text(
                  'جاري التحقق من صلاحيات الدخول...',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Color(0xFF6E6367),
                  ),
                ),
              ],
            ),
          ),
        );

      case AuthStatus.admin:
        return const AdminShellScreen();

      case AuthStatus.providerApproved:
        return const ProviderShellScreen();

      case AuthStatus.providerPending:
      case AuthStatus.providerRejected:
        return const ApplicationStatusScreen();

      case AuthStatus.unauthorizedCustomer:
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}