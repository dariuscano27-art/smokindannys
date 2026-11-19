import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const LoginScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late int _selectedTab; // 0 = Log In, 1 = Sign Up
  final _formKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _signupFullNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _rememberMe = false;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFullNameController.dispose();
    _signupEmailController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signIn(
          _loginEmailController.text.trim(),
          _loginPasswordController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      final authRepo = ref.read(authRepositoryProvider);
      final user = authRepo.currentUser;
      if (!mounted) return;

      if (user != null) {
        final role = await authRepo.getUserRole(user.id);
        if (!mounted) return;

        if (role == 'owner') {
          context.go('/owner/dashboard');
        } else if (role == 'cashier') {
          context.go('/cashier/pos');
        } else {
          context.go('/customer/home');
        }
      } else {
        context.go('/customer/home');
      }
    } else {
      final errorState = ref.read(authControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${errorState.error ?? "Invalid credentials"}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the Terms and Conditions to register'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).signUp(
          email: _signupEmailController.text.trim(),
          password: _signupPasswordController.text.trim(),
          fullName: _signupFullNameController.text.trim(),
          phone: _signupPhoneController.text.trim(),
          role: 'customer',
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Switching to Log In.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedTab = 0;
        _loginEmailController.text = _signupEmailController.text;
      });
    } else {
      final errorState = ref.read(authControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${errorState.error ?? "Please check your details"}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: _buildWebHeader(context, isDesktop),
      body: SafeArea(
        child: Center(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40.0 : 20.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1040 : 480,
                ),
                child: isDesktop
                    ? _buildDesktopWebLayout(isLoading)
                    : _buildMobileTabletLayout(isLoading),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildWebHeader(BuildContext context, bool isDesktop) {
    return AppBar(
      backgroundColor: AppTheme.darkBg,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: isDesktop ? 48 : 16,
      title: InkWell(
        onTap: () => context.go('/'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryRed,
              ),
              child: const Icon(Icons.location_on, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'SMOKIN DANNYS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_outlined, color: AppTheme.textMuted, size: 18),
          label: const Text('Home', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => context.go('/customer/home'),
          icon: const Icon(Icons.restaurant_menu_outlined, color: AppTheme.textMuted, size: 18),
          label: const Text('Menu', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
        ),
        SizedBox(width: isDesktop ? 48 : 16),
      ],
    );
  }

  Widget _buildDesktopWebLayout(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column: Hero Branding
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF160303), Color(0xFF0D0D0D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryRed,
                      ),
                      child: const Icon(Icons.outdoor_grill_rounded, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'GOOD FOOD.\nDELIVERED\nFASTER.',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sign in to access your orders, cashier POS terminals, and owner management analytics.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _heroCheck('Real-time order placement & kitchen queue'),
                    const SizedBox(height: 12),
                    _heroCheck('Touchscreen POS terminal integration'),
                    const SizedBox(height: 12),
                    _heroCheck('Owner sales analytics & reports'),
                  ],
                ),
              ),
            ),

            // Right Column: Form Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSegmentedTabBar(),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _selectedTab == 0
                            ? _buildLoginForm(isLoading)
                            : _buildSignupForm(isLoading),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCheck(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppTheme.primaryRed, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildMobileTabletLayout(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark, width: 1),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Icon(Icons.outdoor_grill_rounded, size: 48, color: AppTheme.primaryRed),
            const SizedBox(height: 12),
            const Text(
              'SMOKIN DANNYS',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildSegmentedTabBar(),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedTab == 0
                  ? _buildLoginForm(isLoading)
                  : _buildSignupForm(isLoading),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.surfaceBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppTheme.borderDark, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: _selectedTab == 0 ? AppTheme.primaryRed : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 0 ? Colors.white : AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: _selectedTab == 1 ? AppTheme.primaryRed : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 1 ? Colors.white : AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Email Address'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _loginEmailController,
          hintText: 'name@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter your email';
            if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Password'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _loginPasswordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.textMuted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter your password';
            if (value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppTheme.primaryRed,
                    checkColor: Colors.white,
                    side: const BorderSide(color: AppTheme.borderDark),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Remember me', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ],
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset link sent if registered.')),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppTheme.primaryRed, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildActionButton(text: 'Log In', isLoading: isLoading, onPressed: _handleLogin),
        const SizedBox(height: 20),
        _buildSocialDivider(),
        const SizedBox(height: 16),
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildSignupForm(bool isLoading) {
    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Full Name'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupFullNameController,
          hintText: 'David Johnson',
          prefixIcon: Icons.person_outline,
          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('Email Address'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupEmailController,
          hintText: 'name@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter your email';
            if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('Phone Number'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupPhoneController,
          hintText: '09123456789',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your phone number' : null,
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('Enter Password'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupPasswordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureSignupPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureSignupPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.textMuted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter a password';
            if (value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: _acceptTerms,
                activeColor: AppTheme.primaryRed,
                checkColor: Colors.white,
                side: const BorderSide(color: AppTheme.borderDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => setState(() => _acceptTerms = val ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/terms'),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(text: 'Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildActionButton(text: 'Create Account', isLoading: isLoading, onPressed: _handleSignup),
        const SizedBox(height: 16),
        _buildSocialDivider(),
        const SizedBox(height: 14),
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: AppTheme.textMuted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surfaceBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.primaryRed, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.8),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 4,
          shadowColor: const Color(0x66E50914),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.borderDark)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'or continue with',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.borderDark)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialPillButton(
            icon: const Text('G', style: TextStyle(color: Color(0xFFEA4335), fontWeight: FontWeight.bold, fontSize: 14)),
            label: 'Google',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSocialPillButton(
            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 20),
            label: 'Facebook',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPillButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderDark, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
