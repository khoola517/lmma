import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'fcm_service.dart';
import 'sound_service.dart';
import 'supabase_realtime_service.dart';
import '../../provider/settings/models/provider_settings_model.dart';

class InAppAlertEvent {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime receivedAt;

  const InAppAlertEvent({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.receivedAt,
  });
}

/// خدمة مركزية لإدارة إظهار اللافتات المنبثقة والتنبيهات الصوتية لحظياً على الويب
/// عبر Supabase Realtime (جدول notifications) و Firebase Cloud Messaging مع منع التكرار.
class LiveNotificationBannerService {
  LiveNotificationBannerService._();
  static final LiveNotificationBannerService instance =
      LiveNotificationBannerService._();

  final ValueNotifier<InAppAlertEvent?> currentAlert = ValueNotifier(null);

  bool _initialized = false;
  RealtimeSubscriptionToken? _notifRealtimeToken;
  StreamSubscription<AuthState>? _authSub;
  String? _activeUserId;
  Timer? _dismissTimer;
  ProviderSettingsModel Function()? _settingsResolver;

  final Map<String, DateTime> _recentAlertKeys = {};

  void initialize({ProviderSettingsModel Function()? settingsResolver}) {
    if (settingsResolver != null) {
      _settingsResolver = settingsResolver;
    }
    if (_initialized) return;
    _initialized = true;

    FcmService.instance.onForegroundMessage.addListener(_onFcmMessage);

    if (SupabaseConfig.hasClient) {
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser != null) {
        _subscribeForUser(currentUser.id);
      }

      _authSub = SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
        final userId = data.session?.user.id;
        if (userId != null) {
          _subscribeForUser(userId);
        } else {
          _unsubscribeUser();
        }
      });
    }
  }

  void updateSettingsResolver(ProviderSettingsModel Function() resolver) {
    _settingsResolver = resolver;
  }

  void _subscribeForUser(String userId) {
    if (_activeUserId == userId && _notifRealtimeToken != null) return;
    _unsubscribeUser();
    _activeUserId = userId;

    _notifRealtimeToken = SupabaseRealtimeService.instance.subscribeTable(
      table: 'notifications',
      filter: 'user_id=eq.$userId',
      onInserted: (record) {
        _handleRealtimeNotification(record);
      },
    );
    debugPrint('LiveNotificationBannerService: Subscribed to Realtime notifications for $userId');
  }

  void _unsubscribeUser() {
    _notifRealtimeToken?.cancel();
    _notifRealtimeToken = null;
    _activeUserId = null;
  }

  void _handleRealtimeNotification(Map<String, dynamic> record) {
    final id = record['id']?.toString() ?? '';
    final title = record['title']?.toString() ?? 'تنبيه جديد';
    final body = record['body']?.toString() ?? '';
    final type = record['type']?.toString() ?? '';

    _dispatchAlert(
      id: id,
      title: title,
      body: body,
      type: type,
    );
  }

  void _onFcmMessage() {
    final msg = FcmService.instance.onForegroundMessage.value;
    if (msg == null) return;

    final id = msg.data['id']?.toString() ?? '';
    final title = msg.notification?.title ?? msg.data['title']?.toString() ?? 'تنبيه جديد';
    final body = msg.notification?.body ?? msg.data['body']?.toString() ?? '';
    final type = msg.data['type']?.toString() ?? '';

    _dispatchAlert(
      id: id,
      title: title,
      body: body,
      type: type,
    );
  }

  bool _isDuplicate(String id, String title, String body) {
    final now = DateTime.now();
    _recentAlertKeys.removeWhere((_, ts) => now.difference(ts).inSeconds > 15);

    final idKey = id.isNotEmpty ? 'id:$id' : null;
    final contentKey = 'content:${title.trim()}|${body.trim()}';

    if (idKey != null && _recentAlertKeys.containsKey(idKey)) return true;
    if (_recentAlertKeys.containsKey(contentKey)) return true;

    if (idKey != null) _recentAlertKeys[idKey] = now;
    _recentAlertKeys[contentKey] = now;
    return false;
  }

  void _dispatchAlert({
    required String id,
    required String title,
    required String body,
    required String type,
    bool bypassPreferences = false,
  }) {
    if (!bypassPreferences && _isDuplicate(id, title, body)) {
      return;
    }

    final settings = _settingsResolver?.call() ?? const ProviderSettingsModel();
    final lowerType = type.toLowerCase();

    final isNewOrder = lowerType == 'new_booking_request' ||
        lowerType == 'booking_request' ||
        title.contains('حجز جديد') ||
        body.contains('طلب حجز جديد');

    final isOrderUpdate = !isNewOrder &&
        lowerType != 'booking_created' &&
        (lowerType.startsWith('booking_') ||
            title.contains('تحديث') ||
            title.contains('تأكيد') ||
            title.contains('إلغاء'));

    if (!bypassPreferences) {
      if (isNewOrder && !settings.newOrderNotifications) return;
      if (isOrderUpdate && !settings.orderUpdatesNotifications) return;
    }

    if (settings.soundAlerts || bypassPreferences) {
      SoundService.instance.playNotificationSound();
    }

    _showBanner(
      InAppAlertEvent(
        id: id.isNotEmpty ? id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.isNotEmpty ? title : 'تنبيه جديد',
        body: body,
        type: type,
        receivedAt: DateTime.now(),
      ),
    );
  }

  void _showBanner(InAppAlertEvent event) {
    _dismissTimer?.cancel();
    currentAlert.value = event;
    _dismissTimer = Timer(const Duration(seconds: 6), dismiss);
  }

  void triggerTestAlert() {
    _dispatchAlert(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'اختبار التنبيهات الصوتية واللافتات',
      body: 'نظام الإشعارات الفورية والتنبيهات الصوتية يعمل بنجاح في لوحة التحكم!',
      type: 'test',
      bypassPreferences: true,
    );
  }

  void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    currentAlert.value = null;
  }

  void dispose() {
    _dismissTimer?.cancel();
    _authSub?.cancel();
    _unsubscribeUser();
    FcmService.instance.onForegroundMessage.removeListener(_onFcmMessage);
  }
}
