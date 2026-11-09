import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/firebase_options.dart';
import '../config/supabase_config.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  String? _currentToken;
  bool _initialized = false;

  /// دالة لمعالجة أو بث الرسائل الواردة أثناء فتح الويب (Foreground)
  final ValueNotifier<RemoteMessage?> onForegroundMessage = ValueNotifier(null);

  /// تهيئة خدمة إشعارات FCM للويب
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. تهيئة Firebase Web
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. طلب صلاحيات الإشعارات من متصفح الويب
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Web Notification permission status: ${settings.authorizationStatus}');

      // 3. الاستماع للرسائل في الواجهة الأمامية أثناء فتح لوحة التحكم
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Web Foreground message received: ${message.notification?.title}');
        onForegroundMessage.value = message;
      });

      // 4. الاستماع للنقر على الإشعار عند فتح التبويب
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Web Notification clicked: ${message.data}');
      });

      // 5. الاستماع لتحديث التوكن
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Web Token refreshed: $newToken');
        _currentToken = newToken;
        syncTokenWithSupabase();
      });

      // 6. ربط مزامنة التوكن بحالة تسجيل الدخول في Supabase
      _initAuthListener();

      _initialized = true;
      debugPrint('FCM Service initialized successfully for Web');
    } catch (e) {
      debugPrint('FCM Web Service initialization note: $e');
    }
  }

  /// ربط الخدمة بحالة الدخول والخروج في Supabase
  void _initAuthListener() {
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final hasSession = data.session != null;
      debugPrint('>>> FCM Web AuthListener event: $event (hasSession: $hasSession)');
      if (hasSession) {
        syncTokenWithSupabase();
      } else if (event == AuthChangeEvent.signedOut) {
        _currentToken = null;
      }
    });

    if (SupabaseConfig.client.auth.currentUser != null) {
      syncTokenWithSupabase();
    }
  }

  /// مزامنة وتسجيل التوكن في Supabase
  Future<void> syncTokenWithSupabase() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      debugPrint('FCM Web: User not authenticated, skipping token registration');
      return;
    }

    try {
      final token = await _messaging.getToken(
        vapidKey: DefaultFirebaseOptions.vapidKey,
      );

      if (token == null || token.isEmpty) {
        debugPrint('FCM Web: No token received from browser');
        return;
      }

      _currentToken = token;

      final deviceInfo = {
        'platform': 'web',
        'registered_at': DateTime.now().toIso8601String(),
      };

      await SupabaseConfig.client.rpc(
        'register_fcm_token',
        params: {
          'p_fcm_token': token,
          'p_platform': 'web',
          'p_device_info': deviceInfo,
        },
      );

      debugPrint('FCM Web Token registered successfully in Supabase for user: ${user.id}');
    } catch (e) {
      debugPrint('FCM Web Token registration note: $e');
    }
  }

  /// إلغاء ربط التوكن عند تسجيل الخروج
  Future<void> unregisterToken() async {
    final user = SupabaseConfig.client.auth.currentUser;
    final token = _currentToken;

    if (user == null || token == null || token.isEmpty) return;

    try {
      await SupabaseConfig.client.rpc(
        'unregister_fcm_token',
        params: {
          'p_fcm_token': token,
        },
      );
      debugPrint('FCM Web Token unregistered successfully from Supabase');
    } catch (e) {
      debugPrint('FCM Web Token unregister note: $e');
    } finally {
      _currentToken = null;
    }
  }
}
