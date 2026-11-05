import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';
import 'package:khadematy_web/admin/shell/providers/admin_navigation_provider.dart';
import 'package:khadematy_web/admin/dashboard/providers/admin_dashboard_provider.dart';
import 'package:khadematy_web/admin/shell/views/admin_sidebar.dart';
import 'package:khadematy_web/admin/shell/views/admin_header.dart';
import 'package:khadematy_web/admin/dashboard/views/admin_home_dashboard_screen.dart';
import 'package:khadematy_web/admin/users/views/admin_users_screen.dart';
import 'package:khadematy_web/admin/applications/views/admin_applications_screen.dart';
import 'package:khadematy_web/admin/categories/views/admin_categories_screen.dart';
import 'package:khadematy_web/admin/services/views/admin_services_screen.dart';
import 'package:khadematy_web/admin/bookings/views/admin_bookings_screen.dart';
import 'package:khadematy_web/admin/reviews/views/admin_reviews_screen.dart';
import 'package:khadematy_web/admin/complaints/views/admin_complaints_screen.dart';
import 'package:khadematy_web/admin/notifications/views/admin_notifications_screen.dart';
import 'package:khadematy_web/admin/settings/views/admin_settings_screen.dart';
import 'package:khadematy_web/admin/profile/views/admin_profile_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminDashboardProvider>().loadAllAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AdminNavigationProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    String pageTitle;
    Widget currentScreen;

    switch (nav.selectedItem) {
      case AdminNavItem.dashboard:
        pageTitle = 'لوحة التحكم الرئيسية للمشرف';
        currentScreen = const AdminHomeDashboardScreen();
        break;
      case AdminNavItem.users:
        pageTitle = 'إدارة المستخدمين';
        currentScreen = const AdminUsersScreen();
        break;
      case AdminNavItem.applications:
        pageTitle = 'إدارة طلبات الانضمام';
        currentScreen = const AdminApplicationsScreen();
        break;
      case AdminNavItem.categories:
        pageTitle = 'إدارة التصنيفات';
        currentScreen = const AdminCategoriesScreen();
        break;
      case AdminNavItem.services:
        pageTitle = 'إدارة الخدمات';
        currentScreen = const AdminServicesScreen();
        break;
      case AdminNavItem.bookings:
        pageTitle = 'إدارة الحجوزات';
        currentScreen = const AdminBookingsScreen();
        break;
      case AdminNavItem.reviews:
        pageTitle = 'إدارة التقييمات';
        currentScreen = const AdminReviewsScreen();
        break;
      case AdminNavItem.complaints:
        pageTitle = 'إدارة الشكاوى والنزاعات';
        currentScreen = const AdminComplaintsScreen();
        break;
      case AdminNavItem.notifications:
        pageTitle = 'إدارة الإشعارات والتعميمات';
        currentScreen = const AdminNotificationsScreen();
        break;
      case AdminNavItem.settings:
        pageTitle = 'إعدادات المنصة';
        currentScreen = const AdminSettingsScreen();
        break;
      case AdminNavItem.profile:
        pageTitle = 'الملف الشخصي للمشرف';
        currentScreen = const AdminProfileScreen();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      drawer: !isDesktop ? const Drawer(child: AdminSidebar()) : null,
      body: Row(
        children: [
          // Sidebar on Desktop
          if (isDesktop && !nav.isSidebarCollapsed)
            const AdminSidebar(),

          // Main Screen Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                AdminHeader(title: pageTitle),

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
