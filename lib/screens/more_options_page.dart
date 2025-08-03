import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MoreOptionsPage extends StatefulWidget {
  const MoreOptionsPage({super.key});

  @override
  State<MoreOptionsPage> createState() => _MoreOptionsPageState();
}

class _MoreOptionsPageState extends State<MoreOptionsPage> {
  bool _showSignOutDialog = false;

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
          'Options',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Section
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Info
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Personal Info',
                  onTap:
                      () =>
                          Navigator.pushNamed(context, '/personal-information'),
                ),
                const SizedBox(height: 16),

                // My Orders
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'My Orders',
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                const SizedBox(height: 16),

                // My Address
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'My Address',
                  onTap: () => Navigator.pushNamed(context, '/address-book'),
                ),
                const SizedBox(height: 16),

                // Pega Já Wallet
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Pega Já Wallet',
                  onTap: () => Navigator.pushNamed(context, '/vuba-wallet'),
                ),
                const SizedBox(height: 16),

                // Mobile Wallet Money
                _buildMenuItem(
                  icon: Icons.phone_android_outlined,
                  title: 'Mobile Wallet Money',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/mobile-wallet-numbers',
                      ),
                ),
                const SizedBox(height: 16),

                // Pega Já Rating and Reviews
                _buildMenuItem(
                  icon: Icons.star_outline,
                  title: 'Pega Já Rating and Review',
                  onTap: () => Navigator.pushNamed(context, '/rating-reviews'),
                ),

                const SizedBox(height: 32),

                // App Setting Section
                const Text(
                  'App Setting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Notification settings
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notification settings',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/notification-settings',
                      ),
                ),
                const SizedBox(height: 16),

                // Inbox
                _buildMenuItem(
                  icon: Icons.inbox_outlined,
                  title: 'Inbox',
                  onTap: () => Navigator.pushNamed(context, '/messages'),
                ),
                const SizedBox(height: 16),

                // About Us
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () => Navigator.pushNamed(context, '/about-us'),
                ),
                const SizedBox(height: 32),

                // Logout
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => setState(() => _showSignOutDialog = true),
                  isDestructive: true,
                ),
                const SizedBox(height: 40),

                // Copyright
                Center(
                  child: const Text(
                    'Copyright © 2025 Pega Já',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Sign Out Dialog Overlay
          if (_showSignOutDialog)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Are you sure you want to sign\nout?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  () => setState(
                                    () => _showSignOutDialog = false,
                                  ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.inputBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'No',
                                style: TextStyle(color: AppColors.onBackground),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _signOut,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Yes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
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
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDestructive ? AppColors.error : AppColors.onBackground,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _signOut() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
