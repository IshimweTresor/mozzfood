// filepath: [otp_verification_page.dart](http://_vscodecontentref_/1)
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../api/user.api.dart';
import 'set_new_password_page.dart';

class OTPVerificationPage extends StatefulWidget {
  final String contact;
  final String resetKey;
  const OTPVerificationPage({super.key, required this.contact, required this.resetKey});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 6-digit code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final response = await UserApi.verifyResetCode(
      resetKey: widget.resetKey,
      code: _otpController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.success && response.data != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SetNewPasswordPage(
            contact: widget.contact,
            resetKey: widget.resetKey,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Text(
                'Enter the code sent to ${widget.contact}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                hintText: 'Enter 6-digit code',
                controller: _otpController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.length != 6 ? 'Enter 6 digits' : null,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Verify',
                onPressed: _verifyOTP,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}