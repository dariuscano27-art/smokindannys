import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AuthRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({required String email, required String password}) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      return await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
    } catch (e) {
      // Auto-provision customer, staff/cashier, or admin/owner if they don't exist yet in Supabase Auth
      if (cleanEmail == 'customer@smokindannys.com' || cleanEmail == 'staff@smokindannys.com' || cleanEmail == 'admin@smokindannys.com' || cleanEmail == 'owner@smokindannys.com') {
        final role = (cleanEmail == 'staff@smokindannys.com')
            ? 'cashier'
            : (cleanEmail == 'customer@smokindannys.com' ? 'customer' : 'owner');
        final fullName = (role == 'cashier') ? 'Staff Cashier' : (role == 'customer' ? 'Test Customer' : 'Store Owner');
        try {
          final signupRes = await _client.auth.signUp(
            email: cleanEmail,
            password: password,
            data: {'full_name': fullName, 'phone': '+639170000000'},
          );
          if (signupRes.user != null) {
            await _client.from('profiles').upsert({
              'id': signupRes.user!.id,
              'email': cleanEmail,
              'full_name': fullName,
              'phone': '+639170000000',
            });
            await _client.from('user_roles').upsert({
              'user_id': signupRes.user!.id,
              'role': role,
            });
            return signupRes;
          }
        } catch (_) {
          // ignore nested provisioning error and rethrow original
        }
      }
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String role = 'customer',
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );

    if (response.user != null) {
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'email': email.trim(),
        'full_name': fullName,
        'phone': phone,
      });

      await _client.from('user_roles').upsert({
        'user_id': response.user!.id,
        'role': role,
      });
    }

    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<String> getUserRole(String userId) async {
    try {
      final data = await _client
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle();
      if (data != null && data['role'] != null) {
        return data['role'].toString();
      }
    } catch (e) {
      // fallback
    }
    return 'customer';
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }
}
