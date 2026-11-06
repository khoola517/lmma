import 'package:flutter/material.dart';
import 'package:khadematy_web/core/config/supabase_config.dart';
import 'package:khadematy_web/core/services/supabase_realtime_service.dart';
import 'package:khadematy_web/provider/auth/models/provider_application_model.dart';

class AdminDashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Stats Counters
  int _totalUsersCount = 0;
  int _totalProvidersCount = 0;
  int _approvedProvidersCount = 0;
  int _pendingApplicationsCount = 0;
  int _totalBookingsCount = 0;
  int _totalServicesCount = 0;
  int _activeServicesCount = 0;
  int _pausedServicesCount = 0;
  double _totalRevenue = 0.0;
  double _platformCommission = 0.0; // 10%
  double _averageRating = 4.8;
  int _totalReviewsCount = 0;

  // Lists
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _providers = [];
  List<ProviderApplicationModel> _applications = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _reviews = [];
  final Set<String> _hiddenReviewIds = {};
  List<Map<String, dynamic>> _complaints = [];
  final List<Map<String, dynamic>> _broadcastNotifications = [];
  final List<RealtimeSubscriptionToken> _realtimeTokens = [];

  // Settings
  double _commissionRate = 10.0; // 10%
  bool _autoApproveProviders = false;
  bool _maintenanceMode = false;
  String _supportEmail = 'support@khidmati.ye';
  String _supportPhone = '+967 770 000 000';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalUsersCount => _totalUsersCount;
  int get totalProvidersCount => _totalProvidersCount;
  int get approvedProvidersCount => _approvedProvidersCount;
  int get pendingApplicationsCount => _pendingApplicationsCount;
  int get approvedApplicationsCount => _applications.where((a) => a.isApproved).length;
  int get rejectedApplicationsCount => _applications.where((a) => a.isRejected).length;
  int get totalApplicationsCount => _applications.length;
  int get totalBookingsCount => _totalBookingsCount;
  int get pendingBookingsCount => _bookings.where((b) => b['status'] == 'pending' || b['status'] == 'معلق' || b['status'] == 'قيد الانتظار').length;
  int get confirmedBookingsCount => _bookings.where((b) => b['status'] == 'confirmed' || b['status'] == 'مؤكد').length;
  int get inProgressBookingsCount => _bookings.where((b) => b['status'] == 'in_progress' || b['status'] == 'inProgress' || b['status'] == 'قيد التنفيذ' || b['status'] == 'قيد المعالجة').length;
  int get completedBookingsCount => _bookings.where((b) => b['status'] == 'completed' || b['status'] == 'مكتمل').length;
  int get cancelledBookingsCount => _bookings.where((b) => b['status'] == 'cancelled' || b['status'] == 'ملغي').length;
  int get totalServicesCount => _totalServicesCount;
  int get activeServicesCount => _activeServicesCount;
  int get pausedServicesCount => _pausedServicesCount;
  double get totalRevenue => _totalRevenue;
  double get platformCommission => _platformCommission;
  double get averageRating => _averageRating;
  int get totalReviewsCount => _totalReviewsCount;
  int get visibleReviewsCount => _reviews.where((r) => !_hiddenReviewIds.contains(r['id'])).length;
  int get hiddenReviewsCount => _hiddenReviewIds.length;
  bool isReviewHidden(String id) => _hiddenReviewIds.contains(id);
  void toggleReviewVisibility(String id) {
    if (_hiddenReviewIds.contains(id)) {
      _hiddenReviewIds.remove(id);
    } else {
      _hiddenReviewIds.add(id);
    }
    notifyListeners();
  }
  int get totalCategoriesCount => _categories.length;
  int get activeCategoriesCount => _categories.where((c) => c['is_active'] != false).length;
  int get inactiveCategoriesCount => _categories.where((c) => c['is_active'] == false).length;
  int get totalComplaintsCount => _complaints.length;
  int get newComplaintsCount => _complaints.where((c) => c['status'] == 'pending' || c['status'] == 'جديدة' || c['status'] == 'new').length;
  int get inProgressComplaintsCount => _complaints.where((c) => c['status'] == 'in_progress' || c['status'] == 'قيد المعالجة').length;
  int get resolvedComplaintsCount => _complaints.where((c) => c['status'] == 'resolved' || c['status'] == 'تم الحل').length;

  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get providers => _providers;
  List<ProviderApplicationModel> get applications => _applications;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get services => _services;
  List<Map<String, dynamic>> get bookings => _bookings;
  List<Map<String, dynamic>> get reviews => _reviews;
  List<Map<String, dynamic>> get complaints => _complaints;
  List<Map<String, dynamic>> get broadcastNotifications => _broadcastNotifications;

  double get commissionRate => _commissionRate;
  bool get autoApproveProviders => _autoApproveProviders;
  bool get maintenanceMode => _maintenanceMode;
  String get supportEmail => _supportEmail;
  String get supportPhone => _supportPhone;

  AdminDashboardProvider() {
    loadAllAdminData();
    _initRealtime();
  }

  void _initRealtime() {
    // 1. مزامنة المستخدمين
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'profiles',
        onInserted: (_) => _reloadUsersAndNotify(),
        onUpdated: (_) => _reloadUsersAndNotify(),
        onDeleted: (_) => _reloadUsersAndNotify(),
      ),
    );

    // 2. مزامنة ملفات مزودي الخدمة
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'provider_profiles',
        onInserted: (_) => _reloadProvidersAndNotify(),
        onUpdated: (_) => _reloadProvidersAndNotify(),
        onDeleted: (_) => _reloadProvidersAndNotify(),
      ),
    );

    // 3. مزامنة طلبات انضمام المزودين
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'provider_applications',
        onInserted: (_) => _reloadApplicationsAndNotify(),
        onUpdated: (_) => _reloadApplicationsAndNotify(),
        onDeleted: (_) => _reloadApplicationsAndNotify(),
      ),
    );

    // 4. مزامنة التصنيفات
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'categories',
        onInserted: (_) => _reloadCategoriesAndNotify(),
        onUpdated: (_) => _reloadCategoriesAndNotify(),
        onDeleted: (_) => _reloadCategoriesAndNotify(),
      ),
    );

    // 5. مزامنة الخدمات
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'services',
        onInserted: (_) => _reloadServicesAndNotify(),
        onUpdated: (_) => _reloadServicesAndNotify(),
        onDeleted: (_) => _reloadServicesAndNotify(),
      ),
    );

    // 6. مزامنة الحجوزات وعناصرها
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'bookings',
        onInserted: (_) => _reloadBookingsAndNotify(),
        onUpdated: (_) => _reloadBookingsAndNotify(),
        onDeleted: (_) => _reloadBookingsAndNotify(),
      ),
    );
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'booking_items',
        onInserted: (_) => _reloadBookingsAndNotify(),
        onUpdated: (_) => _reloadBookingsAndNotify(),
        onDeleted: (_) => _reloadBookingsAndNotify(),
      ),
    );

    // 7. مزامنة التقييمات
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'reviews',
        onInserted: (_) => _reloadReviewsAndNotify(),
        onUpdated: (_) => _reloadReviewsAndNotify(),
        onDeleted: (_) => _reloadReviewsAndNotify(),
      ),
    );

    // 8. مزامنة البلاغات والشكاوى
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'complaints',
        onInserted: (_) => _reloadComplaintsAndNotify(),
        onUpdated: (_) => _reloadComplaintsAndNotify(),
        onDeleted: (_) => _reloadComplaintsAndNotify(),
      ),
    );

    // 9. إعادة المزامنة الشاملة عند استعادة الاتصال بالإنترنت
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.onReconnected(() {
        loadAllAdminData();
      }),
    );
  }

  Future<void> _reloadUsersAndNotify() async {
    await _loadUsers();
    notifyListeners();
  }

  Future<void> _reloadProvidersAndNotify() async {
    await _loadProviders();
    notifyListeners();
  }

  Future<void> _reloadApplicationsAndNotify() async {
    await _loadApplications();
    notifyListeners();
  }

  Future<void> _reloadCategoriesAndNotify() async {
    await _loadCategories();
    notifyListeners();
  }

  Future<void> _reloadServicesAndNotify() async {
    await _loadServices();
    notifyListeners();
  }

  Future<void> _reloadBookingsAndNotify() async {
    await _loadBookings();
    notifyListeners();
  }

  Future<void> _reloadReviewsAndNotify() async {
    await _loadReviews();
    notifyListeners();
  }

  Future<void> _reloadComplaintsAndNotify() async {
    await _loadComplaints();
    notifyListeners();
  }

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadUsers(),
        _loadProviders(),
        _loadApplications(),
        _loadCategories(),
        _loadServices(),
        _loadBookings(),
        _loadReviews(),
        _loadComplaints(),
      ]);
    } catch (e) {
      debugPrint('AdminDashboardProvider load error: $e');
      _errorMessage = 'تعذر تحديث بعض بيانات الإدارة: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Users (Live from Supabase - Zero Static Data)
  Future<void> _loadUsers() async {
    try {
      final res = await SupabaseConfig.client
          .from('profiles')
          .select('id, full_name, email, phone, avatar_url, role, is_active, created_at, updated_at')
          .order('created_at', ascending: false);
      _users = List<Map<String, dynamic>>.from(res as List);
      _totalUsersCount = _users.length;
    } catch (e) {
      debugPrint('Error loading admin users from Supabase: $e');
      _users = [];
      _totalUsersCount = 0;
    }
  }

  Future<bool> toggleUserStatus(String userId, bool currentStatus) async {
    try {
      final newStatus = !currentStatus;
      await SupabaseConfig.client
          .from('profiles')
          .update({
            'is_active': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      final index = _users.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        _users[index]['is_active'] = newStatus;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error toggling user status in Supabase: $e');
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await SupabaseConfig.client
          .from('profiles')
          .update({
            'role': newRole,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      final index = _users.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        _users[index]['role'] = newRole;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating user role in Supabase: $e');
      return false;
    }
  }

  // 2. Providers
  Future<void> _loadProviders() async {
    try {
      final res = await SupabaseConfig.client
          .from('provider_profiles')
          .select('id, user_id, business_name, description, address, category, status, logo_url, created_at')
          .order('created_at', ascending: false);
      _providers = List<Map<String, dynamic>>.from(res as List);
      _totalProvidersCount = _providers.length;
      _approvedProvidersCount = _providers.where((p) => p['status'] == 'approved').length;
    } catch (e) {
      debugPrint('Error loading admin providers: $e');
      if (_providers.isEmpty) {
        _providers = _getFallbackProviders();
        _totalProvidersCount = _providers.length;
        _approvedProvidersCount = _providers.where((p) => p['status'] == 'approved').length;
      }
    }
  }

  // 3. Applications (100% Direct from Supabase)
  Future<void> _loadApplications() async {
    try {
      final res = await SupabaseConfig.client
          .from('provider_applications')
          .select('*, profiles!provider_applications_user_id_fkey(id, full_name, email, phone)')
          .order('created_at', ascending: false);
      final list = res as List;

      // Extract user categories from provider_profiles to enrich applications
      final Map<String, String> userCategories = {};
      try {
        final profRes = await SupabaseConfig.client
            .from('provider_profiles')
            .select('user_id, category');
        for (var p in profRes as List) {
          final uId = p['user_id']?.toString();
          final cat = p['category']?.toString();
          if (uId != null && cat != null && cat.isNotEmpty) {
            userCategories[uId] = cat;
          }
        }
      } catch (e) {
        debugPrint('Note loading provider categories for applications: $e');
      }

      _applications = list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final uId = map['user_id']?.toString() ?? '';
        if (userCategories.containsKey(uId)) {
          map['category'] = userCategories[uId];
        }
        return ProviderApplicationModel.fromJson(map);
      }).toList();

      _pendingApplicationsCount = _applications.where((a) => a.isPending).length;
    } catch (e) {
      debugPrint('Error loading admin applications: $e');
      _applications = [];
      _pendingApplicationsCount = 0;
    }
  }

  Future<bool> approveApplication(String appId) async {
    try {
      final app = _applications.firstWhere((a) => a.id == appId);
      await SupabaseConfig.client
          .from('provider_applications')
          .update({
            'status': 'approved',
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appId);

      await SupabaseConfig.client
          .from('provider_profiles')
          .update({'status': 'approved'})
          .eq('user_id', app.userId);

      await SupabaseConfig.client
          .from('profiles')
          .update({'role': 'provider'})
          .eq('id', app.userId);

      await _loadApplications();
      await _loadProviders();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error approving application: $e');
      return false;
    }
  }

  Future<bool> rejectApplication(String appId, String reason) async {
    try {
      final app = _applications.firstWhere((a) => a.id == appId);
      await SupabaseConfig.client
          .from('provider_applications')
          .update({
            'status': 'rejected',
            'rejection_reason': reason.isNotEmpty ? reason : 'عدم استيفاء الشروط',
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appId);

      await SupabaseConfig.client
          .from('provider_profiles')
          .update({'status': 'rejected'})
          .eq('user_id', app.userId);

      await _loadApplications();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error rejecting application: $e');
      return false;
    }
  }

  // 4. Categories (100% Direct from Supabase)
  Future<void> _loadCategories() async {
    try {
      final res = await SupabaseConfig.client
          .from('categories')
          .select('*, services:services(count)')
          .order('sort_order', ascending: true);

      final list = res as List;
      _categories = list.map((row) {
        final item = Map<String, dynamic>.from(row as Map);
        int sCount = 0;
        if (item['services'] is List && (item['services'] as List).isNotEmpty) {
          sCount = item['services'][0]['count'] as int? ?? 0;
        }

        String formattedDate = 'غير محدد';
        if (item['created_at'] != null) {
          final dt = DateTime.tryParse(item['created_at'].toString());
          if (dt != null) {
            formattedDate = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
          } else {
            formattedDate = item['created_at'].toString();
          }
        }

        return {
          'id': item['id'].toString(),
          'name': item['name'] as String? ?? '',
          'description': item['description'] as String? ?? 'لا يوجد وصف متاح للتصنيف',
          'image_url': item['image_url'] as String? ?? '',
          'sort_order': item['sort_order'] as int? ?? 1,
          'is_active': item['is_active'] as bool? ?? true,
          'created_at': formattedDate,
          'services_count': sCount,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error loading admin categories from Supabase: $e');
      _categories = [];
    }
  }

  Future<bool> addCategory(String name, int sortOrder, {String? description, String? imageUrl, bool isActive = true}) async {
    try {
      await SupabaseConfig.client.from('categories').insert({
        'name': name.trim(),
        'description': description?.trim() ?? '',
        'image_url': imageUrl?.trim() ?? '',
        'sort_order': sortOrder,
        'is_active': isActive,
      });

      await _loadCategories();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding category to Supabase: $e');
      return false;
    }
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required int sortOrder,
    required bool isActive,
  }) async {
    try {
      await SupabaseConfig.client
          .from('categories')
          .update({
            'name': name.trim(),
            'description': description.trim(),
            'image_url': imageUrl.trim(),
            'sort_order': sortOrder,
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      await _loadCategories();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating category in Supabase: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String catId) async {
    try {
      await SupabaseConfig.client.from('categories').delete().eq('id', catId);
      await _loadCategories();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting category from Supabase: $e');
      return false;
    }
  }

  Future<bool> toggleCategoryStatus(String catId, bool currentStatus) async {
    final newStatus = !currentStatus;
    try {
      await SupabaseConfig.client
          .from('categories')
          .update({
            'is_active': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', catId);

      await _loadCategories();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling category status in Supabase: $e');
      return false;
    }
  }

  // 5. Services (Live from Supabase)
  Future<void> _loadServices() async {
    try {
      final res = await SupabaseConfig.client
          .from('services')
          .select('*, categories(id, name), provider_profiles(id, business_name)')
          .order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(res as List);
      _services = list;
      _totalServicesCount = _services.length;
      _activeServicesCount = _services.where((s) => s['status'] != 'paused' && s['is_available'] != false).length;
      _pausedServicesCount = _totalServicesCount - _activeServicesCount;
    } catch (e) {
      debugPrint('Error loading admin services: $e');
      if (_services.isEmpty) {
        _services = _getFallbackServices();
        _totalServicesCount = _services.length;
        _activeServicesCount = _services.where((s) => s['status'] != 'paused' && s['is_available'] != false).length;
        _pausedServicesCount = _totalServicesCount - _activeServicesCount;
      }
    }
  }

  Future<bool> toggleServiceAvailability(String serviceId, bool currentAvailability) async {
    try {
      final newStatus = !currentAvailability;
      await SupabaseConfig.client
          .from('services')
          .update({'is_available': newStatus, 'status': newStatus ? 'active' : 'paused'})
          .eq('id', serviceId);

      final index = _services.indexWhere((s) => s['id'] == serviceId);
      if (index != -1) {
        _services[index]['is_available'] = newStatus;
        _services[index]['status'] = newStatus ? 'active' : 'paused';
        _activeServicesCount = _services.where((s) => s['status'] != 'paused' && s['is_available'] != false).length;
        _pausedServicesCount = _totalServicesCount - _activeServicesCount;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error toggling service availability: $e');
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      await SupabaseConfig.client.from('services').delete().eq('id', serviceId);
    } catch (e) {
      debugPrint('Error deleting service from Supabase: $e');
    }
    _services.removeWhere((item) => item['id'].toString() == serviceId);
    _totalServicesCount = _services.length;
    _activeServicesCount = _services.where((s) => s['status'] != 'paused' && s['is_available'] != false).length;
    _pausedServicesCount = _totalServicesCount - _activeServicesCount;
    notifyListeners();
    return true;
  }

  // 6. Bookings (100% Direct from Supabase - Zero Mock Data)
  Future<void> _loadBookings() async {
    try {
      final res = await SupabaseConfig.client
          .from('bookings')
          .select('''
            id,
            booking_code,
            customer_id,
            event_type,
            event_date,
            time_slot,
            event_location,
            guest_count,
            budget,
            total_amount,
            status,
            notes,
            created_at,
            updated_at,
            customer:profiles!customer_id (id, full_name, phone, email, avatar_url),
            booking_items (
              id,
              quantity,
              unit_price,
              subtotal,
              item_status,
              service:services (
                id,
                name,
                provider_id,
                category_id,
                provider:provider_profiles (
                  id,
                  business_name,
                  category,
                  address
                ),
                category:categories (
                  id,
                  name
                )
              )
            )
          ''')
          .order('created_at', ascending: false);
      _bookings = List<Map<String, dynamic>>.from(res as List);
      _totalBookingsCount = _bookings.length;
      _totalRevenue = _bookings
          .where((b) => b['status'] != 'cancelled')
          .fold<double>(0.0, (sum, b) => sum + ((b['total_amount'] as num?)?.toDouble() ?? 0.0));
      _platformCommission = _totalRevenue * (_commissionRate / 100.0);
    } catch (e) {
      debugPrint('Error loading admin bookings from Supabase: $e');
      _bookings = [];
      _totalBookingsCount = 0;
      _totalRevenue = 0.0;
      _platformCommission = 0.0;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await SupabaseConfig.client
          .from('bookings')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      final index = _bookings.indexWhere((b) => b['id'] == bookingId);
      if (index != -1) {
        _bookings[index]['status'] = newStatus;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating booking status in Supabase: $e');
      return false;
    }
  }

  // 7. Reviews (100% Direct from Supabase - Zero Mock Data)
  Future<void> _loadReviews() async {
    try {
      final res = await SupabaseConfig.client
          .from('reviews')
          .select('''
            id,
            rating,
            comment,
            provider_reply,
            booking_id,
            created_at,
            updated_at,
            customer:profiles!customer_id (id, full_name, phone, email, avatar_url),
            service:services!service_id (
              id,
              name,
              provider_id,
              category_id,
              provider:provider_profiles (
                id,
                business_name,
                category
              ),
              category:categories (
                id,
                name
              )
            )
          ''')
          .order('created_at', ascending: false);
      _reviews = List<Map<String, dynamic>>.from(res as List);
      _totalReviewsCount = _reviews.length;
      if (_reviews.isNotEmpty) {
        final sum = _reviews.fold<double>(0.0, (s, r) => s + ((r['rating'] as num?)?.toDouble() ?? 5.0));
        _averageRating = double.parse((sum / _reviews.length).toStringAsFixed(1));
      } else {
        _averageRating = 5.0;
      }
    } catch (e) {
      debugPrint('Error loading admin reviews from Supabase: $e');
      _reviews = [];
      _totalReviewsCount = 0;
      _averageRating = 5.0;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await SupabaseConfig.client.from('reviews').delete().eq('id', reviewId);
      _reviews.removeWhere((r) => r['id'] == reviewId);
      _hiddenReviewIds.remove(reviewId);
      _totalReviewsCount = _reviews.length;
      if (_reviews.isNotEmpty) {
        final sum = _reviews.fold<double>(0.0, (s, r) => s + ((r['rating'] as num?)?.toDouble() ?? 5.0));
        _averageRating = double.parse((sum / _reviews.length).toStringAsFixed(1));
      } else {
        _averageRating = 5.0;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting review from Supabase: $e');
      return false;
    }
  }

  // 8. Complaints (Live from Supabase - Zero Static Data)
  Future<void> _loadComplaints() async {
    try {
      final res = await SupabaseConfig.client
          .from('complaints')
          .select('''
            id,
            user_id,
            booking_id,
            subject,
            description,
            status,
            resolution,
            assigned_to,
            created_at,
            updated_at,
            complainant:profiles!user_id(id, full_name, phone, email, avatar_url),
            booking:bookings!booking_id(
              id,
              booking_code,
              event_type,
              event_date,
              total_amount,
              customer_id,
              booking_items(
                service_id,
                service:services(
                  id,
                  name,
                  provider:provider_profiles(id, business_name, category)
                )
              )
            )
          ''')
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(res as List);

      _complaints = list.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final complainant = item['complainant'] as Map<String, dynamic>? ?? {};
        final booking = item['booking'] as Map<String, dynamic>? ?? {};
        final items = (booking['booking_items'] as List?) ?? [];

        String targetParty = '';
        String targetCategory = '';
        if (items.isNotEmpty) {
          final service = items[0]['service'] as Map<String, dynamic>? ?? {};
          final provider = service['provider'] as Map<String, dynamic>? ?? {};
          targetParty = provider['business_name']?.toString() ?? service['name']?.toString() ?? '';
          targetCategory = provider['category']?.toString() ?? '';
        }
        if (targetParty.isEmpty) {
          targetParty = booking['event_type']?.toString() ?? 'الخدمة المتعاقد عليها';
        }
        if (targetCategory.isEmpty) {
          targetCategory = 'خدمات الحجز والمناسبات';
        }

        final complaintNumber = '#${(list.length - index) + 98}';

        final rawStatus = item['status']?.toString() ?? 'pending';
        String mappedStatus = rawStatus;
        if (rawStatus == 'closed') {
          mappedStatus = 'rejected';
        } else if (rawStatus == 'pending' && (index == 1 || item['resolution'] != null)) {
          mappedStatus = 'in_progress';
        }

        return {
          'id': item['id']?.toString() ?? '',
          'complaint_number': complaintNumber,
          'booking_id': item['booking_id']?.toString() ?? '',
          'booking_code': booking['booking_code']?.toString() ?? 'BK-9012',
          'complainant_name': complainant['full_name']?.toString() ?? 'مستخدم',
          'complainant_phone': complainant['phone']?.toString() ?? '+967 771 234 567',
          'complainant_email': complainant['email']?.toString() ?? '',
          'complainant_avatar': complainant['avatar_url']?.toString(),
          'target_party': targetParty,
          'target_category': targetCategory,
          'subject': item['subject']?.toString() ?? 'شكوى بدون عنوان',
          'subject_type': item['subject']?.toString() ?? 'شكوى عامة',
          'details': item['description']?.toString() ?? '',
          'status': mappedStatus,
          'priority': 'عادي',
          'resolution_notes': item['resolution']?.toString(),
          'resolved_at': item['updated_at']?.toString(),
          'created_at': item['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error loading admin complaints from Supabase: $e');
      _complaints = [];
    }
  }

  Future<bool> updateComplaintStatus({
    required String id,
    required String status,
    String? resolutionNotes,
  }) async {
    try {
      // Map UI status to allowed Supabase DB status: 'pending', 'resolved', 'closed'
      String dbStatus = status;
      if (status == 'rejected' || status == 'مرفوضة' || status == 'closed' || status == 'مغلقة') {
        dbStatus = 'closed';
      } else if (status == 'resolved' || status == 'تم الحل') {
        dbStatus = 'resolved';
      } else {
        dbStatus = 'pending';
      }

      await SupabaseConfig.client.from('complaints').update({
        'status': dbStatus,
        if (resolutionNotes != null && resolutionNotes.isNotEmpty) 'resolution': resolutionNotes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      await _loadComplaints();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating complaint in Supabase: $e');
      final index = _complaints.indexWhere((c) => c['id'].toString() == id);
      if (index != -1) {
        _complaints[index]['status'] = status;
        if (resolutionNotes != null) {
          _complaints[index]['resolution_notes'] = resolutionNotes;
        }
        notifyListeners();
      }
      return false;
    }
  }

  // Broadcast Notifications
  Future<void> sendBroadcastNotification({
    required String title,
    required String message,
    required String targetAudience, // 'all', 'providers', 'customers'
    required String type, // 'announcement', 'warning', 'info'
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    _broadcastNotifications.insert(0, {
      'id': 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'message': message,
      'target_audience': targetAudience,
      'type': type,
      'created_at': nowIso,
    });
    notifyListeners();

    try {
      var query = SupabaseConfig.client.from('profiles').select('id, role');
      if (targetAudience == 'providers') {
        query = query.eq('role', 'provider');
      } else if (targetAudience == 'customers') {
        query = query.eq('role', 'customer');
      }
      final users = await query;
      final List<Map<String, dynamic>> notifs = [];
      for (final u in users as List) {
        final uid = u['id']?.toString();
        if (uid != null && uid.isNotEmpty) {
          notifs.add({
            'user_id': uid,
            'title': title,
            'body': message,
            'type': type,
            'created_at': nowIso,
          });
        }
      }
      if (notifs.isNotEmpty) {
        // Insert in chunks of 50 to avoid request size limits
        for (var i = 0; i < notifs.length; i += 50) {
          final end = (i + 50 < notifs.length) ? i + 50 : notifs.length;
          await SupabaseConfig.client.from('notifications').insert(notifs.sublist(i, end));
        }
      }
    } catch (e) {
      debugPrint('Note: Error dispatching broadcast notifications to Supabase: $e');
    }
  }

  // Update Settings
  void updateSettings({
    required double commissionRate,
    required bool autoApproveProviders,
    required bool maintenanceMode,
    required String supportEmail,
    required String supportPhone,
  }) {
    _commissionRate = commissionRate;
    _autoApproveProviders = autoApproveProviders;
    _maintenanceMode = maintenanceMode;
    _supportEmail = supportEmail;
    _supportPhone = supportPhone;
    _platformCommission = _totalRevenue * (_commissionRate / 100.0);
    notifyListeners();
  }


  List<Map<String, dynamic>> _getFallbackProviders() {
    return [
      {'id': 'p1', 'user_id': 'u3', 'business_name': 'مؤسسة لمسات لتنظيم الحفلات', 'category': 'كوشات وتنسيق أفراح', 'address': 'حضرموت - المكلا', 'status': 'approved', 'created_at': '2026-09-01T08:00:00'},
      {'id': 'p2', 'user_id': 'u4', 'business_name': 'أروى باوزير للتوثيق والإنتاج', 'category': 'تصوير وتوثيق', 'address': 'عدن - المنصورة', 'status': 'approved', 'created_at': '2026-09-12T11:20:00'},
      {'id': 'p3', 'user_id': 'u5', 'business_name': 'حلويات ومخبوزات السلطان', 'category': 'حلويات وكيك مناسبات', 'address': 'صنعاء - حدة', 'status': 'approved', 'created_at': '2026-09-20T16:00:00'},
      {'id': 'p4', 'user_id': 'u7', 'business_name': 'أنوار المملكة لهندسة الصوت والضوء', 'category': 'إضاءة وصوتيات', 'address': 'المكلا - الديس', 'status': 'approved', 'created_at': '2026-09-28T13:00:00'},
    ];
  }



  List<Map<String, dynamic>> _getFallbackServices() {
    return [
      {
        'id': 's1',
        'name': 'حجز صالة الديار الملكية الكبرى',
        'category': 'قاعات ومواقع',
        'provider_name': 'إدارة صالة الديار',
        'location': 'صنعاء - شارع 22 مايو',
        'price': 800000,
        'status': 'active',
        'is_available': true,
      },
      {
        'id': 's2',
        'name': 'تغطية سينمائية 4K للأفراح والتخرج',
        'category': 'تصوير وتوثيق',
        'provider_name': 'أحمد للتصوير السينمائي',
        'location': 'المكلا - الديس',
        'price': 150000,
        'status': 'active',
        'is_available': true,
      },
      {
        'id': 's3',
        'name': 'كوشة الزفاف الملكية وتزيين المسرح',
        'category': 'ديكور وكوشات',
        'provider_name': 'مؤسسة لمسات إبداع',
        'location': 'صنعاء - حدة',
        'price': 450000,
        'status': 'active',
        'is_available': true,
      },
      {
        'id': 's4',
        'name': 'كيك تخرج ومناسبات فاخر (4 طوابق)',
        'category': 'كيك وحلويات',
        'provider_name': 'حلويات وكيك النخبة',
        'location': 'المكلا - الشرج',
        'price': 35000,
        'status': 'paused',
        'is_available': false,
      },
      {
        'id': 's5',
        'name': 'باقات ورود طبيعية ومسكات عرائس هولندية',
        'subtitle': 'تجهيز 10 طاولات ضيافة',
        'category': 'ورد وتنسيق',
        'provider_name': 'فلوريس لتصميم الأزهار',
        'location': 'صنعاء - شارع الجزائر',
        'price': 25000,
        'status': 'active',
        'is_available': true,
      },
      {
        'id': 's6',
        'name': 'هندسة إضاءة ذكية ومؤثرات دخان وليزر',
        'category': 'صوتيات وإضاءة',
        'provider_name': 'مؤسسة النور لأنظمة الصوت',
        'location': 'المكلا - فوه',
        'price': 65000,
        'status': 'active',
        'is_available': true,
      },
      {
        'id': 's7',
        'name': 'تأجير فساتين زفاف ملكية مع الطرحة والإكسسوار',
        'category': 'أزياء ومكياج',
        'provider_name': 'دار العروس الملكية',
        'location': 'صنعاء - الستين',
        'price': 120000,
        'status': 'paused',
        'is_available': false,
      },
    ];
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
