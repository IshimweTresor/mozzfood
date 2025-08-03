import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
        title: const Text(
          'About Us',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Contact Us
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Contact Us',
              onTap: () => _showContactInfo(context),
            ),
            const SizedBox(height: 16),

            // Privacy & Data Protection Policy
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Privacy & Data Protection Policy',
              onTap: () => _showPrivacyPolicy(context),
            ),
            const SizedBox(height: 16),

            // Terms & Conditions
            _buildMenuItem(
              icon: Icons.gavel_outlined,
              title: 'Terms & Conditions',
              onTap: () => _showTermsAndConditions(context),
            ),
            const SizedBox(height: 32),

            // Version
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Version',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ),
                  Text(
                    '2.0.12(87)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onBackground,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Contact Us',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email: support@pegaja.com',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  'Phone: +250 788 000 000',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  'Address: Kigali, Rwanda',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Privacy Policy',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'Your privacy is important to us. This policy outlines how we collect, use, and protect your personal information.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Terms & Conditions',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'By using our app, you agree to our terms and conditions of service.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
