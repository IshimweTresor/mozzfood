import 'package:flutter/material.dart';
import 'package:vuba/models/user.model.dart';
import '../utils/colors.dart';
import 'mobile_wallet_numbers_page.dart';
import 'order_summary_page.dart';

class PaymentMethodPage extends StatefulWidget {
    final SavedLocation selectedLocation;
  const PaymentMethodPage({super.key, required this.selectedLocation});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Vuba Wallet',
      'balance': 'Balance 0 RWF',
      'logo': 'assets/vuba_wallet.png',
      'color': AppColors.primary,
    },
    {
      'name': 'MOMO by MTN',
      'balance': '',
      'logo': 'assets/momo.png',
      'color': const Color(0xFFFFCC00),
    },
    {
      'name': 'Visa Card',
      'balance': '',
      'logo': 'assets/visa.png',
      'color': const Color(0xFF1A1F71),
    },
    {
      'name': 'MasterCard',
      'balance': '',
      'logo': 'assets/mastercard.png',
      'color': const Color(0xFFEB001B),
    },
    {
      'name': 'Airtel Money',
      'balance': '',
      'logo': 'assets/airtel.png',
      'color': const Color(0xFFE60012),
    },
    {
      'name': 'SmartCash',
      'balance': '',
      'logo': 'assets/smartcash.png',
      'color': const Color(0xFFFF6B35),
    },
    {
      'name': 'SPENN',
      'balance': '',
      'logo': 'assets/spenn.png',
      'color': const Color(0xFF00A651),
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
                    'Payment Method',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // K-Pay Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'K',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PAY',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Payment Methods Grid
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    final isSelected = _selectedPaymentMethod == method['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = method['name'];
                        });

                        // Check if it's a mobile money option
                        if (method['name'] == 'MOMO by MTN' ||
                            method['name'] == 'Airtel Money') {
                          Future.delayed(const Duration(milliseconds: 200), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MobileWalletNumbersPage(
                                      paymentMethod: method['name'],
                                      selectedLocation:
                                          widget
                                              .selectedLocation, // Pass the address!
                                    ),
                              ),
                            );
                          });
                        } else {
                          // Navigate to Order Summary for other payment methods
                          Future.delayed(const Duration(milliseconds: 200), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => OrderSummaryPage(
                                      paymentMethod: method['name'],
                                      selectedNumber:
                                          '', // Not applicable for non-mobile money
                                    ),
                              ),
                            );
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? method['color'].withOpacity(0.1)
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? method['color']
                                    : AppColors.inputBorder.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Payment Method Icon/Logo
                            Container(
                              width: 60,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildPaymentIcon(method['name']),
                            ),

                            const SizedBox(height: 12),

                            // Payment Method Name
                            Text(
                              method['name'],
                              style: const TextStyle(
                                color: AppColors.onBackground,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Balance (for Vuba Wallet)
                            if (method['balance'].isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                method['balance'],
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIcon(String methodName) {
    switch (methodName) {
      case 'Vuba Wallet':
        return Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'vuba',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      case 'MOMO by MTN':
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'MoMo',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      case 'Visa Card':
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
        );
      case 'MasterCard':
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 8, backgroundColor: Color(0xFFEB001B)),
                SizedBox(width: 2),
                CircleAvatar(radius: 8, backgroundColor: Color(0xFFFF5F00)),
              ],
            ),
          ),
        );
      case 'Airtel Money':
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE60012),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'airtel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        );
      case 'SmartCash':
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      case 'SPENN':
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF00A651),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'SPENN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        );
      default:
        return const Icon(Icons.payment, color: AppColors.primary, size: 24);
    }
  }
}
