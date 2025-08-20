// filepath: [forgot_password_page.dart](http://_vscodecontentref_/0)
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../api/user.api.dart'; // <-- Import your API
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  bool _isLoading = false;
  String? _resetKey; // Store resetKey for next step

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter email or phone number';
    }
    final trimmed = value.trim();
    final isPhone = trimmed.startsWith('+250') && trimmed.length == 13;
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed);
    if (!isPhone && !isEmail) {
      return 'Enter a valid phone number (+250...) or email';
    }
    return null;
  }

  Future<void> _handleSendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await UserApi.forgotPassword(
        identifier: _contactController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success && response.data != null) {
        _resetKey = response.data!.resetKey;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              contact: _contactController.text.trim(),
              resetKey: _resetKey!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
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
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Enter your phone number or email to reset your password',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Phone Number or Email',
                  hintText: 'Enter phone number (+250...) or email',
                  controller: _contactController,
                  validator: _validateContact,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Send OTP',
                  onPressed: _handleSendOTP,
                  isLoading: _isLoading,
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