import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/core/widgets/provider_sidebar.dart';
import 'package:khadematy_web/core/widgets/provider_header.dart';
import 'package:khadematy_web/provider/shell/providers/navigation_provider.dart';
import 'package:khadematy_web/provider/services/providers/services_provider.dart';
import 'package:khadematy_web/provider/bookings/providers/bookings_provider.dart';
import 'package:khadematy_web/provider/profile/providers/profile_provider.dart';
import 'package:khadematy_web/provider/reviews/providers/reviews_provider.dart';
import 'package:khadematy_web/provider/dashboard/views/dashboard_screen.dart';
import 'package:khadematy_web/provider/services/views/services_screen.dart';
import 'package:khadematy_web/provider/bookings/views/booking_requests_screen.dart';
import 'package:khadematy_web/provider/bookings/views/confirmed_bookings_screen.dart';
import 'package:khadematy_web/provider/reviews/views/reviews_screen.dart';
import 'package:khadematy_web/provider/profile/views/profile_screen.dart';
import 'package:khadematy_web/provider/settings/views/settings_screen.dart';

class ProviderShellScreen extends StatefulWidget {
  const ProviderShellScreen({super.key});

  @override
  State<ProviderShellScreen> createState() => _ProviderShellScreenState();
}

class _ProviderShellScreenState extends State<ProviderShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadProfile();
      context.read<BookingsProvider>().loadBookings();
      context.read<ReviewsProvider>().loadReviews();
    });
  }

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
                    context.read<ReviewsProvider>().setSearchQuery(query);
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