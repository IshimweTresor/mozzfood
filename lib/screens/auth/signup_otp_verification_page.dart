import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import 'login_page.dart';
import '../../api/user.api.dart';

class SignupOtpVerificationPage extends StatefulWidget {
  final String email;
  final String phoneNumber;

  const SignupOtpVerificationPage({
    super.key,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<SignupOtpVerificationPage> createState() =>
      _SignupOtpVerificationPageState();
}

class _SignupOtpVerificationPageState extends State<SignupOtpVerificationPage> {
  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      print('🔄 Resending OTP to: ${widget.email}');

      // Call backend resend OTP API
      final response = await UserApi.resendCode(
        verificationKey: widget.email.trim(), // using email as verificationKey
        method: 'email', // or 'phone' if you want to support phone
      );

      if (response.success) {
        _showSuccessMessage(response.message);
        _clearOtp();
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Resend OTP Error: $e');
      _showErrorMessage('Failed to resend OTP. Please try again.');
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  bool _isOtpComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _clearOtp() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  Future<void> _verifyOtp() async {
    if (widget.email.trim().isEmpty) {
      _showErrorMessage(
        'Email cannot be empty. Please go back and enter your email.',
      );
      return;
    }
    if (!_isOtpComplete()) {
      _showErrorMessage('Please enter the complete OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final otpCode = _getOtpCode();
      final email = widget.email.trim();
      print('🔐 Verifying OTP: $otpCode');
      print('📧 Email: $email');

      final response = await UserApi.verifyCode(
        verificationKey: email,
        code: otpCode,
      );

      print('🔎 OTP Verification API Response:');
      print('   - Success: ${response.success}');
      print('   - Message: ${response.message}');
      print('   - Error: ${response.error}');
      if (response.data != null) print('   - Data: ${response.data}');

      if (response.success) {
        _showSuccessMessage(response.message);
        // Wait a moment so user sees the success message
        await Future.delayed(const Duration(seconds: 1));
        // Navigate to login page
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        String errorMsg = response.message;
        if (response.error != null) {
          errorMsg += '\nError: ${response.error}';
        }
        _showErrorMessage(errorMsg);
        _clearOtp();
      }
    } catch (e) {
      print('❌ OTP Verification Error: $e');
      _showErrorMessage(
        'Verification failed. Please try again.\nError: ${e.toString()}',
      );
      _clearOtp();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(
          color:
              _otpControllers[index].text.isNotEmpty
                  ? AppColors.primary
                  : Colors.grey.shade700,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade900,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.message_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Please check OTP sent to you via sms or whatsapp ',
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' or email to '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "If you don't receive the OTP email in your inbox, please remember to check your spam folder.",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),

              const SizedBox(height: 40),

              // Verify Button
              CustomButton(
                text: _isLoading ? 'Verifying...' : 'Verify',
                onPressed: _isLoading || !_isOtpComplete() ? null : _verifyOtp,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 30),

              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the verification OTP?  ",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _isResending ? null : () => _resendOtp(),
                    child: Text(
                      _isResending ? 'Resending...' : 'Resend Code',
                      style: TextStyle(
                        color:
                            _isResending ? Colors.white38 : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
