import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_provider.dart';

void showCustomerProfileModal(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => const _CustomerProfileDialog(),
  );
}

void showSignOutConfirmationDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: AppTheme.primaryMaroon, size: 22),
          SizedBox(width: 10),
          Text(
            'SIGN OUT CONFIRMATION',
            style: TextStyle(
              color: AppTheme.primaryMaroon,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to sign out from your Smokin Dannys account?',
        style: TextStyle(color: AppTheme.darkText, fontSize: 13, height: 1.4),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.darkText,
            side: const BorderSide(color: AppTheme.borderMaroon),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // close dialog
            await ref.read(authControllerProvider.notifier).signOut();
            if (context.mounted) {
              AppToast.show(context, message: 'Signed out successfully.');
              context.go('/');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryMaroon,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Yes, Sign Out'),
        ),
      ],
    ),
  );
}

class _CustomerProfileDialog extends ConsumerStatefulWidget {
  const _CustomerProfileDialog();

  @override
  ConsumerState<_CustomerProfileDialog> createState() => _CustomerProfileDialogState();
}

class _CustomerProfileDialogState extends ConsumerState<_CustomerProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;
  String _avatarInitials = 'DJ';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? 'David Cruz Johnson';

    final parts = fullName.trim().split(' ');
    String first = 'David';
    String middle = 'Cruz';
    String last = 'Johnson';

    if (parts.length == 1) {
      first = parts[0];
      middle = '';
      last = '';
    } else if (parts.length == 2) {
      first = parts[0];
      middle = '';
      last = parts[1];
    } else if (parts.length >= 3) {
      first = parts[0];
      middle = parts.sublist(1, parts.length - 1).join(' ');
      last = parts.last;
    }

    _firstNameController = TextEditingController(text: first);
    _middleNameController = TextEditingController(text: middle);
    _surnameController = TextEditingController(text: last);
    _emailController = TextEditingController(text: user?.email ?? 'customer@smokindannys.com');
    _phoneController = TextEditingController(text: user?.userMetadata?['phone'] ?? '09123456789');
    _addressController = TextEditingController(text: '123 Main St, Quezon City');

    _updateInitials(first, last);
  }

  void _updateInitials(String first, String surname) {
    if (first.isNotEmpty && surname.isNotEmpty) {
      _avatarInitials = '${first[0]}${surname[0]}'.toUpperCase();
    } else if (first.isNotEmpty) {
      _avatarInitials = first[0].toUpperCase();
    } else {
      _avatarInitials = 'SD';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameFormatter = [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
    final phoneFormatter = [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))];

    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 660),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_pin_rounded, color: AppTheme.primaryMaroon, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'CUSTOMER PROFILE',
                            style: TextStyle(
                              color: AppTheme.primaryMaroon,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.mutedText),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar Badge
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryMaroon,
                      border: Border.all(color: AppTheme.champagneGold, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22800020),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _avatarInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // VIP Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.softMaroon,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.champagneGold),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: AppTheme.champagneGold, size: 15),
                        SizedBox(width: 6),
                        Text(
                          'SMOKIN VIP MEMBER',
                          style: TextStyle(
                            color: AppTheme.primaryMaroon,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // First Name & Middle Name Fields
                  Row(
                    children: [
                      Expanded(
                        child: _profileField(
                          label: 'First Name *',
                          controller: _firstNameController,
                          icon: Icons.person_outline_rounded,
                          isEditing: _isEditing,
                          inputFormatters: nameFormatter,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'First name required';
                            if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _profileField(
                          label: 'Middle Name (Opt)',
                          controller: _middleNameController,
                          icon: Icons.person_outline_rounded,
                          isEditing: _isEditing,
                          inputFormatters: nameFormatter,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Surname Field
                  _profileField(
                    label: 'Surname *',
                    controller: _surnameController,
                    icon: Icons.person_outline_rounded,
                    isEditing: _isEditing,
                    inputFormatters: nameFormatter,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Surname required';
                      if (RegExp(r'[0-9]').hasMatch(value)) return 'No numbers allowed';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Email Field (read only)
                  _profileField(
                    label: 'Email Address',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    isEditing: false, // Email is read-only
                  ),
                  const SizedBox(height: 10),

                  // Phone Number Field
                  _profileField(
                    label: 'Phone Number *',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    isEditing: _isEditing,
                    inputFormatters: phoneFormatter,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Phone number required';
                      if (RegExp(r'[a-zA-Z]').hasMatch(value)) return 'No letters allowed';
                      if (value.length < 10) return 'Invalid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Saved Address Field
                  _profileField(
                    label: 'Saved Address *',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                    isEditing: _isEditing,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Address cannot be empty';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Save / Edit Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_isEditing) {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() {
                            _updateInitials(_firstNameController.text, _surnameController.text);
                            _isEditing = false;
                          });
                          AppToast.show(context, message: 'Profile details saved successfully!');
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                      icon: Icon(_isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded, size: 20),
                      label: Text(_isEditing ? 'SAVE PROFILE CHANGES' : 'EDIT PROFILE DETAILS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing ? Colors.green : AppTheme.primaryMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        elevation: 2,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.mutedText, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: isEditing,
          inputFormatters: inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(
            color: isEditing ? AppTheme.darkText : AppTheme.darkText.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryMaroon, size: 18),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            filled: true,
            fillColor: isEditing ? Colors.white : AppTheme.softMaroon,
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderMaroon),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.8),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
