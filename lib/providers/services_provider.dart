import 'package:flutter/material.dart';
import '../data/mock/provider_mock_data.dart';
import '../models/service_model.dart';

class ServicesProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  ServicesProvider() {
    _services = List.from(ProviderMockData.initialServices);
  }

  List<ServiceModel> get services {
    return _services.where((s) {
      final matchesCategory = _selectedCategory == 'الكل' || s.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.contains(_searchQuery) ||
          s.category.contains(_searchQuery) ||
          s.occasion.contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get totalServicesCount => _services.length;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void addService(ServiceModel service) {
    _services.insert(0, service);
    notifyListeners();
  }

  void updateService(ServiceModel updatedService) {
    final index = _services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      _services[index] = updatedService;
      notifyListeners();
    }
  }

  void deleteService(String serviceId) {
    _services.removeWhere((s) => s.id == serviceId);
    notifyListeners();
  }

  void toggleServiceAvailability(String serviceId) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      _services[index] = _services[index].copyWith(
        isAvailable: !_services[index].isAvailable,
      );
      notifyListeners();
    }
  }
}
