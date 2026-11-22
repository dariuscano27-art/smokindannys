import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/admin_login_page.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/terms_screen.dart';
import '../../features/catalog/presentation/customer_home_screen.dart';
import '../../features/dashboard/presentation/owner_dashboard_screen.dart';
import '../../features/landing/presentation/landing_screen.dart';
import '../../features/pos/presentation/cashier_pos_screen.dart';
import '../../core/theme/app_theme.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<bool>(isAdminAuthenticatedProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final isAdminAuthenticated = ref.read(isAdminAuthenticatedProvider);
      final isGoingToAdminDashboard = state.matchedLocation == '/owner/dashboard' ||
          state.matchedLocation == '/admin/dashboard';

      // Protect admin dashboard route from unauthenticated users
      if (isGoingToAdminDashboard && !isAdminAuthenticated) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        name: 'admin_login',
        builder: (context, state) => AdminLoginPage(
          onLogin: (username, password, rememberMe) async {
            final success = await ref
                .read(authControllerProvider.notifier)
                .adminSignIn(username, password, rememberMe);
            if (success && context.mounted) {
              context.go('/owner/dashboard');
              return true;
            }
            return false;
          },
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/customer/home',
        name: 'customer_home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/owner/dashboard',
        name: 'owner_dashboard',
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/cashier/pos',
        name: 'cashier_pos',
        builder: (context, state) => const CashierPosScreen(),
      ),
    ],
  );
});

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80, color: AppTheme.primaryMaroon),
            const SizedBox(height: 16),
            Text(
              'Smokin Dannys',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
