import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
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
    if (!value.startsWith('+250') || value.length < 13) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleSendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully to your phone and email'),
            backgroundColor: AppColors.success,
          ),
        );

        // TODO: Navigate to OTP verification page
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const OTPVerificationPage(),
        //   ),
        // );
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

                // Back Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.inputBorder.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.onBackground,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Illustration
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background decorative elements
                        Positioned(
                          top: 30,
                          left: 40,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          right: 30,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 20,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 60,
                          right: 40,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Squiggly lines
                        Positioned(
                          top: 20,
                          left: 60,
                          child: CustomPaint(
                            size: const Size(30, 10),
                            painter: SquigglyLinePainter(),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          right: 60,
                          child: CustomPaint(
                            size: const Size(25, 8),
                            painter: SquigglyLinePainter(),
                          ),
                        ),
                        // Main truck illustration
                        Container(
                          width: 100,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              // Truck cab
                              Positioned(
                                left: 0,
                                top: 10,
                                child: Container(
                                  width: 30,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade600,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              // Truck body
                              Positioned(
                                left: 25,
                                top: 5,
                                child: Container(
                                  width: 70,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.local_shipping,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              // Wheels
                              Positioned(
                                bottom: -5,
                                left: 10,
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -5,
                                right: 15,
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Title
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

                // Subtitle
                const Center(
                  child: Text(
                    'In order to reset your password, please provide\nyour phone number and email',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Phone Number Field
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Phone number',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.blue,
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(2),
                                      topRight: Radius.circular(2),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(2),
                                      bottomRight: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '+250',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.inputBorder.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.inputBorder.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Email Field
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.inputBorder.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.inputBorder.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Send OTP Button
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

// Custom painter for squiggly lines
class SquigglyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (int i = 0; i < size.width; i += 5) {
      if (i % 10 == 0) {
        path.lineTo(i.toDouble(), 0);
      } else {
        path.lineTo(i.toDouble(), size.height);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
