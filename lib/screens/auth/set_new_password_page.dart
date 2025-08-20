// filepath: [set_new_password_page.dart](http://_vscodecontentref_/2)
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../api/user.api.dart';

class SetNewPasswordPage extends StatefulWidget {
  final String contact;
  final String resetKey;
  const SetNewPasswordPage({super.key, required this.contact, required this.resetKey});

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await UserApi.resetPassword(
        resetKey: widget.resetKey,
        newPassword: _passwordController.text,
        confirmPassword: _confirmController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successful!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                const Text(
                  'Set New Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'New Password',
                  hintText: 'Enter new password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) =>
                      value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter new password',
                  controller: _confirmController,
                  isPassword: true,
                  validator: (value) =>
                      value != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Set Password',
                  onPressed: _setPassword,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}