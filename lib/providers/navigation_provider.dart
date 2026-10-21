import 'package:flutter/material.dart';

enum ProviderNavItem {
  dashboard,
  bookingRequests,
  confirmedBookings,
  myServices,
  reviews,
  profile,
  settings,
}

class NavigationProvider extends ChangeNotifier {
  ProviderNavItem _selectedItem = ProviderNavItem.dashboard;
  bool _isSidebarCollapsed = false;

  ProviderNavItem get selectedItem => _selectedItem;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  void selectItem(ProviderNavItem item) {
    if (_selectedItem != item) {
      _selectedItem = item;
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }
}
