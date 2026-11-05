import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khadematy_web/core/config/supabase_config.dart';
import 'package:khadematy_web/provider/auth/models/provider_application_model.dart';
import 'package:khadematy_web/provider/auth/models/user_profile_model.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  admin,
  providerApproved,
  providerPending,
  providerRejected,
  unauthorizedCustomer,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserProfileModel? _userProfile;
  Map<String, dynamic>? _providerProfile;
  ProviderApplicationModel? _currentApplication;
  List<ProviderApplicationModel> _adminApplications = [];
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserProfileModel? get userProfile => _userProfile;
  Map<String, dynamic>? get providerProfile => _providerProfile;
  String? get currentProviderId => _providerProfile?['id'] as String?;
  ProviderApplicationModel? get currentApplication => _currentApplication;
  List<ProviderApplicationModel> get adminApplications => _adminApplications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _status == AuthStatus.admin || _status == AuthStatus.providerApproved;
  bool get isAdmin => _status == AuthStatus.admin;
  bool get isProviderApproved => _status == AuthStatus.providerApproved;
  bool get isPending => _status == AuthStatus.providerPending;
  bool get isRejected => _status == AuthStatus.providerRejected;

  String get displayName {
    if (_providerProfile != null && _providerProfile!['business_name'] != null) {
      return _providerProfile!['business_name'] as String;
    }
    if (_currentApplication != null && _currentApplication!.businessName.isNotEmpty) {
      return _currentApplication!.businessName;
    }
    if (_userProfile != null && _userProfile!.fullName.isNotEmpty) {
      return _userProfile!.fullName;
    }
    return 'مقدم الخدمة';
  }

  String get email => _userProfile?.email ?? '';
  String get phone => _userProfile?.phone ?? '';

  bool get _hasClient {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    if (!_hasClient) return;
    try {
      SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session == null) {
          _status = AuthStatus.unauthenticated;
          _userProfile = null;
          _providerProfile = null;
          _currentApplication = null;
          _adminApplications = [];
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Auth listener init note: $e');
    }
  }

  /// استعادة الجلسة عند فتح التطبيق أو إعادة تحميل الصفحة
  Future<void> restoreSession() async {
    if (!_hasClient) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final session = SupabaseConfig.client.auth.currentSession;
    if (session == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _resolveUserRoleAndStatus(session.user.id);
    } catch (e) {
      debugPrint('Error restoring session: $e');
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تسجيل الدخول عبر البريد وكلمة المرور
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('تعذر الحصول على بيانات المستخدم.');
      }

      await _resolveUserRoleAndStatus(user.id);
      return true;
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
      _status = AuthStatus.unauthenticated;
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إنشاء حساب جديد لمقدم الخدمة مع طلب اعتماد بحالة pending
  Future<bool> registerProvider({
    required String businessName,
    required String email,
    required String password,
    required String phone,
    required String serviceType,
    required String city,
    required String bio,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. إنشاء الحساب في Supabase Auth
      final response = await SupabaseConfig.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': businessName.trim(),
          'phone': phone.trim(),
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('تعذر إنشاء الحساب، يرجى المحاولة لاحقاً.');
      }

      // 2. تحديث بروفايل المستخدم في جدول profiles
      try {
        await SupabaseConfig.client.from('profiles').upsert({
          'id': user.id,
          'full_name': businessName.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'role': 'customer', // يبقى customer حتى اعتماد الأدمن
          'is_active': true,
        });
      } catch (e) {
        debugPrint('Profile upsert note (handled by trigger or updated): $e');
      }

      // 3. إنشاء سجل provider_profiles بحالة pending
      try {
        await SupabaseConfig.client.from('provider_profiles').insert({
          'user_id': user.id,
          'business_name': businessName.trim(),
          'description': bio.trim(),
          'address': city.trim(),
          'status': 'pending',
        });
      } catch (e) {
        debugPrint('Provider profile creation note: $e');
      }

      // 4. إنشاء طلب اعتماد في provider_applications
      final appRes = await SupabaseConfig.client.from('provider_applications').insert({
        'user_id': user.id,
        'business_name': businessName.trim(),
        'description': '$serviceType - ${bio.trim()}',
        'phone': phone.trim(),
        'address': city.trim(),
        'status': 'pending',
      }).select().single();

      _currentApplication = ProviderApplicationModel.fromJson(appRes);
      _status = AuthStatus.providerPending;

      return true;
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تقديم الطلب: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// التحقق من صلاحيات ودور الحساب وتحديد حالة التوجيه
  Future<void> _resolveUserRoleAndStatus(String userId) async {
    // 1. جلب بيانات البروفايل من profiles
    final profileRes = await SupabaseConfig.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (profileRes == null) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'لم يتم العثور على ملف المستخدم المرتبط بهذا الحساب.';
      return;
    }

    _userProfile = UserProfileModel.fromJson(profileRes);

    if (!_userProfile!.isActive) {
      await SupabaseConfig.client.auth.signOut();
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'تم تعطيل هذا الحساب، يرجى التواصل مع إدارة المنصة.';
      return;
    }

    // 2. إذا كان الحساب مسؤول نظام (Admin)
    if (_userProfile!.isAdmin) {
      _status = AuthStatus.admin;
      await loadAdminApplications();
      return;
    }

    // 3. إذا كان الحساب مقدم خدمة معتمد (Provider)
    if (_userProfile!.isProvider) {
      final provRes = await SupabaseConfig.client
          .from('provider_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (provRes != null && provRes['status'] == 'approved') {
        _providerProfile = provRes;
        _status = AuthStatus.providerApproved;
        return;
      }
    }

    // 4. فحص طلبات الاعتماد في provider_applications
    final appRes = await SupabaseConfig.client
        .from('provider_applications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (appRes != null) {
      _currentApplication = ProviderApplicationModel.fromJson(appRes);
      if (_currentApplication!.isApproved) {
        try {
          final provRes = await SupabaseConfig.client
              .from('provider_profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
          if (provRes != null) {
            _providerProfile = provRes;
          }
        } catch (e) {
          debugPrint('Provider profile fetch note: $e');
        }
        _status = AuthStatus.providerApproved;
      } else if (_currentApplication!.isRejected) {
        _status = AuthStatus.providerRejected;
      } else {
        _status = AuthStatus.providerPending;
      }
      return;
    }

    // 5. إذا كان الحساب عميلاً عادياً ولم يقدم طلباً
    if (_userProfile!.isCustomer) {
      await SupabaseConfig.client.auth.signOut();
      _status = AuthStatus.unauthorizedCustomer;
      _errorMessage =
          'هذه البوابة مخصصة حصراً لمقدمي الخدمات وإدارة المنصة. حسابات العملاء مقتصرة على تطبيق خِدمتي للهاتف.';
      return;
    }

    _status = AuthStatus.unauthenticated;
  }

  /// للأدمن: تحميل قائمة جميع طلبات مقدمي الخدمة
  Future<void> loadAdminApplications() async {
    if (!isAdmin) return;

    try {
      final response = await SupabaseConfig.client
          .from('provider_applications')
          .select('*, profiles:user_id(full_name, email)')
          .order('created_at', ascending: false);

      final list = response as List;
      _adminApplications = list
          .map((item) =>
              ProviderApplicationModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading admin applications: $e');
    }
  }

  /// للأدمن: اعتماد طلب مقدم خدمة
  Future<bool> approveApplication(String applicationId) async {
    if (!isAdmin) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // تجربة استدعاء دالة RPC الذرية أولاً
      try {
        await SupabaseConfig.client.rpc(
          'approve_provider_application',
          params: {'p_application_id': applicationId},
        );
      } catch (rpcError) {
        debugPrint('RPC error, falling back to direct admin update: $rpcError');
        final currentAdminId = SupabaseConfig.client.auth.currentUser!.id;

        // الحصول على طلب الاعتماد
        final app = _adminApplications.firstWhere((a) => a.id == applicationId);

        // تحديث الطلب
        await SupabaseConfig.client.from('provider_applications').update({
          'status': 'approved',
          'reviewed_by': currentAdminId,
          'reviewed_at': DateTime.now().toIso8601String(),
          'rejection_reason': null,
        }).eq('id', applicationId);

        // ترقية دور المستخدم
        await SupabaseConfig.client.from('profiles').update({
          'role': 'provider',
        }).eq('id', app.userId);

        // تحديث ملف المزود
        await SupabaseConfig.client.from('provider_profiles').upsert({
          'user_id': app.userId,
          'business_name': app.businessName,
          'description': app.description,
          'address': app.address,
          'status': 'approved',
          'approved_at': DateTime.now().toIso8601String(),
        });
      }

      await loadAdminApplications();
      return true;
    } catch (e) {
      debugPrint('Error approving application: $e');
      _errorMessage = 'فشل اعتماد الطلب: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// للأدمن: رفض طلب مقدم خدمة مع تسجيل السبب
  Future<bool> rejectApplication(String applicationId, String reason) async {
    if (!isAdmin) return false;

    _isLoading = true;
    notifyListeners();

    try {
      try {
        await SupabaseConfig.client.rpc(
          'reject_provider_application',
          params: {
            'p_application_id': applicationId,
            'p_rejection_reason': reason.trim(),
          },
        );
      } catch (rpcError) {
        debugPrint('RPC error, falling back to direct admin update: $rpcError');
        final currentAdminId = SupabaseConfig.client.auth.currentUser!.id;
        final app = _adminApplications.firstWhere((a) => a.id == applicationId);

        await SupabaseConfig.client.from('provider_applications').update({
          'status': 'rejected',
          'reviewed_by': currentAdminId,
          'reviewed_at': DateTime.now().toIso8601String(),
          'rejection_reason': reason.trim(),
        }).eq('id', applicationId);

        await SupabaseConfig.client.from('provider_profiles').update({
          'status': 'rejected',
        }).eq('user_id', app.userId);
      }

      await loadAdminApplications();
      return true;
    } catch (e) {
      debugPrint('Error rejecting application: $e');
      _errorMessage = 'فشل رفض الطلب: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث الملف الشخصي للمستخدم في سوبابيز
  Future<bool> updateUserProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _userProfile?.id ?? SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      final updateData = <String, dynamic>{
        'full_name': fullName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (phone != null) updateData['phone'] = phone.trim();
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl.trim();

      await SupabaseConfig.client.from('profiles').update(updateData).eq('id', userId);

      await _resolveUserRoleAndStatus(userId);
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _errorMessage = 'فشل تحديث البيانات: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث كلمة المرور
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      _errorMessage = 'فشل تحديث كلمة المرور: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      debugPrint('Signout error: $e');
    } finally {
      _status = AuthStatus.unauthenticated;
      _userProfile = null;
      _providerProfile = null;
      _currentApplication = null;
      _adminApplications = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'بيانات الدخول غير صحيحة. يرجى التأكد من البريد الإلكتروني وكلمة المرور.';
    }
    if (message.contains('User already registered')) {
      return 'البريد الإلكتروني مسجل مسبقاً في النظام. يمكنك تسجيل الدخول بدلاً من ذلك.';
    }
    if (message.contains('Password should be at least')) {
      return 'كلمة المرور يجب أن تكون 6 أحرف أو أرقام على الأقل.';
    }
    if (message.contains('Email rate limit exceeded')) {
      return 'تم تجاوز الحد الأقصى للمحاولات. يرجى الانتظار بضع دقائق والمحاولة مجدداً.';
    }
    return message;
  }
}