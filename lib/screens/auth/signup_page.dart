import 'package:flutter/material.dart';
import '../../api/user.api.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'signup_otp_verification_page.dart'; // ✅ Import the new OTP page

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // ✅ Added name field
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // ✅ Added password field
  final _confirmPasswordController =
      TextEditingController(); // ✅ Added confirm password

  String _selectedCountry = 'Rwanda'; // ✅ Default to Rwanda
  String _selectedCountryCode = '+250';
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';

    // Remove any spaces or special characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Both Rwanda and Mozambique use 9-digit local numbers in this app
    if ((_selectedCountry == 'Rwanda' || _selectedCountry == 'Mozambique') &&
        cleanPhone.length != 9) {
      return 'Phone number must be 9 digits for ${_selectedCountry}';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    // Allow common valid emails. Ensure the pattern ends with $ (end anchor)
    if (!RegExp(
      r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$',
      caseSensitive: false,
    ).hasMatch(value)) {
      // Fallback simpler check if the regex fails (defensive)
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String _formatPhoneNumber(String phone) {
    // Remove any existing country code and formatting
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Remove country code if it exists
    if (_selectedCountry == 'Rwanda' && cleanPhone.startsWith('250')) {
      cleanPhone = cleanPhone.substring(3);
    } else if (_selectedCountry == 'Mozambique' &&
        cleanPhone.startsWith('258')) {
      cleanPhone = cleanPhone.substring(3);
    }

    // Add the country code
    return '${_selectedCountryCode.replaceAll('+', '')}$cleanPhone';
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 32,
                        height: 8,
                        color: AppColors.rwandaBlue,
                      ),
                      Positioned(
                        top: 8,
                        child: Container(
                          width: 32,
                          height: 8,
                          color: AppColors.rwandaYellow,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 8,
                          color: AppColors.rwandaGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                title: const Text(
                  'Rwanda (+250)',
                  style: TextStyle(color: AppColors.onBackground),
                ),
                onTap: () {
                  setState(() {
                    _selectedCountry = 'Rwanda';
                    _selectedCountryCode = '+250';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // Red triangle on the left
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 12,
                          height: 24,
                          color: AppColors.mozambiqueRed,
                        ),
                      ),
                      // Main horizontal stripes
                      Positioned(
                        left: 12,
                        child: Column(
                          children: [
                            Container(
                              width: 20,
                              height: 6,
                              color: AppColors.mozambiqueGreen,
                            ),
                            Container(
                              width: 20,
                              height: 6,
                              color: AppColors.mozambiqueBlack,
                            ),
                            Container(
                              width: 20,
                              height: 6,
                              color: AppColors.mozambiqueYellow,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                title: const Text(
                  'Mozambique (+258)',
                  style: TextStyle(color: AppColors.onBackground),
                ),
                onTap: () {
                  setState(() {
                    _selectedCountry = 'Mozambique';
                    _selectedCountryCode = '+258';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // _showSuccessMessage and _showCountryPicker already defined above.
  // Next: sign-up handler
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showErrorMessage('Please agree to the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());

      final response = await UserApi.registerUser(
        fullName: _nameController.text.trim(),
        location: _selectedCountry,
        phoneNumber: formattedPhone,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        roles: 'CUSTOMER',
      );

      if (response.success && response.data != null) {
        _showSuccessMessage(response.message);
        if (response.data!.requiresVerification) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SignupOtpVerificationPage(
                  email: _emailController.text.trim(),
                  phoneNumber: formattedPhone,
                ),
              ),
            );
          }
        } else {
          if (mounted) Navigator.pop(context);
        }
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      _showErrorMessage('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration (keep your existing illustration code)
                Center(
                  child: SizedBox(
                    height: 180,
                    width: 200,
                    child: Stack(
                      children: [
                        // Your existing illustration code
                        Positioned(
                          bottom: 20,
                          left: 50,
                          child: Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                const Positioned(
                                  top: 20,
                                  left: 35,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'vuba',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 20,
                          child: Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Please sign up first to enjoy our services',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Name Field ✅ Added
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: _nameController,
                  validator: _validateName,
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 24),

                // Country Selection
                CustomTextField(
                  hintText: _selectedCountry,
                  controller: TextEditingController(),
                  readOnly: true,
                  onTap: _showCountryPicker,
                  prefix: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Phone Number Field
                CustomTextField(
                  label: 'Phone Number',
                  hintText: 'Enter Phone number',
                  controller: _phoneController,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  prefix: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: _selectedCountry == 'Rwanda'
                                ? Stack(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 5,
                                        color: const Color(0xFF00A1DE),
                                      ),
                                      Positioned(
                                        top: 5,
                                        child: Container(
                                          width: 20,
                                          height: 5,
                                          color: const Color(0xFFFAD201),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          width: 20,
                                          height: 5,
                                          color: const Color(0xFF00A651),
                                        ),
                                      ),
                                    ],
                                  )
                                : (_selectedCountry == 'Mozambique'
                                      ? Stack(
                                          children: [
                                            // small red stripe on left
                                            Positioned(
                                              left: 0,
                                              child: Container(
                                                width: 6,
                                                height: 15,
                                                color: AppColors.mozambiqueRed,
                                              ),
                                            ),
                                            Positioned(
                                              left: 6,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 14,
                                                    height: 5,
                                                    color: AppColors
                                                        .mozambiqueGreen,
                                                  ),
                                                  Container(
                                                    width: 14,
                                                    height: 5,
                                                    color: AppColors
                                                        .mozambiqueBlack,
                                                  ),
                                                  Container(
                                                    width: 14,
                                                    height: 5,
                                                    color: AppColors
                                                        .mozambiqueYellow,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : // fallback to Rwanda colors
                                        Stack(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 5,
                                              color: AppColors.rwandaBlue,
                                            ),
                                            Positioned(
                                              top: 5,
                                              child: Container(
                                                width: 20,
                                                height: 5,
                                                color: AppColors.rwandaYellow,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              child: Container(
                                                width: 20,
                                                height: 5,
                                                color: AppColors.rwandaGreen,
                                              ),
                                            ),
                                          ],
                                        )),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCountryCode,
                            style: const TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 1,
                            height: 16,
                            color: AppColors.inputBorder,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                // Password Field ✅ Added
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  isPassword: true,
                  controller: _passwordController,
                  validator: _validatePassword,
                ),

                const SizedBox(height: 24),

                // Confirm Password Field ✅ Added
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Confirm your password',
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                ),

                const SizedBox(height: 24),

                // Terms and Conditions Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      side: const BorderSide(color: AppColors.inputBorder),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToTerms = !_agreeToTerms;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text.rich(
                            TextSpan(
                              text: 'Yes, I have read and agreed to the ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & conditions',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and to the '),
                                TextSpan(
                                  text: 'Privacy & Data Protection Policy',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                CustomButton(
                  text: 'Sign Up',
                  onPressed: _agreeToTerms ? _handleSignUp : null,
                  isLoading: _isLoading,
                  isEnabled: _agreeToTerms,
                ),

                const SizedBox(height: 40),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account ? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
