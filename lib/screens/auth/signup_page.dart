import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCountry = 'Select country';
  String _selectedCountryCode = '+250';
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the terms and conditions'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
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
                        height: 12,
                        color: AppColors.ukraineBlue,
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 12,
                          color: AppColors.ukraineYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                title: const Text(
                  'Ukraine (+380)',
                  style: TextStyle(color: AppColors.onBackground),
                ),
                onTap: () {
                  setState(() {
                    _selectedCountry = 'Ukraine';
                    _selectedCountryCode = '+380';
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
                      Container(
                        width: 32,
                        height: 8,
                        color: const Color(0xFF00A1DE), // Rwanda blue
                      ),
                      Positioned(
                        top: 8,
                        child: Container(
                          width: 32,
                          height: 8,
                          color: const Color(0xFFFAD201), // Rwanda yellow
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 8,
                          color: const Color(0xFF00A651), // Rwanda green
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
            ],
          ),
        );
      },
    );
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
                // Illustration
                Center(
                  child: Container(
                    height: 180,
                    width: 200,
                    child: Stack(
                      children: [
                        // Delivery person illustration
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
                        // Delivery bag
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
                            child:
                                _selectedCountry == 'Rwanda'
                                    ? Stack(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 5,
                                          color: const Color(
                                            0xFF00A1DE,
                                          ), // Rwanda blue
                                        ),
                                        Positioned(
                                          top: 5,
                                          child: Container(
                                            width: 20,
                                            height: 5,
                                            color: const Color(
                                              0xFFFAD201,
                                            ), // Rwanda yellow
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: 20,
                                            height: 5,
                                            color: const Color(
                                              0xFF00A651,
                                            ), // Rwanda green
                                          ),
                                        ),
                                      ],
                                    )
                                    : Stack(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 7.5,
                                          color: AppColors.ukraineBlue,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: 20,
                                            height: 7.5,
                                            color: AppColors.ukraineYellow,
                                          ),
                                        ),
                                      ],
                                    ),
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
