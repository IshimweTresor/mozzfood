import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PrimePage extends StatefulWidget {
  const PrimePage({super.key});

  @override
  State<PrimePage> createState() => _PrimePageState();
}

class _PrimePageState extends State<PrimePage> {
  String _selectedRecipient = '';
  String _selectedMethod = 'Select method';
  final TextEditingController _phoneController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Visa Card',
      'icon': Icons.credit_card,
      'color': const Color(0xFF1A1F71),
    },
    {
      'name': 'MasterCard',
      'icon': Icons.credit_card,
      'color': const Color(0xFFEB001B),
    },
    {
      'name': 'SmartCash',
      'icon': Icons.payment,
      'color': const Color(0xFFFF6B35),
    },
    {
      'name': 'Airtel Money',
      'icon': Icons.phone_android,
      'color': const Color(0xFFE60012),
    },
    {
      'name': 'MOMO by MTN',
      'icon': Icons.phone_android,
      'color': const Color(0xFFFFCC00),
    },
    {
      'name': 'SPENN',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF00A651),
    },
    {
      'name': 'Pega Já Wallet',
      'icon': Icons.account_balance_wallet,
      'color': AppColors.primary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
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
                  const SizedBox(width: 16),
                  const Text(
                    'Vuba Prime',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrimeHistoryPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.history,
                      color: AppColors.textSecondary,
                    ),
                    label: const Text(
                      'History',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vuba Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'vuba',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Who is Eligible for Vuba Prime?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'To qualify for Vuba Prime membership, you must meet the following criteria at the time of subscription:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Criteria List
                    _buildCriteriaItem(
                      '1. You must be an individual, corporate or sponsored accounts are not allowed.',
                    ),

                    const SizedBox(height: 16),

                    _buildCriteriaItem(
                      '2. You must have done 5 successful prepaid order in the past 30 days via Pega Já.',
                    ),

                    const SizedBox(height: 24),

                    // Eligibility Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'You are eligible to Vuba Prime',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Buy Prime Button (First Screen)
                    if (_selectedRecipient.isEmpty) ...[
                      CustomButton(
                        text: 'Buy Prime',
                        onPressed: () {
                          setState(() {
                            _selectedRecipient =
                                'My Self'; // Set default to My Self
                          });
                        },
                      ),
                    ] else ...[
                      // Buy Prime For Section
                      const Text(
                        'Buy Prime For:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Recipient Selection
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRecipient = 'My Self';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedRecipient == 'My Self'
                                          ? Colors.white
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color:
                                        _selectedRecipient == 'My Self'
                                            ? Colors.white
                                            : AppColors.inputBorder,
                                  ),
                                ),
                                child: Text(
                                  'My Self',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        _selectedRecipient == 'My Self'
                                            ? Colors.black
                                            : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRecipient = 'Others';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedRecipient == 'Others'
                                          ? Colors.white
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color:
                                        _selectedRecipient == 'Others'
                                            ? Colors.white
                                            : AppColors.inputBorder,
                                  ),
                                ),
                                child: Text(
                                  'Others',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        _selectedRecipient == 'Others'
                                            ? Colors.black
                                            : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Subscription form for both My Self and Others
                      // Subscription Plan
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'One month',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  Text(
                                    'RWF 25,000',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  Text(
                                    'Enjoy 30 days of free delivery',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Phone Number Input (only for Others)
                      if (_selectedRecipient == 'Others') ...[
                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Subscriber number or telephone number',
                          keyboardType: TextInputType.phone,
                          prefix: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Method Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Method',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            DropdownButton<String>(
                              value: _selectedMethod,
                              underline: const SizedBox(),
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(
                                color: AppColors.onBackground,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                              ),
                              items:
                                  [
                                    'Select method',
                                    ..._paymentMethods.map(
                                      (e) => e['name'] as String,
                                    ),
                                  ].map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedMethod = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Confirm Button
                      CustomButton(
                        text: 'Confirm',
                        onPressed: () {
                          if (_selectedRecipient == 'Others') {
                            if (_phoneController.text.isNotEmpty &&
                                _selectedMethod != 'Select method') {
                              _handlePurchase();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } else {
                            if (_selectedMethod != 'Select method') {
                              _handlePurchase();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select a payment method',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.onBackground,
        height: 1.5,
      ),
    );
  }

  void _handlePurchase() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Purchase Successful!',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'Your Vuba Prime subscription has been activated.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

// Prime History Page
class PrimeHistoryPage extends StatelessWidget {
  const PrimeHistoryPage({super.key});

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
          'Prime History',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main circle (sad face)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('😞', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  // Small decorative elements
                  ...List.generate(6, (index) {
                    final angle = (index * 60) * (3.14159 / 180);
                    final radius = 50.0;
                    return Positioned(
                      left: 60 + radius * cos(angle) - 4,
                      top: 60 + radius * sin(angle) - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              index % 2 == 0 ? AppColors.primary : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Data Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have not yet purchased any Vuba Prime package',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function for angle calculations
double cos(double angle) => math.cos(angle);
double sin(double angle) => math.sin(angle);
