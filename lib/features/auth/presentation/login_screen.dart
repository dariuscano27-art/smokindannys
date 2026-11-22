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

  bool _obscureLoginPassword = true;
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
        _passwordStrengthColor = Colors.orange;
      });
    } else if (pwd.length >= 10 && hasUppercase && hasDigits && hasSpecialCharacters) {
      setState(() {
        _passwordStrength = 'Strong Password';
        _passwordStrengthColor = Colors.green;
      });
    } else {
      setState(() {
        _passwordStrength = 'Good Password';
        _passwordStrengthColor = Colors.orange;
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
      final authRepo = ref.read(authRepositoryProvider);
      final user = authRepo.currentUser;
      if (!mounted) return;

      String role = 'customer';
      final email = _loginEmailController.text.trim().toLowerCase();
      if (email.contains('owner') || email.contains('admin')) {
        role = 'owner';
      } else if (email.contains('cashier') || email.contains('staff')) {
        role = 'cashier';
      } else if (user != null) {
        role = await authRepo.getUserRole(user.id);
      }

      if (!mounted) return;

      if (role == 'owner') {
        context.go('/owner/dashboard');
      } else if (role == 'cashier') {
        context.go('/cashier/pos');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please log in.'),
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

  void _fillStaffDemo() {
    setState(() {
      _selectedTab = 0;
      _loginEmailController.text = 'staff@smokindannys.com';
      _loginPasswordController.text = 'Password123';
    });
  }

  void _fillAdminDemo() {
    setState(() {
      _selectedTab = 0;
      _loginEmailController.text = 'admin@smokindannys.com';
      _loginPasswordController.text = 'Password123';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderMaroon, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14800000),
                      blurRadius: 20,
                      offset: Offset(0, 6),
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
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33800000),
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
                        'BBQ & POS MANAGEMENT SYSTEM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppTheme.mutedText,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Segmented Tab Bar (Log In / Register)
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.softMaroon,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.borderMaroon),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: _selectedTab == 0 ? AppTheme.primaryMaroon : Colors.transparent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _selectedTab == 0 ? Colors.white : AppTheme.primaryMaroon,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: _selectedTab == 1 ? AppTheme.primaryMaroon : Colors.transparent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _selectedTab == 1 ? Colors.white : AppTheme.primaryMaroon,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Email Address', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          maxLength: 50,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'admin@smokindannys.com or customer...',
            hintStyle: const TextStyle(color: Color(0xFFA0989A), fontSize: 12),
            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryMaroon, size: 18),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter your email';
            if (!value.contains('@') || !value.contains('.')) return 'Invalid email address';
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text('Password', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          maxLength: 30,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Color(0xFFA0989A), fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryMaroon, size: 18),
            suffixIcon: IconButton(
              icon: Icon(_obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.primaryMaroon, size: 18),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8)),
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
                const Text('Remember me', style: TextStyle(color: AppTheme.darkText, fontSize: 12)),
              ],
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent.')));
              },
              child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.lightMaroon]),
            boxShadow: const [BoxShadow(color: Color(0x40800000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            child: isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _fillAdminDemo,
                icon: const Icon(Icons.admin_panel_settings, size: 14, color: AppTheme.primaryMaroon),
                label: const Text('Admin Demo', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primaryMaroon), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _fillStaffDemo,
                icon: const Icon(Icons.point_of_sale, size: 14, color: AppTheme.primaryMaroon),
                label: const Text('Staff POS', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primaryMaroon), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignupForm(bool isLoading) {
    final nameFormatter = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
    final phoneFormatter = [FilteringTextInputFormatter.digitsOnly]; // numbers only

    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('First Name * (Max 50 chars)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _signupFirstNameController,
          maxLength: 50,
          inputFormatters: nameFormatter,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: _inputDec('David', Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'First name is required';
            if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed in name';
            return null;
          },
        ),
        const SizedBox(height: 12),
        const Text('Middle Name (Optional, Max 50 chars)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _signupMiddleNameController,
          maxLength: 50,
          inputFormatters: nameFormatter,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: _inputDec('Cruz', Icons.person_outline),
          validator: (value) {
            if (value != null && value.isNotEmpty && RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed';
            return null;
          },
        ),
        const SizedBox(height: 12),
        const Text('Surname * (Max 50 chars)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _signupSurnameController,
          maxLength: 50,
          inputFormatters: nameFormatter,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: _inputDec('Johnson', Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Surname is required';
            if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed in surname';
            return null;
          },
        ),
        const SizedBox(height: 12),
        const Text('Email Address * (Max 50 chars)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _signupEmailController,
          keyboardType: TextInputType.emailAddress,
          maxLength: 50,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: _inputDec('name@example.com', Icons.email_outlined),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Email is required';
            if (!value.contains('@') || !value.contains('.')) return 'Invalid email format';
            return null;
          },
        ),
        const SizedBox(height: 12),
        const Text('Contact Number * (11 digits only)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _signupPhoneController,
          keyboardType: TextInputType.number,
          maxLength: 11,
          inputFormatters: phoneFormatter,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: _inputDec('09123456789', Icons.phone_outlined),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Contact number is required';
            if (value.length != 11) return 'Must be exactly 11 digits (e.g. 09123456789)';
            if (!value.startsWith('09')) return 'Must start with 09';
            return null;
          },
        ),
        const SizedBox(height: 12),
        const Text('Password * (Min 8, Max 30 chars)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _signupPasswordController,
          obscureText: _obscureSignupPassword,
          maxLength: 30,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Color(0xFFA0989A), fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryMaroon, size: 18),
            suffixIcon: IconButton(
              icon: Icon(_obscureSignupPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.primaryMaroon, size: 18),
              onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
            ),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Password is required';
            if (value.length < 8) return 'Minimum 8 characters required';
            return null;
          },
        ),
        const SizedBox(height: 4),
        // Password Strength Meter Badge
        if (_passwordStrength.isNotEmpty)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _passwordStrengthColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _passwordStrengthColor),
                ),
                child: Text(
                  _passwordStrength,
                  style: TextStyle(color: _passwordStrengthColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        const Text('Confirm Password * (Max 30 chars)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _signupConfirmPasswordController,
          obscureText: _obscureConfirmPassword,
          maxLength: 30,
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Color(0xFFA0989A), fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryMaroon, size: 18),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.primaryMaroon, size: 18),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please confirm your password';
            if (value != _signupPasswordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 12),
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
            const Expanded(
              child: Text('I agree to Terms & Conditions and Privacy Policy', style: TextStyle(color: AppTheme.darkText, fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [AppTheme.primaryMaroon, AppTheme.lightMaroon]),
            boxShadow: const [BoxShadow(color: Color(0x40800000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSignup,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            child: isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Register Account', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      counterText: '',
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA0989A), fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.primaryMaroon, size: 18),
      filled: true,
      fillColor: AppTheme.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8)),
    );
  }
}
