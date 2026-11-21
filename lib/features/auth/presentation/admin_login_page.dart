import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AdminLoginPage extends StatefulWidget {
  final Future<bool> Function(String username, String password, bool rememberMe) onLogin;

  const AdminLoginPage({
    super.key,
    required this.onLogin,
  });

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isHovered = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your username and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onLogin(
        _usernameController.text.trim(),
        _passwordController.text,
        _rememberMe,
      );

      if (!mounted) return;

      if (!success) {
        setState(() {
          _errorMessage = 'Invalid username or password.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to sign in. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.mutedText),
      prefixIcon: Icon(icon, color: AppTheme.primaryMaroon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderMaroon),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderMaroon),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryMaroon,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33800000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SMOKIN DANNYS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryMaroon,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'BBQ & POS MANAGEMENT SYSTEM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderMaroon,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F800000),
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Staff / Owner Portal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to access cashier POS & owner dashboard.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Username or Email
                        const Text(
                          'Username or Email',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: AppTheme.darkText),
                          decoration: _inputDecoration(
                            hint: 'Enter your username or email',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppTheme.darkText),
                          decoration: _inputDecoration(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.mutedText,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Remember Me
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                color: AppTheme.darkText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.softMaroon,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        MouseRegion(
                          onEnter: (_) => setState(() => _isHovered = true),
                          onExit: (_) => setState(() => _isHovered = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: _isHovered && !_isLoading
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x40800000),
                                        blurRadius: 15,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryMaroon,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppTheme.deepMaroon,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'SIGN IN TO PORTAL',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text(
                      '← Back to Home / Customer Menu',
                      style: TextStyle(color: AppTheme.mutedText, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
