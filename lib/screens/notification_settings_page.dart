import 'package:flutter/material.dart';
import '../utils/colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _marketingNotifications = true;

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
          'Notification Settings',
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
            // Marketing Notifications Toggle
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Marketing Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                  Switch(
                    value: _marketingNotifications,
                    onChanged: (value) {
                      setState(() {
                        _marketingNotifications = value;
                      });
                      _showNotificationUpdate();
                    },
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withOpacity(0.3),
                    inactiveThumbColor: AppColors.textSecondary,
                    inactiveTrackColor: AppColors.inputBorder,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.inputBorder),
            const SizedBox(height: 24),

            // Additional settings placeholder
            const Text(
              'Other notification preferences can be configured here',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _marketingNotifications
              ? 'Marketing notifications enabled'
              : 'Marketing notifications disabled',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
