import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/user.api.dart';
import '../../response/auth_responses.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../location_selection_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart'; // ✅ Keep this import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // Changed from email to identifier
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number or email is required';
    }
    
    // Basic validation for email or phone
    if (value.contains('@')) {
      // Email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    } else {
      // Phone validation (basic)
      if (value.length < 9 || !RegExp(r'^[+]?[0-9]+$').hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

Future<void> _saveUserData(LoginResponse loginResponse) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Save user token
    await prefs.setString('auth_token', loginResponse.token);
    
    // Save user data
    await prefs.setString('user_id', loginResponse.user.id ?? '');
    await prefs.setString('user_name', loginResponse.user.name);
    await prefs.setString('user_email', loginResponse.user.email);
    await prefs.setString('user_phone', loginResponse.user.phone);
    await prefs.setString('user_role', loginResponse.user.role);
    await prefs.setBool('user_verified', loginResponse.user.isVerified ?? false);
    
    // Save login status
    await prefs.setBool('is_logged_in', true);
    
    print('✅ User data saved successfully');
  } catch (e) {
    print('❌ Error saving user data: $e');
  }
}

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

// ...existing code...
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    print('🔄 Attempting login...');
    print('📧 Identifier: ${_identifierController.text.trim()}');
    
    final response = await UserApi.loginUser(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text.trim(),
    );

    print('📱 API Response: ${response.success}');
    print('📱 Message: ${response.message}');
    
    if (response.success && response.data != null) {
      print('🔍 User Data Debug:');
      print('   - User ID: ${response.data!.user.id}');
      print('   - User Name: ${response.data!.user.name}');
      print('   - User Email: ${response.data!.user.email}');
      print('   - User Phone: ${response.data!.user.phone}');
      print('   - User Role: ${response.data!.user.role}');
      print('   - Is Verified: ${response.data!.user.isVerified}');
      print('   - Token: ${response.data!.token.substring(0, 20)}...');

      // Login successful
      print('✅ Login successful!');
      
      // Save user data locally
      await _saveUserData(response.data!);
      
      // Show success message
      _showSuccessSnackBar(response.message);
      
      // Check if user is verified - Handle nullable field
      final isVerified = response.data!.user.isVerified ?? false; // ✅ Handle null case
      print('🔍 Verification Check: $isVerified');
      
      if (!isVerified) {
        print('❌ User is NOT verified - showing dialog');
        _showErrorDialog(
          'Account Not Verified',
          'Please verify your account first. Check your email or SMS for the verification code.',
        );
        return;
      }
      
      print('✅ User IS verified - proceeding to main app');
      // Navigate to location selection page or main app
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LocationSelectionPage(),
          ),
        );
      }
    } else {
      // Login failed
      print('❌ Login failed: ${response.message}');
      _showErrorDialog('Login Failed', response.message);
    }
  } catch (e) {
    print('❌ Login error: $e');
    _showErrorDialog(
      'Network Error',
      'Unable to connect to the server. Please check your internet connection and try again.',
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Illustration
                Center(
                  child: Container(
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Background illustration elements
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            width: 40,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 30,
                          right: 30,
                          child: Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        // Main characters
                        Positioned(
                          bottom: 40,
                          left: 40,
                          child: Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          right: 40,
                          child: Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Please sign in first to enjoy our services',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // Phone Number/Email Field
                CustomTextField(
                  label: 'Phone Number/Email',
                  hintText: 'Enter your phone number or email',
                  controller: _identifierController,
                  validator: _validateEmailOrPhone,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  isPassword: true,
                  controller: _passwordController,
                  validator: _validatePassword,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 16),

                // Forgot Password - ✅ Keep the working version from main
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password ?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Sign In Button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),

                if (_isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Signing you in...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New Customer? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up now',
                        style: TextStyle(
                          color: _isLoading ? AppColors.textSecondary : AppColors.primary,
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