import 'package:flutter/material.dart';
import 'package:khadematy_web/core/config/supabase_config.dart';
import 'package:khadematy_web/core/services/supabase_realtime_service.dart';
import 'package:khadematy_web/provider/reviews/models/review_model.dart';

enum ReviewReplyFilter { all, replied, pending }

class ReviewsProvider extends ChangeNotifier {
  List<ReviewModel> _allReviews = [];
  bool _isLoading = false;
  bool _isSubmittingReply = false;
  String? _submittingReviewId;
  String? _errorMessage;
  String? _lastLoadedProviderId;

  // Filters & Search
  double? _ratingFilter;
  ReviewReplyFilter _replyFilter = ReviewReplyFilter.all;
  String? _selectedServiceId;
  String _searchQuery = '';

  final List<RealtimeSubscriptionToken> _realtimeTokens = [];

  ReviewsProvider() {
    loadReviews();
  }

  // Getters
  List<ReviewModel> get allReviews => _allReviews;
  bool get isLoading => _isLoading;
  bool get isSubmittingReply => _isSubmittingReply;
  String? get submittingReviewId => _submittingReviewId;
  String? get errorMessage => _errorMessage;
  double? get ratingFilter => _ratingFilter;
  ReviewReplyFilter get replyFilter => _replyFilter;
  String? get selectedServiceId => _selectedServiceId;
  String get searchQuery => _searchQuery;
  String? get lastLoadedProviderId => _lastLoadedProviderId;

  bool isActionLoading(String id) =>
      _isSubmittingReply && _submittingReviewId == id;

  /// القائمة المصفاة بناء على البحث والتصنيفات وحالة الرد
  List<ReviewModel> get reviews {
    return _allReviews.where((r) {
      // 1. تصفية التقييم
      if (_ratingFilter != null) {
        if (_ratingFilter == 5.0 && r.rating < 4.5) return false;
        if (_ratingFilter == 4.0 && (r.rating < 3.5 || r.rating >= 4.5)) return false;
        if (_ratingFilter == 3.0 && r.rating >= 3.5) return false;
      }

      // 2. تصفية حالة الرد
      if (_replyFilter == ReviewReplyFilter.replied) {
        if (r.providerReply == null || r.providerReply!.trim().isEmpty) {
          return false;
        }
      } else if (_replyFilter == ReviewReplyFilter.pending) {
        if (r.providerReply != null && r.providerReply!.trim().isNotEmpty) {
          return false;
        }
      }

      // 3. تصفية الخدمة
      if (_selectedServiceId != null && _selectedServiceId!.isNotEmpty) {
        if (r.serviceId != _selectedServiceId) return false;
      }

      // 4. تصفية نص البحث
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchCustomer = r.customerName.toLowerCase().contains(q);
        final matchComment = r.comment.toLowerCase().contains(q);
        final matchService = r.serviceName.toLowerCase().contains(q);
        final matchReply = r.providerReply?.toLowerCase().contains(q) ?? false;
        if (!matchCustomer && !matchComment && !matchService && !matchReply) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // الإحصائيات المحسوبة ديناميكياً
  int get totalReviewsCount => _allReviews.length;

  double get averageRating {
    if (_allReviews.isEmpty) return 0.0;
    final total = _allReviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / _allReviews.length).toStringAsFixed(1));
  }

  int get fiveStarCount => _allReviews.where((r) => r.rating >= 4.5).length;
  int get fourStarCount =>
      _allReviews.where((r) => r.rating >= 3.5 && r.rating < 4.5).length;
  int get threeStarCount =>
      _allReviews.where((r) => r.rating >= 2.5 && r.rating < 3.5).length;
  int get twoStarCount =>
      _allReviews.where((r) => r.rating >= 1.5 && r.rating < 2.5).length;
  int get oneStarCount => _allReviews.where((r) => r.rating < 1.5).length;

  double get satisfactionPercentage {
    if (_allReviews.isEmpty) return 100.0;
    final positive = _allReviews.where((r) => r.rating >= 4.0).length;
    return double.parse(((positive / _allReviews.length) * 100).toStringAsFixed(1));
  }

  int get reviewedServicesCount {
    return _allReviews
        .map((r) => r.serviceName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;
  }

  int get pendingRepliesCount {
    return _allReviews
        .where((r) => r.providerReply == null || r.providerReply!.trim().isEmpty)
        .length;
  }

  List<Map<String, String>> get availableServicesWithReviews {
    final Map<String, String> map = {};
    for (final r in _allReviews) {
      if (r.serviceId != null && r.serviceId!.isNotEmpty) {
        map[r.serviceId!] = r.serviceName;
      }
    }
    return map.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  // تعيين الفلاتر
  void setRatingFilter(double? rating) {
    _ratingFilter = rating;
    notifyListeners();
  }

  void setReplyFilter(ReviewReplyFilter filter) {
    _replyFilter = filter;
    notifyListeners();
  }

  void setServiceFilter(String? serviceId) {
    _selectedServiceId = serviceId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearFilters() {
    _ratingFilter = null;
    _replyFilter = ReviewReplyFilter.all;
    _selectedServiceId = null;
    _searchQuery = '';
    notifyListeners();
  }

  /// تحميل التقييمات من جدول reviews في Supabase
  Future<void> loadReviews({String? providerId, bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. تحديد معرّف المزود المستهدف
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
          } catch (e) {
            debugPrint('ReviewsProvider: error fetching provider profile: $e');
          }
        }
      }

      // إذا لم يتوفر ملف للمستخدم، نأخذ أول مزود متاح للعرض
      if (resolvedProviderId == null || resolvedProviderId.isEmpty) {
        try {
          final firstProv = await SupabaseConfig.client
              .from('provider_profiles')
              .select('id')
              .limit(1)
              .maybeSingle();
          if (firstProv != null) {
            resolvedProviderId = firstProv['id'] as String?;
          }
        } catch (_) {}
      }

      _lastLoadedProviderId = resolvedProviderId;

      // 2. استعلام Supabase لجلب التقييمات مع العميل والخدمة
      final response = await SupabaseConfig.client
          .from('reviews')
          .select('''
            id,
            rating,
            comment,
            provider_reply,
            created_at,
            updated_at,
            service_id,
            customer_id,
            customer:profiles!customer_id (id, full_name, avatar_url),
            service:services!service_id (id, name, provider_id)
          ''')
          .order('created_at', ascending: false);

      final rawList = List<Map<String, dynamic>>.from(response as List);

      // 3. تصفية التقييمات الخاصة بخدمات هذا المزود
      List<Map<String, dynamic>> filteredList = rawList;
      if (resolvedProviderId != null && resolvedProviderId.isNotEmpty) {
        filteredList = rawList.where((item) {
          final s = item['service'] as Map<String, dynamic>?;
          return s != null && s['provider_id'] == resolvedProviderId;
        }).toList();
      }

      _allReviews = filteredList.map((r) => ReviewModel.fromJson(r)).toList();

      // 4. الاشتراك في التحديثات المباشرة Realtime
      _subscribeToRealtime();
    } catch (e) {
      debugPrint('Error loading reviews from Supabase: $e');
      _errorMessage = 'تعذر تحميل التقييمات من الخادم: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إرسال أو تعديل رد مقدم الخدمة على التقييم في Supabase
  Future<bool> replyToReview({
    required String reviewId,
    required String replyText,
  }) async {
    _isSubmittingReply = true;
    _submittingReviewId = reviewId;
    notifyListeners();

    try {
      final cleanText = replyText.trim();
      final nowIso = DateTime.now().toIso8601String();

      await SupabaseConfig.client.from('reviews').update({
        'provider_reply': cleanText,
        'updated_at': nowIso,
      }).eq('id', reviewId);

      // تحديث الحالة محلياً فوراً
      final index = _allReviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _allReviews[index] = _allReviews[index].copyWith(
          providerReply: cleanText,
          updatedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error replying to review in Supabase: $e');
      _errorMessage = 'فشل إرسال الرد: $e';
      return false;
    } finally {
      _isSubmittingReply = false;
      _submittingReviewId = null;
      notifyListeners();
    }
  }

  /// حذف رد مقدم الخدمة في Supabase
  Future<bool> deleteReply(String reviewId) async {
    _isSubmittingReply = true;
    _submittingReviewId = reviewId;
    notifyListeners();

    try {
      final nowIso = DateTime.now().toIso8601String();
      await SupabaseConfig.client.from('reviews').update({
        'provider_reply': null,
        'updated_at': nowIso,
      }).eq('id', reviewId);

      final index = _allReviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _allReviews[index] = _allReviews[index].copyWith(
          providerReply: null,
          updatedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting reply in Supabase: $e');
      _errorMessage = 'فشل حذف الرد: $e';
      return false;
    } finally {
      _isSubmittingReply = false;
      _submittingReviewId = null;
      notifyListeners();
    }
  }

  /// اشتراك Realtime لمزامنة التقييمات الجديدة وتعديلاتها فوراً
  void _subscribeToRealtime() {
    if (_realtimeTokens.isNotEmpty) return;
    try {
      _realtimeTokens.add(
        SupabaseRealtimeService.instance.subscribeToReviews(
          onData: (payload) {
            debugPrint('Realtime reviews update received: ${payload.eventType}');
            loadReviews(providerId: _lastLoadedProviderId, force: true);
          },
          onResync: () {
            loadReviews(providerId: _lastLoadedProviderId, force: true);
          },
        ),
      );

      _realtimeTokens.add(
        SupabaseRealtimeService.instance.onReconnected(() {
          loadReviews(providerId: _lastLoadedProviderId, force: true);
        }),
      );
    } catch (e) {
      debugPrint('Realtime subscription error for reviews: $e');
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