import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/services_provider.dart';
import 'providers/bookings_provider.dart';
import 'providers/profile_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/shell/presentation/provider_shell_screen.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('1: بدء تشغيل التطبيق');

  try {
    await SupabaseConfig.initialize();
    debugPrint('2: تمت تهيئة Supabase بنجاح');

    final data =
        await SupabaseConfig.client.from('categories').select().limit(1);

    debugPrint('3: نجح اختبار قراءة التصنيفات: $data');
  } catch (e, stackTrace) {
    debugPrint('حدث خطأ أثناء تهيئة Supabase أو قراءة البيانات: $e');
    debugPrint('$stackTrace');
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
      ],
      child: MaterialApp(
        title: 'خِدمتي - بوابة مقدمي الخدمة',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: '/dashboard',
        routes: {
          '/': (context) => const ProviderShellScreen(),
          '/dashboard': (context) => const ProviderShellScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const ProviderShellScreen(),
          );
        },
      ),
    );
  }
}
