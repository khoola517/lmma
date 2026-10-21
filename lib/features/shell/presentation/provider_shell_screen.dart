import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/provider_sidebar.dart';
import '../../../core/widgets/provider_header.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/services_provider.dart';
import '../../../providers/bookings_provider.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../services/presentation/services_screen.dart';
import '../../bookings/presentation/booking_requests_screen.dart';
import '../../bookings/presentation/confirmed_bookings_screen.dart';
import '../../reviews/presentation/reviews_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class ProviderShellScreen extends StatelessWidget {
  const ProviderShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    String pageTitle = 'لوحة التحكم';
    Widget currentScreen;

    switch (navProvider.selectedItem) {
      case ProviderNavItem.dashboard:
        pageTitle = 'لوحة التحكم';
        currentScreen = const DashboardScreen();
        break;
      case ProviderNavItem.bookingRequests:
        pageTitle = 'طلبات الحجز الجديدة';
        currentScreen = const BookingRequestsScreen();
        break;
      case ProviderNavItem.confirmedBookings:
        pageTitle = 'الحجوزات المؤكدة';
        currentScreen = const ConfirmedBookingsScreen();
        break;
      case ProviderNavItem.myServices:
        pageTitle = 'خدماتي';
        currentScreen = const ServicesScreen();
        break;
      case ProviderNavItem.reviews:
        pageTitle = 'التقييمات والمراجعات';
        currentScreen = const ReviewsScreen();
        break;
      case ProviderNavItem.profile:
        pageTitle = 'الملف الشخصي لمقدم الخدمة';
        currentScreen = const ProfileScreen();
        break;
      case ProviderNavItem.settings:
        pageTitle = 'الإعدادات';
        currentScreen = const SettingsScreen();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      drawer: !isDesktop ? const Drawer(child: ProviderSidebar()) : null,
      body: Row(
        children: [
          // Sidebar on Desktop
          if (isDesktop && !navProvider.isSidebarCollapsed)
            const ProviderSidebar(),

          // Main Screen Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                ProviderHeader(
                  title: pageTitle,
                  onSearch: (query) {
                    // Update search query across active modules
                    context.read<ServicesProvider>().setSearchQuery(query);
                    context.read<BookingsProvider>().setConfirmedSearchQuery(query);
                  },
                ),

                // Active Page View
                Expanded(
                  child: currentScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
