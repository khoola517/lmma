import 'package:flutter/material.dart';

enum AdminNavItem {
  dashboard,
  users,
  applications,
  categories,
  services,
  bookings,
  reviews,
  complaints,
  notifications,
  settings,
  profile,
}

class AdminNavigationProvider extends ChangeNotifier {
  AdminNavItem _selectedItem = AdminNavItem.dashboard;
  bool _isSidebarCollapsed = false;
  String _searchQuery = '';

  AdminNavItem get selectedItem => _selectedItem;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  String get searchQuery => _searchQuery;

  void selectItem(AdminNavItem item) {
    if (_selectedItem != item) {
      _selectedItem = item;
      _searchQuery = '';
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }
}
