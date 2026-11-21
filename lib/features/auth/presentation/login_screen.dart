import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
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
      if (email.contains('owner')) {
        role = 'owner';
      } else if (email.contains('cashier')) {
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
      backgroundColor: const Color(0xFFF4F4F6),
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
      backgroundColor: AppTheme.primaryMaroon,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: isDesktop ? 40 : 16,
      title: InkWell(
        onTap: () => context.go('/'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.outdoor_grill_rounded, size: 20, color: AppTheme.primaryMaroon),
            ),
            const SizedBox(width: 10),
            const Text(
              'Smokin Dannys BBQ & POS Portal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => context.go('/customer/home'),
          icon: const Icon(Icons.restaurant_menu_outlined, color: Colors.white70, size: 18),
          label: const Text('Menu', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        ),
        SizedBox(width: isDesktop ? 40 : 16),
      ],
    );
  }

  Widget _buildDesktopWebLayout(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderMaroon, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A800000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Hero Branding
          Expanded(
            flex: 5,
            child: Container(
              constraints: const BoxConstraints(minHeight: 560),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryMaroon, AppTheme.deepMaroon],
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
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.outdoor_grill_rounded, size: 36, color: Colors.white),
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
                      color: Colors.white70,
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
                          ? _buildLoginForm(isLoading, isDesktop: true)
                          : _buildSignupForm(isLoading, isDesktop: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCheck(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabletLayout(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderMaroon, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F800000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildMobileHeaderLogo(),
            const SizedBox(height: 24),
            _buildSegmentedTabBar(),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedTab == 0
                  ? _buildLoginForm(isLoading, isDesktop: false)
                  : _buildSignupForm(isLoading, isDesktop: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeaderLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.primaryMaroon, AppTheme.deepMaroon],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: const Center(
            child: Icon(Icons.outdoor_grill_rounded, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Smokin Dannys',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryMaroon,
          ),
        ),
        const Text(
          'BBQ & POS PORTAL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppTheme.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabBar() {
    return Container(
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
    );
  }

  Widget _buildLoginForm(bool isLoading, {bool isDesktop = false}) {
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
              color: AppTheme.primaryMaroon,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset link sent if registered.')),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildSignupForm(bool isLoading, {bool isDesktop = false}) {
    // Name Input Formatter: Disallow numbers/digits
    final nameFormatter = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
    
    // Phone Input Formatter: Disallow letters
    final phoneFormatter = [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))];

    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          // 3-Column Layout on Desktop Web for Name Fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Middle Name (Optional)'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _signupMiddleNameController,
                      hintText: 'Cruz',
                      prefixIcon: Icons.person_outline,
                      inputFormatters: nameFormatter,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && RegExp(r'[0-9]').hasMatch(value)) {
                          return 'No numbers allowed';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Surname *'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _signupSurnameController,
                      hintText: 'Johnson',
                      prefixIcon: Icons.person_outline,
                      inputFormatters: nameFormatter,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2-Column Row for Email & Phone on Desktop
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        if (RegExp(r'[a-zA-Z]').hasMatch(value)) return 'No letters allowed';
                        if (value.length < 10) return 'Invalid phone number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2-Column Row for Passwords on Desktop (8 chars, 1 uppercase, 1 number)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Password required';
                        if (value.length < 8) return 'Min 8 characters required';
                        if (!value.contains(RegExp(r'[A-Z]'))) return 'Must have 1 uppercase (A-Z)';
                        if (!value.contains(RegExp(r'[0-9]'))) return 'Must have 1 number (0-9)';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Confirm password';
                        if (value != _signupPasswordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Mobile Stack Layout
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Middle Name (Optional)'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _signupMiddleNameController,
                      hintText: 'Cruz',
                      prefixIcon: Icons.person_outline,
                      inputFormatters: nameFormatter,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && RegExp(r'[0-9]').hasMatch(value)) {
                          return 'No numbers allowed';
                        }
                        return null;
                      },
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Surname required';
              if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed';
              return null;
            },
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
              if (RegExp(r'[a-zA-Z]').hasMatch(value)) return 'No letters allowed';
              if (value.length < 10) return 'Invalid phone number';
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
              if (value.length < 8) return 'Min 8 characters required';
              if (!value.contains(RegExp(r'[A-Z]'))) return 'Must have 1 uppercase (A-Z)';
              if (!value.contains(RegExp(r'[0-9]'))) return 'Must have 1 number (0-9)';
              return null;
            },
          ),
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
        ],

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
            color: Color(0x40800000),
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
                maxLines: 1,
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
