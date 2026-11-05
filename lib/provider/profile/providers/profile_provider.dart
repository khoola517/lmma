import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:khadematy_web/core/config/supabase_config.dart';
import 'package:khadematy_web/core/services/storage_service.dart';
import 'package:khadematy_web/data/mock/provider_mock_data.dart';
import 'package:khadematy_web/provider/profile/models/provider_profile_model.dart';
import 'package:khadematy_web/provider/reviews/models/review_model.dart';
import 'package:khadematy_web/admin/notifications/models/admin_notification_model.dart';

class ProfileProvider extends ChangeNotifier {
  late ProviderProfileModel _profile;
  List<ReviewModel> _reviews = [];
  List<NotificationModel> _notifications = [];
  double? _ratingFilter;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _lastLoadedUserId;
  String? _lastLoadedProviderId;

  ProfileProvider() {
    _profile = ProviderMockData.initialProfile;
    _reviews = List.from(ProviderMockData.initialReviews);
    _notifications = List.from(ProviderMockData.initialNotifications);
    // Load dynamically from Supabase if client and session are active
    loadProfile();
  }

  // Getters
  ProviderProfileModel get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // Reviews
  List<ReviewModel> get reviews {
    if (_ratingFilter == null) return _reviews;
    return _reviews.where((r) => r.rating >= _ratingFilter!).toList();
  }

  int get totalReviewsCount => _reviews.length;

  double get averageRating {
    if (_reviews.isEmpty) return _profile.overallRating;
    final total = _reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / _reviews.length).toStringAsFixed(1));
  }

  int get fiveStarCount => _reviews.where((r) => r.rating >= 4.5).length;

  void setRatingFilter(double? rating) {
    _ratingFilter = rating;
    notifyListeners();
  }

  // Notifications
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  /// زيادة عداد الحجوزات عند قبول وتأكيد حجز جديد
  void incrementBookingsCount() {
    _profile = _profile.copyWith(
      completedBookingsCount: _profile.completedBookingsCount + 1,
    );
    notifyListeners();
  }

  /// تحميل الملف الشخصي والتقييمات والإحصائيات من Supabase
  Future<void> loadProfile({
    String? providerId,
    String? userId,
    bool force = false,
  }) async {
    if (!SupabaseConfig.hasClient) return;
    if (_isLoading && !force) return;

    final currentUser = SupabaseConfig.client.auth.currentUser;
    final resolvedUserId = userId ?? currentUser?.id;

    if (resolvedUserId == null && (providerId == null || providerId.isEmpty)) {
      return;
    }

    if (!force &&
        _lastLoadedUserId == resolvedUserId &&
        _lastLoadedProviderId == providerId &&
        _profile.id != null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. جلب بيانات ملف مزود الخدمة من جدول provider_profiles
      Map<String, dynamic>? prov;
      if (providerId != null && providerId.isNotEmpty) {
        prov = await SupabaseConfig.client
            .from('provider_profiles')
            .select()
            .eq('id', providerId)
            .maybeSingle();
      } else if (resolvedUserId != null) {
        prov = await SupabaseConfig.client
            .from('provider_profiles')
            .select()
            .eq('user_id', resolvedUserId)
            .maybeSingle();
      }

      // إذا لم يتوفر ملف للمستخدم الحالي (مثلاً أدمن أو حساب تجريبي)، نأخذ أول مزود متاح للعرض
      if (prov == null) {
        try {
          prov = await SupabaseConfig.client
              .from('provider_profiles')
              .select()
              .limit(1)
              .maybeSingle();
        } catch (_) {}
      }

      final targetUserId = prov?['user_id'] as String? ?? resolvedUserId;
      final targetProviderId = prov?['id'] as String?;

      // 2. جلب بيانات المستخدم من جدول profiles
      Map<String, dynamic>? userProf;
      if (targetUserId != null) {
        try {
          userProf = await SupabaseConfig.client
              .from('profiles')
              .select()
              .eq('id', targetUserId)
              .maybeSingle();
        } catch (e) {
          debugPrint('Error fetching user profile: $e');
        }
      }

      // 3. جلب التصنيف الرئيسي للخدمات
      String category = prov?['category'] as String? ?? '';
      if (category.isEmpty && targetProviderId != null) {
        try {
          final serviceWithCat = await SupabaseConfig.client
              .from('services')
              .select('categories(name)')
              .eq('provider_id', targetProviderId)
              .limit(1)
              .maybeSingle();
          if (serviceWithCat != null && serviceWithCat['categories'] != null) {
            category = serviceWithCat['categories']['name'] as String? ?? '';
          }
        } catch (_) {}
      }
      if (category.isEmpty) {
        category = 'تنظيم وتنسيق الحفلات';
      }

      // 4. جلب التقييمات المرتبطة بخدمات هذا المزود من Supabase
      List<ReviewModel> loadedReviews = [];
      if (targetProviderId != null) {
        try {
          final revRes = await SupabaseConfig.client
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

          final list = (revRes as List).map((r) => r as Map<String, dynamic>).where((r) {
            final s = r['service'] as Map<String, dynamic>?;
            return s != null && s['provider_id'] == targetProviderId;
          }).toList();

          loadedReviews = list
              .map((r) => ReviewModel.fromJson(r))
              .toList();
        } catch (e) {
          debugPrint('Error loading reviews in ProfileProvider: $e');
        }
      }

      _reviews = loadedReviews;

      // حساب التقييم الإجمالي
      double computedRating = 5.0;
      if (_reviews.isNotEmpty) {
        final total = _reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
        computedRating =
            double.parse((total / _reviews.length).toStringAsFixed(1));
      }

      // 5. حساب عدد الحجوزات المكتملة من قاعدة البيانات
      int completedBookings = 0;
      if (targetProviderId != null) {
        try {
          final res = await SupabaseConfig.client
              .from('booking_items')
              .select('id, bookings!inner(status), services!inner(provider_id)')
              .eq('services.provider_id', targetProviderId)
              .eq('bookings.status', 'completed');
          completedBookings = (res as List).length;
        } catch (_) {
          completedBookings = 0;
        }
      }

      // 6. جلب الإشعارات
      if (targetUserId != null) {
        try {
          final notifsRes = await SupabaseConfig.client
              .from('notifications')
              .select()
              .eq('user_id', targetUserId)
              .order('created_at', ascending: false)
              .limit(20);

          final notifsList = (notifsRes as List)
              .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
              .toList();

          if (notifsList.isNotEmpty) {
            _notifications = notifsList;
          }
        } catch (e) {
          debugPrint('Error loading notifications: $e');
        }
      }

      // 7. تحديث كائن الملف الشخصي
      if (prov != null) {
        _profile = ProviderProfileModel.fromSupabase(
          providerProfile: prov,
          userProfile: userProf,
          rating: computedRating,
          completedCount: completedBookings,
          categoryName: category,
        );
      } else if (userProf != null) {
        _profile = _profile.copyWith(
          userId: targetUserId,
          businessName:
              userProf['full_name'] as String? ?? _profile.businessName,
          phone: userProf['phone'] as String? ?? _profile.phone,
          email: userProf['email'] as String? ?? _profile.email,
          logoUrl: userProf['avatar_url'] as String? ?? _profile.logoUrl,
        );
      }

      _lastLoadedUserId = resolvedUserId;
      _lastLoadedProviderId = targetProviderId;
    } catch (e) {
      debugPrint('Error in loadProfile: $e');
      _errorMessage = 'تعذر تحميل بيانات الملف الشخصي: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث الملف الشخصي في Supabase
  Future<bool> updateProfile({
    required String businessName,
    required String phone,
    required String email,
    required String location,
    required String category,
    required String bio,
    String? logoUrl,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = SupabaseConfig.client.auth.currentUser;
      final userId = _profile.userId ?? currentUser?.id;
      final providerId = _profile.id;

      // 1. تحديث جدول provider_profiles
      if (providerId != null && providerId.isNotEmpty) {
        await SupabaseConfig.client.from('provider_profiles').update({
          'business_name': businessName.trim(),
          'address': location.trim(),
          'category': category.trim(),
          'description': bio.trim(),
          if (logoUrl != null) 'logo_url': logoUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', providerId);
      } else if (userId != null && userId.isNotEmpty) {
        await SupabaseConfig.client.from('provider_profiles').upsert({
          'user_id': userId,
          'business_name': businessName.trim(),
          'address': location.trim(),
          'category': category.trim(),
          'description': bio.trim(),
          if (logoUrl != null) 'logo_url': logoUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // 2. تحديث جدول profiles (الاسم، الهاتف، البريد، الصورة)
      if (userId != null && userId.isNotEmpty) {
        await SupabaseConfig.client.from('profiles').update({
          'full_name': businessName.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          if (logoUrl != null) 'avatar_url': logoUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }

      // 3. تحديث جدول provider_applications إن وجد لمزامنة البيانات
      if (userId != null && userId.isNotEmpty) {
        try {
          await SupabaseConfig.client.from('provider_applications').update({
            'business_name': businessName.trim(),
            'phone': phone.trim(),
            'address': location.trim(),
            'description': '$category - ${bio.trim()}',
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', userId);
        } catch (_) {}
      }

      // 4. تحديث الحالة المحلية
      _profile = _profile.copyWith(
        businessName: businessName.trim(),
        phone: phone.trim(),
        email: email.trim(),
        location: location.trim(),
        category: category.trim(),
        bio: bio.trim(),
        logoUrl: logoUrl ?? _profile.logoUrl,
      );

      return true;
    } catch (e) {
      debugPrint('Error updating profile in Supabase: $e');
      _errorMessage = 'فشل حفظ التعديلات: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// رفع وتحديث الشعار في مساحة تخزين Supabase
  Future<String?> uploadProfileLogo({
    required Uint8List bytes,
    required String fileName,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = fileName
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\.]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      final path = 'profiles/${timestamp}_$safeName';

      final publicUrl = await StorageService.uploadServiceImage(
        bytes: bytes,
        originalName: fileName,
        customPath: path,
      );

      if (publicUrl != null) {
        final success = await updateProfile(
          businessName: _profile.businessName,
          phone: _profile.phone,
          email: _profile.email,
          location: _profile.location,
          category: _profile.category,
          bio: _profile.bio,
          logoUrl: publicUrl,
        );
        if (success) {
          return publicUrl;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading profile logo: $e');
      _errorMessage = 'فشل رفع الشعار: $e';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// الرد على تقييم في Supabase
  Future<bool> replyToReview(String reviewId, String reply) async {
    try {
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index].providerReply = reply;
        notifyListeners();
      }

      await SupabaseConfig.client.from('reviews').update({
        'provider_reply': reply.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);

      return true;
    } catch (e) {
      debugPrint('Error replying to review in Supabase: $e');
      return false;
    }
  }

  /// تحديد جميع الإشعارات كمقروءة في Supabase
  Future<void> markAllNotificationsAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();

    try {
      final currentUser = SupabaseConfig.client.auth.currentUser;
      final userId = _profile.userId ?? currentUser?.id;
      if (userId != null) {
        await SupabaseConfig.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('is_read', false);
      }
    } catch (e) {
      debugPrint('Error marking all notifications read in Supabase: $e');
    }
  }

  /// تحديد إشعار محدد كمقروء في Supabase
  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }

    try {
      await SupabaseConfig.client
          .from('notifications')
          .update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('Error marking notification read in Supabase: $e');
    }
  }
}