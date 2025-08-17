import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added
import '../../api/user.api.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../location_selection_page.dart';
import 'login_page.dart';

class VerificationPage extends StatefulWidget {
  final String verificationKey;
  final String sentVia;
  final String email;
  final String phone;

  const VerificationPage({
    super.key,
    required this.verificationKey,
    required this.sentVia,
    required this.email,
    required this.phone,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    print('🔍 Verification Page initialized:');
    print('   - Verification Key: ${widget.verificationKey}');
    print('   - Sent Via: ${widget.sentVia}');
    print('   - Email: ${widget.email}');
    print('   - Phone: ${widget.phone}');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel(); // Cancel existing timer if any
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _handleVerifyCode() async {
    if (_codeController.text.trim().isEmpty) {
      _showErrorMessage('Please enter the verification code');
      return;
    }

    if (_codeController.text.trim().length != 6) {
      _showErrorMessage('Verification code must be 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Attempting verification...');
      print('   - Verification Key: ${widget.verificationKey}');
      print('   - Code: ${_codeController.text.trim()}');

      final response = await UserApi.verifyCode(
        verificationKey: widget.verificationKey,
        code: _codeController.text.trim(),
      );

      print('📱 Verification Response:');
      print('   - Success: ${response.success}');
      print('   - Message: ${response.message}');
      print('   - Data: ${response.data}');
      print('   - Error: ${response.error}');

      if (response.success && response.data != null) {
        _showSuccessMessage('Account verified successfully!');
        
        // ✅ Save user data after successful verification
        await _saveUserData(response.data!);
        
        // Navigate to location selection page
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationSelectionPage(),
            ),
            (route) => false,
          );
        }
      } else {
        _showErrorMessage(response.message);
        if (response.error != null && response.error!.isNotEmpty) {
          _showErrorMessage('Attempts left: ${response.error}');
        }
      }
    } catch (e) {
      print('❌ Verification error: $e');
      _showErrorMessage('Verification failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Added method to save user data after verification
  Future<void> _saveUserData(dynamic loginResponse) async {
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
      await prefs.setBool('user_verified', loginResponse.user.isVerified ?? true);
      
      // Save login status
      await prefs.setBool('is_logged_in', true);
      
      print('✅ User data saved after verification');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  Future<void> _handleResendCode() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      print('🔄 Attempting to resend code...');
      print('   - Verification Key: ${widget.verificationKey}');
      print('   - Method: ${widget.sentVia}');

      final response = await UserApi.resendCode(
        verificationKey: widget.verificationKey,
        method: widget.sentVia,
      );

      print('📱 Resend Response:');
      print('   - Success: ${response.success}');
      print('   - Message: ${response.message}');

      if (response.success) {
        _showSuccessMessage('Verification code sent successfully!');
        _startResendTimer();
        _codeController.clear(); // Clear the old code
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Resend error: $e');
      _showErrorMessage('Failed to resend code. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _handleChangeMethod() async {
    final newMethod = widget.sentVia == 'email' ? 'phone' : 'email';
    
    setState(() {
      _isResending = true;
    });

    try {
      print('🔄 Changing verification method to: $newMethod');
      
      final response = await UserApi.resendCode(
        verificationKey: widget.verificationKey,
        method: newMethod,
      );

      if (response.success) {
        _showSuccessMessage('Verification code sent via ${newMethod == 'email' ? 'email' : 'SMS'}!');
        _startResendTimer();
        _codeController.clear();
        
        // Update the UI to reflect the new method
        setState(() {
          // You might want to update the widget.sentVia here or create a local variable
        });
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Change method error: $e');
      _showErrorMessage('Failed to send code via ${newMethod == 'email' ? 'email' : 'SMS'}.');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'We have sent a verification code to your ${widget.sentVia == 'email' ? 'email' : 'phone number'}.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.sentVia == 'email' ? widget.email : widget.phone,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Code Input
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    letterSpacing: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                ),
                maxLength: 6,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                onChanged: (value) {
                  // Auto-submit when 6 digits are entered
                  if (value.length == 6 && !_isLoading) {
                    _handleVerifyCode();
                  }
                },
              ),

              const SizedBox(height: 40),

              // Verify Button
              CustomButton(
                text: 'Verify Account',
                onPressed: _isLoading ? null : _handleVerifyCode,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              // Resend Code
              Center(
                child: TextButton(
                  onPressed: _resendCountdown > 0 || _isResending ? null : _handleResendCode,
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : Text(
                          _resendCountdown > 0
                              ? 'Resend code in ${_resendCountdown}s'
                              : 'Resend verification code',
                          style: TextStyle(
                            color: _resendCountdown > 0 ? AppColors.textSecondary : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const Spacer(),

              // Change method link
              Center(
                child: GestureDetector(
                  onTap: _isResending ? null : _handleChangeMethod,
                  child: Text.rich(
                    TextSpan(
                      text: 'Didn\'t receive the code? Try sending via ',
                      style: const TextStyle(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: widget.sentVia == 'email' ? 'SMS' : 'Email',
                          style: TextStyle(
                            color: _isResending ? AppColors.textSecondary : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
}