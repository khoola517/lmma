import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = true; // Default logged in for easy testing, or false if starting from login
  String _providerName = 'الأندلس لتنسيق المناسبات';
  String _providerEmail = 'contact@alandalus.com';
  String _providerPhone = '770000000';

  bool get isAuthenticated => _isAuthenticated;
  String get providerName => _providerName;
  String get providerEmail => _providerEmail;
  String get providerPhone => _providerPhone;

  void login({required String email, required String password}) {
    _isAuthenticated = true;
    _providerEmail = email.isNotEmpty ? email : _providerEmail;
    notifyListeners();
  }

  void register({
    required String businessName,
    required String email,
    required String phone,
    required String serviceType,
    required String city,
    required String bio,
  }) {
    _isAuthenticated = true;
    _providerName = businessName;
    _providerEmail = email;
    _providerPhone = phone;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
