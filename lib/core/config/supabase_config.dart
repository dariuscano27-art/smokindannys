import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Your official Supabase Project URL and Publishable API Key
  static const String supabaseUrl = 'https://ngwxonkfjzsmibwdmpmx.supabase.co';
  static const String supabasePublishableKey = 'sb_publishable__XCdXoiduRzJavF5NBRQwQ_zTwejiPp';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
