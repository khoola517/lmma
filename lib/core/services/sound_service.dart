import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Conditionally import dart:html for Web Audio
import 'web_audio_stub.dart'
    if (dart.library.html) 'web_audio_html.dart' as audio_impl;

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  /// تشغيل نغمة إشعار مسموعة ومميزة
  Future<void> playNotificationSound() async {
    try {
      if (kIsWeb) {
        // تشغيل نغمة ويب نقية باستخدام Web Audio API
        audio_impl.playWebChime();
      }
      // تنبيه النظام الاحتياطي
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('SoundService note: $e');
    }
  }
}

