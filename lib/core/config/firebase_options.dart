import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// خيارات Firebase المعتمدة لتطبيق الويب (Lamma Web - lama-a8920)
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  /// مفتاح VAPID المعتمد لإشعارات الويب (Web Push Certificate)
  static const String vapidKey =
      'BM9CZ2-Lh92iLBJX_3skzs_-ZmrkVRDl3BFt_-DTP0YpzC3qs2PKqPgVr9QIDU72VRg7yf3FtXs2gK9_lWhi30s';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for Web in this project.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAcPhmebCKas4x9L_uOl7pZuQlzgnVebeI',
    appId: '1:779197985848:web:9a2b952753672252f1e2cd',
    messagingSenderId: '779197985848',
    projectId: 'lama-a8920',
    authDomain: 'lama-a8920.firebaseapp.com',
    storageBucket: 'lama-a8920.firebasestorage.app',
  );
}
