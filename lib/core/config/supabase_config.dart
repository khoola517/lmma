// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://lynrgiiseawlulwpdesv.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_gBDSZglDdnrWJ14Pz2ti2Q_gjSQ7yhW';

  static SupabaseClient get client => Supabase.instance.client;

  static bool get hasClient {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }
}
