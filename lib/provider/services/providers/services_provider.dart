import 'package:flutter/material.dart';
import 'package:khadematy_web/core/config/supabase_config.dart';
import 'package:khadematy_web/core/constants/app_constants.dart';
import 'package:khadematy_web/core/services/supabase_realtime_service.dart';
import 'package:khadematy_web/provider/services/models/service_model.dart';

class ServicesProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastLoadedProviderId;
  final List<RealtimeSubscriptionToken> _realtimeTokens = [];

  ServicesProvider() {
    loadCategories();
    _initRealtime();
  }

  void _initRealtime() {
    // 1. الاستماع لتحديثات التصنيفات لحظياً
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'categories',
        onInserted: (_) => loadCategories(),
        onUpdated: (_) => loadCategories(),
        onDeleted: (_) => loadCategories(),
      ),
    );

    // 2. الاستماع لتحديثات الخدمات لحظياً
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'services',
        onInserted: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
        onUpdated: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
        onDeleted: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
      ),
    );

    // 3. الاستماع لتحديثات توفر الخدمات وصورها لحظياً
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'service_availability',
        onInserted: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
        onUpdated: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
        onDeleted: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
      ),
    );
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'service_images',
        onInserted: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
        onUpdated: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
        onDeleted: (_) => loadServices(providerId: _lastLoadedProviderId, force: true),
      ),
    );

    // 3. إعادة المزامنة عند استعادة الاتصال
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.onReconnected(() {
        loadCategories();
        loadServices(providerId: _lastLoadedProviderId, force: true);
      }),
    );
  }

  // Getters
  List<ServiceModel> get allServices => _services;
  List<Map<String, dynamic>> get categoriesList => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  int get totalServicesCount => _services.length;

  /// قائمة التصنيفات المتاحة ديناميكياً من Supabase
  List<String> get availableCategories {
    final names = <String>['الكل'];
    for (final cat in _categories) {
      final name = cat['name'] as String?;
      if (name != null && !names.contains(name)) {
        names.add(name);
      }
    }
    for (final s in _services) {
      if (s.category.isNotEmpty && !names.contains(s.category)) {
        names.add(s.category);
      }
    }
    if (names.length == 1) {
      names.addAll(AppConstants.serviceCategories.where((c) => c != 'الكل'));
    }
    return names;
  }

  /// تصفية الخدمات حسب التصنيف والبحث
  List<ServiceModel> get services {
    return _services.where((s) {
      final matchesCategory =
          _selectedCategory == 'الكل' || s.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.occasion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  /// تحميل التصنيفات من جدول categories في Supabase
  Future<void> loadCategories() async {
    try {
      final response = await SupabaseConfig.client
          .from('categories')
          .select('id, name, is_active, sort_order')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      _categories = List<Map<String, dynamic>>.from(response as List);
      notifyListeners();
    } catch (e) {
      debugPrint('Note: Error loading categories from Supabase: $e');
    }
  }

  /// تحميل الخدمات من Supabase
  /// إذا كان providerId محدداً يتم جلب خدمات ذلك المزود فقط
  Future<void> loadServices({String? providerId, bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. تحميل التصنيفات إن لم تكن محملة
      if (_categories.isEmpty) {
        await loadCategories();
      }

      // 2. تحديد معرّف المزود المستهدف
      String? resolvedProviderId = providerId;
      if (resolvedProviderId == null || resolvedProviderId.isEmpty) {
        final user = SupabaseConfig.client.auth.currentUser;
        if (user != null) {
          try {
            final prov = await SupabaseConfig.client
                .from('provider_profiles')
                .select('id')
                .eq('user_id', user.id)
                .maybeSingle();
            if (prov != null) {
              resolvedProviderId = prov['id'] as String?;
            }
          } catch (_) {}
        }
      }

      _lastLoadedProviderId = resolvedProviderId;

      // 3. بناء الاستعلام مع الربط بجدول التصنيفات وصور الخدمة
      var query = SupabaseConfig.client
          .from('services')
          .select('*, categories(id, name), service_images(image_url, sort_order)');

      if (resolvedProviderId != null && resolvedProviderId.isNotEmpty) {
        query = query.eq('provider_id', resolvedProviderId);
      }

      final response = await query.order('created_at', ascending: false);
      final list = response as List;

      _services = list
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading services from Supabase: $e');
      _errorMessage = 'تعذر جلب الخدمات من السيرفر: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة خدمة جديدة في Supabase
  Future<bool> addService(ServiceModel service, {String? providerId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // تحديد provider_id
      String? targetProviderId =
          providerId ?? service.providerId ?? _lastLoadedProviderId;

      if (targetProviderId == null || targetProviderId.isEmpty) {
        final user = SupabaseConfig.client.auth.currentUser;
        if (user != null) {
          try {
            final prov = await SupabaseConfig.client
                .from('provider_profiles')
                .select('id')
                .eq('user_id', user.id)
                .maybeSingle();
            if (prov != null) {
              targetProviderId = prov['id'] as String?;
            }
          } catch (e) {
            debugPrint('Error looking up provider for user: $e');
          }
        }
      }

      // Fallback: If still null (e.g. testing or admin without provider profile), use existing provider
      if (targetProviderId == null || targetProviderId.isEmpty) {
        try {
          final defaultProv = await SupabaseConfig.client
              .from('provider_profiles')
              .select('id')
              .limit(1)
              .maybeSingle();
          if (defaultProv != null) {
            targetProviderId = defaultProv['id'] as String?;
          }
        } catch (e) {
          debugPrint('Fallback provider lookup note: $e');
        }
      }

      if (targetProviderId == null || targetProviderId.isEmpty) {
        throw Exception('لم يتم العثور على ملف مزود خدمة مرتبط بحسابك في النظام');
      }

      // تحديد category_id من اسم التصنيف
      String? targetCategoryId = service.categoryId;
      if (targetCategoryId == null || targetCategoryId.isEmpty) {
        final match = _categories.firstWhere(
          (c) => c['name'] == service.category,
          orElse: () => _categories.isNotEmpty
              ? _categories.first
              : {'id': null},
        );
        targetCategoryId = match['id'] as String?;
      }

      if (targetCategoryId == null || targetCategoryId.isEmpty) {
        final catRes = await SupabaseConfig.client
            .from('categories')
            .select('id')
            .limit(1)
            .maybeSingle();
        targetCategoryId = catRes?['id'] as String?;
      }

      if (targetCategoryId == null) {
        throw Exception('يرجى اختيار تصنيف صالح للخدمة');
      }

      final payload = {
        'provider_id': targetProviderId,
        'category_id': targetCategoryId,
        'name': service.name.trim(),
        'description': service.description.trim(),
        'price': service.price,
        'currency': 'YER',
        'image_url': service.imageUrls.isNotEmpty ? service.imageUrls.first : null,
        'status': service.isAvailable ? 'active' : 'inactive',
        if (service.location != null && service.location!.isNotEmpty)
          'location': service.location,
        if (service.capacity != null) 'capacity': service.capacity,
        'features': service.features,
      };

      Map<String, dynamic> insertRes;
      try {
        insertRes = await SupabaseConfig.client
            .from('services')
            .insert(payload)
            .select('*, categories(id, name), service_images(image_url, sort_order)')
            .single();
      } catch (e) {
        debugPrint('Direct join select note, trying simple select: $e');
        insertRes = await SupabaseConfig.client
            .from('services')
            .insert(payload)
            .select()
            .single();
      }

      final created = ServiceModel.fromJson(insertRes).copyWith(
        category: service.category,
        imageUrls: service.imageUrls,
      );

      // حفظ بقية الصور في service_images
      if (service.imageUrls.length > 1) {
        for (int i = 1; i < service.imageUrls.length; i++) {
          try {
            await SupabaseConfig.client.from('service_images').insert({
              'service_id': created.id,
              'image_url': service.imageUrls[i],
              'sort_order': i,
            });
          } catch (e) {
            debugPrint('Image insert note: $e');
          }
        }
      }

      _services.insert(0, created);
      return true;
    } catch (e) {
      debugPrint('Error inserting service into Supabase: $e');
      _errorMessage = 'فشل إضافة الخدمة: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث خدمة حالية في Supabase
  Future<bool> updateService(ServiceModel updatedService) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // مطابقة category_id
      String? targetCategoryId = updatedService.categoryId;
      if (targetCategoryId == null || targetCategoryId.isEmpty) {
        final match = _categories.firstWhere(
          (c) => c['name'] == updatedService.category,
          orElse: () => {'id': null},
        );
        targetCategoryId = match['id'] as String?;
      }

      final payload = {
        'name': updatedService.name.trim(),
        'description': updatedService.description.trim(),
        'price': updatedService.price,
        'currency': 'YER',
        if (targetCategoryId != null) 'category_id': targetCategoryId,
        if (updatedService.imageUrls.isNotEmpty)
          'image_url': updatedService.imageUrls.first,
        'status': updatedService.isAvailable ? 'active' : 'inactive',
        if (updatedService.location != null) 'location': updatedService.location,
        if (updatedService.capacity != null) 'capacity': updatedService.capacity,
        'features': updatedService.features,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final updateRes = await SupabaseConfig.client
          .from('services')
          .update(payload)
          .eq('id', updatedService.id)
          .select('*, categories(id, name), service_images(image_url, sort_order)')
          .single();

      // مزامنة الصور الإضافية في جدول service_images
      try {
        await SupabaseConfig.client
            .from('service_images')
            .delete()
            .eq('service_id', updatedService.id);

        if (updatedService.imageUrls.length > 1) {
          final extraImages = <Map<String, dynamic>>[];
          for (int i = 1; i < updatedService.imageUrls.length; i++) {
            extraImages.add({
              'service_id': updatedService.id,
              'image_url': updatedService.imageUrls[i],
              'sort_order': i,
            });
          }
          if (extraImages.isNotEmpty) {
            await SupabaseConfig.client.from('service_images').insert(extraImages);
          }
        }
      } catch (e) {
        debugPrint('Image sync note on update: $e');
      }

      final refreshed = ServiceModel.fromJson(updateRes).copyWith(
        category: updatedService.category,
        imageUrls: updatedService.imageUrls,
      );
      final index = _services.indexWhere((s) => s.id == updatedService.id);
      if (index != -1) {
        _services[index] = refreshed;
      }
      return true;
    } catch (e) {
      debugPrint('Error updating service in Supabase: $e');
      _errorMessage = 'فشل تعديل الخدمة: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حذف خدمة من Supabase
  Future<bool> deleteService(String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseConfig.client
          .from('services')
          .delete()
          .eq('id', serviceId);

      _services.removeWhere((s) => s.id == serviceId);
      return true;
    } catch (e) {
      debugPrint('Error deleting service from Supabase: $e');
      // إذا كان هناك قيود مفتاح خارجي (حجوزات سابقة) نقوم بتعطيل الخدمة كحل بديل
      try {
        await SupabaseConfig.client
            .from('services')
            .update({
              'status': 'inactive',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', serviceId);

        final idx = _services.indexWhere((s) => s.id == serviceId);
        if (idx != -1) {
          _services[idx] = _services[idx].copyWith(
            isAvailable: false,
            status: 'inactive',
          );
        }
        _errorMessage =
            'تم إلغاء تفعيل الخدمة بدلاً من حذفها لوجود حجوزات سابقة مرتبطة بها.';
        return true;
      } catch (inner) {
        _errorMessage = 'تعذر حذف الخدمة: $e';
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تبديل حالة توفر الخدمة (active / inactive)
  Future<bool> toggleServiceAvailability(String serviceId) async {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index == -1) return false;

    final current = _services[index];
    final newAvailability = !current.isAvailable;
    final newStatus = newAvailability ? 'active' : 'inactive';

    // تحديث محلي سريع للتفاعل الفوري
    _services[index] = current.copyWith(
      isAvailable: newAvailability,
      status: newStatus,
    );
    notifyListeners();

    try {
      await SupabaseConfig.client
          .from('services')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', serviceId);
      return true;
    } catch (e) {
      debugPrint('Error toggling availability in Supabase: $e');
      _services[index] = current;
      _errorMessage = 'فشل تحديث حالة الخدمة: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    for (final token in _realtimeTokens) {
      token.cancel();
    }
    _realtimeTokens.clear();
    super.dispose();
  }
}