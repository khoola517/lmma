import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'provider/auth/providers/auth_provider.dart';
import 'provider/shell/providers/navigation_provider.dart';
import 'provider/services/providers/services_provider.dart';
import 'provider/bookings/providers/bookings_provider.dart';
import 'provider/profile/providers/profile_provider.dart';
import 'provider/reviews/providers/reviews_provider.dart';
import 'admin/shell/providers/admin_navigation_provider.dart';
import 'admin/dashboard/providers/admin_dashboard_provider.dart';
import 'provider/auth/views/auth_gate.dart';
import 'provider/auth/views/login_screen.dart';
import 'provider/auth/views/register_screen.dart';
import 'provider/auth/views/application_status_screen.dart';
import 'provider/shell/views/provider_shell_screen.dart';
import 'admin/shell/views/admin_shell_screen.dart';

/// http://localhost:8080
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase Initialization Note: $e');
  }

  runApp(const KhadematyProviderApp());
}

class KhadematyProviderApp extends StatelessWidget {
  const KhadematyProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
        ChangeNotifierProvider(create: (_) => AdminNavigationProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
      ],
      child: MaterialApp(
        title: 'خِدمتي - بوابة مقدمي الخدمة والإدارة',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGate(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const _ProtectedProviderRoute(),
          '/admin': (context) => const _ProtectedAdminRoute(),
          '/application-status': (context) => const ApplicationStatusScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const AuthGate(),
          );
        },
      ),
    );
  }
}

class _ProtectedProviderRoute extends StatelessWidget {
  const _ProtectedProviderRoute();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAdmin) {
      return const AdminShellScreen();
    }
    if (auth.isProviderApproved) {
      return const ProviderShellScreen();
    }
    if (auth.isPending || auth.isRejected) {
      return const ApplicationStatusScreen();
    }
    return const LoginScreen();
  }
}

class _ProtectedAdminRoute extends StatelessWidget {
  const _ProtectedAdminRoute();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAdmin) {
      return const AdminShellScreen();
    }
    return const LoginScreen();
  }
}
