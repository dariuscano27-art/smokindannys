import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final int initialTab; // 0 = Log In, 1 = Sign Up

  const LoginScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late int _selectedTab;
  final _formKey = GlobalKey<FormState>();

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Signup Controllers
  final _signupFirstNameController = TextEditingController();
  final _signupMiddleNameController = TextEditingController();
  final _signupSurnameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _acceptTerms = false;

  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _signupPasswordController.addListener(_evaluatePasswordStrength);
  }

  void _evaluatePasswordStrength() {
    final pwd = _signupPasswordController.text;
    if (pwd.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = pwd.contains(RegExp(r'[A-Z]'));
    bool hasDigits = pwd.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = pwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (pwd.length < 8 || (!hasUppercase && !hasDigits)) {
      setState(() {
        _passwordStrength = 'Weak Password';
        _passwordStrengthColor = Colors.red;
      });
    } else if (pwd.length >= 8 && hasUppercase && hasDigits && !hasSpecialCharacters) {
      setState(() {
        _passwordStrength = 'Good Password';
        _passwordStrengthColor = AppTheme.champagneGold;
      });
    } else if (pwd.length >= 10 && hasUppercase && hasDigits && hasSpecialCharacters) {
      setState(() {
        _passwordStrength = 'Strong Password';
        _passwordStrengthColor = Colors.green;
      });
    } else {
      setState(() {
        _passwordStrength = 'Good Password';
        _passwordStrengthColor = AppTheme.champagneGold;
      });
    }
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFirstNameController.dispose();
    _signupMiddleNameController.dispose();
    _signupSurnameController.dispose();
    _signupEmailController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      AppToast.show(context, message: 'Signed in successfully! Welcome back.');
      context.go('/customer/home');
    } else {
      final errorState = ref.read(authControllerProvider);
      AppToast.show(
        context,
        message: 'Login failed: ${errorState.error ?? "Invalid credentials"}',
        backgroundColor: AppTheme.errorColor,
      );
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      AppToast.show(
        context,
        message: 'You must accept the Terms and Conditions to register',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    final firstName = _signupFirstNameController.text.trim();
    final middleName = _signupMiddleNameController.text.trim();
    final surname = _signupSurnameController.text.trim();
    final fullName = '$firstName ${middleName.isNotEmpty ? '$middleName ' : ''}$surname';

    final success = await ref.read(authControllerProvider.notifier).signUp(
          email: _signupEmailController.text.trim(),
          password: _signupPasswordController.text.trim(),
          fullName: fullName,
          phone: _signupPhoneController.text.trim(),
          role: 'customer',
        );

    if (!mounted) return;

    if (success) {
      AppToast.show(context, message: 'Customer account created successfully! Switching to Log In.');
      setState(() {
        _selectedTab = 0;
        _loginEmailController.text = _signupEmailController.text;
      });
    } else {
      final errorState = ref.read(authControllerProvider);
      AppToast.show(
        context,
        message: 'Signup failed: ${errorState.error ?? "Please check your details"}',
        backgroundColor: AppTheme.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryMaroon,
        foregroundColor: Colors.white,
        title: InkWell(
          onTap: () => context.go('/'),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.outdoor_grill_rounded, size: 22, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Smokin Dannys Customer Portal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined, color: Colors.white70, size: 18),
            label: const Text('Home', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () => context.go('/customer/home'),
            icon: const Icon(Icons.restaurant_menu_outlined, color: Colors.white70, size: 18),
            label: const Text('Menu', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderMaroon, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14800020),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo & Header
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryMaroon, AppTheme.deepMaroon],
                              ),
                              border: Border.all(color: AppTheme.champagneGold, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33800020),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.outdoor_grill_rounded, size: 36, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Smokin Dannys',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryMaroon,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'CUSTOMER ONLINE ORDERING PORTAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Segmented Tab Bar (Log In / Sign Up)
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.softMaroon,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppTheme.borderMaroon, width: 1.2),
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
                                      color: _selectedTab == 0 ? AppTheme.primaryMaroon : Colors.transparent,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTab == 0 ? Colors.white : AppTheme.primaryMaroon,
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
                                      color: _selectedTab == 1 ? AppTheme.primaryMaroon : Colors.transparent,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTab == 1 ? Colors.white : AppTheme.primaryMaroon,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Account Sign In',
          style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),

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
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.primaryMaroon,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                    activeColor: AppTheme.primaryMaroon,
                    checkColor: Colors.white,
                    side: const BorderSide(color: AppTheme.borderMaroon),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Remember me', style: TextStyle(color: AppTheme.darkText, fontSize: 13)),
              ],
            ),
            GestureDetector(
              onTap: () {
                AppToast.show(context, message: 'Password reset link sent if registered.');
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        _buildActionButton(text: 'Log In to Account', isLoading: isLoading, onPressed: _handleLogin),

        const SizedBox(height: 20),
        _buildSocialDivider(),
        const SizedBox(height: 16),
        _buildSocialButtons(),
      ],
    );
  }

  Widget _buildSignupForm(bool isLoading) {
    final nameFormatter = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
    final phoneFormatter = [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))];

    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Customer Account',
          style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('First Name *'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _signupFirstNameController,
                    hintText: 'David',
                    prefixIcon: Icons.person_outline,
                    inputFormatters: nameFormatter,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : (RegExp(r'[0-9]').hasMatch(value) ? 'No numbers' : null),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Middle Name (Opt)'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _signupMiddleNameController,
                    hintText: 'Cruz',
                    prefixIcon: Icons.person_outline,
                    inputFormatters: nameFormatter,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildFieldLabel('Surname *'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupSurnameController,
          hintText: 'Johnson',
          prefixIcon: Icons.person_outline,
          inputFormatters: nameFormatter,
          validator: (value) => value == null || value.trim().isEmpty ? 'Surname required' : (RegExp(r'[0-9]').hasMatch(value) ? 'No numbers' : null),
        ),

        const SizedBox(height: 12),

        _buildFieldLabel('Email Address *'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupEmailController,
          hintText: 'name@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter email';
            if (!value.contains('@') || !value.contains('.')) return 'Invalid email format';
            return null;
          },
        ),

        const SizedBox(height: 12),

        _buildFieldLabel('Phone Number *'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupPhoneController,
          hintText: '09123456789',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: phoneFormatter,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Phone required';
            if (RegExp(r'[a-zA-Z]').hasMatch(value)) return 'No letters';
            if (value.length < 10) return 'Invalid phone';
            return null;
          },
        ),

        const SizedBox(height: 12),

        _buildFieldLabel('Enter Password *'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupPasswordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureSignupPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureSignupPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.primaryMaroon,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Password required';
            if (value.length < 8) return 'Min 8 chars required';
            if (!value.contains(RegExp(r'[A-Z]'))) return 'Must have 1 uppercase (A-Z)';
            if (!value.contains(RegExp(r'[0-9]'))) return 'Must have 1 number (0-9)';
            return null;
          },
        ),

        if (_passwordStrength.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _passwordStrengthColor),
              ),
              const SizedBox(width: 6),
              Text(
                _passwordStrength,
                style: TextStyle(color: _passwordStrengthColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),

        _buildFieldLabel('Confirm Password *'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _signupConfirmPasswordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.primaryMaroon,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Confirm password';
            if (value != _signupPasswordController.text) return 'Passwords do not match';
            return null;
          },
        ),

        const SizedBox(height: 14),

        // Terms Checkbox
        Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: _acceptTerms,
                activeColor: AppTheme.primaryMaroon,
                checkColor: Colors.white,
                side: const BorderSide(color: AppTheme.borderMaroon),
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
                    style: TextStyle(color: AppTheme.darkText, fontSize: 12),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(text: 'Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Primary Sign Up Button
        _buildActionButton(text: 'Create Customer Account', isLoading: isLoading, onPressed: _handleSignup),

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
        color: AppTheme.darkText,
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFA0989A), fontSize: 13),
        prefixIcon: Icon(prefixIcon, color: AppTheme.primaryMaroon, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppTheme.borderMaroon, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppTheme.borderMaroon, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
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
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryMaroon, AppTheme.lightMaroon],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40800020),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
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
        Expanded(child: Container(height: 1, color: AppTheme.borderMaroon)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'or continue with',
            style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.borderMaroon)),
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
                color: Color(0xFFEA4335),
              ),
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            label: 'Google',
            onTap: () {
              AppToast.show(context, message: 'Google Sign-In coming soon!');
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSocialPillButton(
            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
            label: 'Facebook',
            onTap: () {
              AppToast.show(context, message: 'Facebook Sign-In coming soon!');
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderMaroon, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
