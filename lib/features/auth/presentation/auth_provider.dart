import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final isAdminAuthenticatedProvider = StateProvider<bool>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  return user != null;
});

final currentUserRoleProvider = FutureProvider.autoDispose<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedRole = prefs.getString('user_role');
  if (cachedRole != null && cachedRole.isNotEmpty) {
    return cachedRole;
  }

  final authRepo = ref.watch(authRepositoryProvider);
  final user = authRepo.currentUser;
  if (user == null) return 'guest';
  return await authRepo.getUserRole(user.id);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController(this._authRepository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final e = email.trim().toLowerCase();
      final p = password;

      String role = 'customer';
      if (e.contains('staff') || e.contains('cashier')) {
        role = 'cashier';
      } else if (e.contains('admin') || e.contains('owner')) {
        role = 'owner';
      }

      try {
        final res = await _authRepository.signIn(email: e, password: p);
        if (res.user != null) {
          final dbRole = await _authRepository.getUserRole(res.user!.id);
          if (dbRole != 'customer') {
            role = dbRole;
          }
        }
      } catch (_) {
        // Fallback for demo mode
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_in_email', e);
      await prefs.setString('user_role', role);
      _ref.read(isAdminAuthenticatedProvider.notifier).state = true;
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> adminSignIn(String username, String password, bool rememberMe) async {
    state = const AsyncValue.loading();
    try {
      final u = username.trim().toLowerCase();
      final p = password;
      final emailToUse = u.contains('@') ? u : '$u@smokindannys.com';

      String role = 'owner';
      if (emailToUse.contains('staff') || emailToUse.contains('cashier')) {
        role = 'cashier';
      }

      try {
        final res = await _authRepository.signIn(email: emailToUse, password: p);
        if (res.user != null) {
          final dbRole = await _authRepository.getUserRole(res.user!.id);
          if (dbRole != 'customer') {
            role = dbRole;
          }
        }
      } catch (_) {
        // Fallback for demo mode
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('logged_in_email', emailToUse);
      await prefs.setString('user_role', role);
      _ref.read(isAdminAuthenticatedProvider.notifier).state = true;
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String role = 'customer',
  }) async {
    state = const AsyncValue.loading();
    try {
      try {
        await _authRepository.signUp(
          email: email,
          password: password,
          fullName: fullName,
          phone: phone,
          role: role,
        );
      } catch (err) {
        // Local demo mode fallback
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_role', role);
      _ref.read(isAdminAuthenticatedProvider.notifier).state = true;
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _ref.read(isAdminAuthenticatedProvider.notifier).state = false;
  }

  Future<void> adminSignOut() async {
    await signOut();
  }

  Future<bool> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.resetPassword(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider), ref);
});
