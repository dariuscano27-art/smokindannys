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

  // Controllers
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

    return Scaffold(
      backgroundColor: AppTheme.darkMaroonBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header Logo & Branding
              _buildHeaderLogo(),

              const SizedBox(height: 24),

              // Segmented Tab Bar (Log In / Sign Up)
              _buildSegmentedTabBar(),

              const SizedBox(height: 20),

              // Form Container Card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkCardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF331419), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _selectedTab == 0
                        ? _buildLoginForm(isLoading)
                        : _buildSignupForm(isLoading),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow Effect
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF800000).withOpacity(0.6),
                const Color(0xFFFF9800).withOpacity(0.2),
                Colors.transparent,
              ],
              radius: 0.8,
            ),
          ),
        ),
        Column(
          children: [
            // Mascot Badge
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFFB300), Color(0xFF800000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8008).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.outdoor_grill_rounded, size: 42, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFFFD54F), Colors.white],
              ).createShader(bounds),
              child: const Text(
                'Smokin Dannys',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.extrabold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
            const Text(
              'BBQ & POS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: Color(0xFFFFD54F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentedTabBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF240F13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3B171D), width: 1.2),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTab != 0) {
                  setState(() => _selectedTab = 0);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: _selectedTab == 0
                      ? const LinearGradient(
                          colors: [Color(0xFF4A1F18), Color(0xFF331512)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFC837).withOpacity(0.2),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 0 ? Colors.white : const Color(0xFF9E8B8E),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTab != 1) {
                  setState(() => _selectedTab = 1);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: _selectedTab == 1
                      ? const LinearGradient(
                          colors: [Color(0xFF4A1F18), Color(0xFF331512)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFC837).withOpacity(0.2),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 1 ? Colors.white : const Color(0xFF9E8B8E),
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
        _buildFieldLabel('Email'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _loginEmailController,
          hintText: 'davidjonson@gmail.com',
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
              color: const Color(0xFF9E8B8E),
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

        // Remember Me & Forgot Password Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: const Color(0xFFFFC837),
                    checkColor: Colors.black,
                    side: const BorderSide(color: Color(0xFF6E565B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                ),
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
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Primary Log In Button
        _buildActionButton(
          text: 'Log In',
          isLoading: isLoading,
          onPressed: _handleLogin,
        ),

        const SizedBox(height: 20),

        // Divider
        _buildSocialDivider(),

        const SizedBox(height: 16),

        // Social Logins
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
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
        ),

        const SizedBox(height: 14),

        _buildFieldLabel('Email Address'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupEmailController,
          hintText: 'davidjonson@gmail.com',
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
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Please enter your phone number' : null,
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
              color: const Color(0xFF9E8B8E),
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

        // Terms Checkbox
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _acceptTerms,
                activeColor: const Color(0xFFFFC837),
                checkColor: Colors.black,
                side: const BorderSide(color: Color(0xFF6E565B)),
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
                    style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Primary Sign Up Button
        _buildActionButton(
          text: 'Sign Up',
          isLoading: isLoading,
          onPressed: _handleSignup,
        ),

        const SizedBox(height: 16),

        // Divider
        _buildSocialDivider(),

        const SizedBox(height: 14),

        // Social Logins
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFD4C5C8),
        fontSize: 13,
        fontWeight: FontWeight.w500,
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
        hintStyle: const TextStyle(color: Color(0xFF6E585C), fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF9E8B8E), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.darkInputBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppTheme.darkInputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppTheme.darkInputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFFFC837), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.4),
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
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC837), Color(0xFFFF8008)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8008).withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
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
        Expanded(child: Container(height: 1, color: const Color(0xFF33171C))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'or continue with',
            style: TextStyle(color: Color(0xFF8C7377), fontSize: 12),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFF33171C))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialPillButton(
            icon: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  color: Color(0xFFEA4335),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            label: 'Google',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Sign-In coming soon!')),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSocialPillButton(
            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
            label: 'Facebook',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Facebook Sign-In coming soon!')),
              );
            },
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
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.darkInputBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF3A181E), width: 1),
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
