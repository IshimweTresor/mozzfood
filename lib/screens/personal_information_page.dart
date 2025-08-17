import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  String _selectedTab = 'Details'; // 'Details', 'Edit Details', 'Security'

  // Controllers for Edit Details
  final TextEditingController _firstNameController = TextEditingController(
    text: 'ISHIMWE',
  );
  final TextEditingController _lastNameController = TextEditingController(
    text: 'TRESOR',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '250784107365',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'ishimwet15@gmail.com',
  );
  final TextEditingController _passwordController = TextEditingController();

  // Controllers for Security
  final TextEditingController _recentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _recentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateAccount() {
    // Validate form
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement account update logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _changePassword() {
    // Validate password fields
    if (_recentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all password fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirm password do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement password change logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear the password fields
    _recentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
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
        title: const Text(
          'Personal information',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4A90E2),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // User Name
                const Text(
                  'ISHIMWE TRESOR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
          ),

          // Tab Navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildTab('Details')),
                Expanded(child: _buildTab('Edit Details')),
                Expanded(child: _buildTab('Security')),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.onBackground : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected ? AppColors.onBackground : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Details':
        return _buildDetailsContent();
      case 'Edit Details':
        return _buildEditDetailsContent();
      case 'Security':
        return _buildSecurityContent();
      default:
        return _buildDetailsContent();
    }
  }

  Widget _buildDetailsContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Names
          _buildDetailItem('Names', 'ISHIMWE TRESOR'),
          const SizedBox(height: 24),

          // Telephone
          _buildDetailItem('Telephone', '250784107365'),
          const SizedBox(height: 24),

          // Email
          _buildDetailItem('Email', 'ishimwet15@gmail.com'),
          const SizedBox(height: 24),

          // Current Browsing Country
          _buildDetailItem('Current Browsing Country', 'RWANDA'),
          const SizedBox(height: 40),

          // Delete Account Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showDeleteAccountDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDetailsContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // First Name
          const Text(
            'First Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _firstNameController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Last Name
          const Text(
            'Last name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _lastNameController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Telephone
          const Text(
            'Telephone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _phoneController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Email
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.email,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _emailController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Password
          const Text(
            'Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '••••••••',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
                Icon(
                  Icons.visibility_off,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Update Account Button
          CustomButton(text: 'Update Account', onPressed: _updateAccount),
        ],
      ),
    );
  }

  Widget _buildSecurityContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Recent Password
          const Text(
            'Recent Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Enter Recent Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.visibility_off,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // New Password
          const Text(
            'New Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Enter New Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.visibility_off,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Password
          const Text(
            'Confirm Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Type Password Again',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.visibility_off,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Change Password Button
          CustomButton(text: 'Change Password', onPressed: _changePassword),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion request submitted'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
