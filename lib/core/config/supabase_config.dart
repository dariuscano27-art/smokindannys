import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Your official Supabase Project URL and Anon API Key
  static const String supabaseUrl = 'https://ngwxonkfjzsmibwdmpmx.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable__XCdXoiduRzJavF5NBRQwQ_zTwejiPp';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
