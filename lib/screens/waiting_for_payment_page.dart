import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/order.api.dart';

class WaitingForPaymentPage extends StatefulWidget {
  final String token;
  final String orderId;
  final String requestId;
  final double amount;

  const WaitingForPaymentPage({
    super.key,
    required this.token,
    required this.orderId,
    required this.requestId,
    required this.amount,
  });

  @override
  State<WaitingForPaymentPage> createState() => _WaitingForPaymentPageState();
}

class _WaitingForPaymentPageState extends State<WaitingForPaymentPage> {
  Timer? _timer;
  String _status = 'PENDING';
  bool _isChecking = false;
  int _attempts = 0;
  final int _maxAttempts = 40; // ~40 * 3s = 120s (2 minutes)

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    _attempts = 0;
    _timer = Timer.periodic(const Duration(seconds: 3), (t) async {
      if (_isChecking) return;
      _isChecking = true;
      _attempts++;

      print('🔍 Checking payment status (attempt $_attempts/$_maxAttempts)...');

      final resp = await OrderApi.momoStatus(
        token: widget.token,
        requestId: widget.requestId,
      );

      _isChecking = false;

      print(
        '🔍 MoMo status response: success=${resp.success}, data=${resp.data}',
      );

      if (resp.success && resp.data != null) {
        final data = resp.data!;

        // Extract status from multiple possible fields
        String? serverStatus;
        dynamic rawStatus;

        // Check all possible status fields
        if (data['status'] != null) {
          rawStatus = data['status'];
        } else if (data['paymentStatus'] != null) {
          rawStatus = data['paymentStatus'];
        } else if (data['transactionStatus'] != null) {
          rawStatus = data['transactionStatus'];
        } else if (data['data'] is Map) {
          final innerData = data['data'] as Map;
          rawStatus =
              innerData['status'] ??
              innerData['paymentStatus'] ??
              innerData['transactionStatus'];
        }

        serverStatus = rawStatus?.toString().toUpperCase();

        print('🔍 Extracted status: "$serverStatus" from raw: $rawStatus');

        setState(() {
          _status = serverStatus ?? 'PENDING';
        });

        if (serverStatus != null) {
          // SUCCESS patterns
          if (serverStatus.contains('SUCCESS') ||
              serverStatus.contains('SUCCESSFUL') ||
              serverStatus.contains('COMPLETED') ||
              serverStatus.contains('PAID') ||
              serverStatus.contains('APPROVED') ||
              serverStatus.contains('SUCCEEDED')) {
            print('✅ Payment SUCCESS detected!');
            _timer?.cancel();
            await _onSuccess();
            return;
          }

          // FAILURE patterns (only consider explicit failures)
          if (serverStatus.contains('FAILED') ||
              serverStatus.contains('REJECTED') ||
              serverStatus.contains('DECLINED') ||
              serverStatus.contains('CANCELLED') ||
              serverStatus.contains('ERROR')) {
            print('❌ Payment FAILURE detected!');
            _timer?.cancel();
            await _onFailure();
            return;
          }

          // Still pending
          print('⏳ Payment still PENDING: $serverStatus');
        } else {
          print('⚠️ No status found in response');
        }
      } else {
        print('⚠️ MoMo status check failed: ${resp.message}');
      }

      if (_attempts >= _maxAttempts) {
        _timer?.cancel();
        await _onTimeout();
      }
    });
  }

  Future<void> _onSuccess() async {
    print('✅ Processing successful payment...');

    // Mark order placed flag so Orders page will refresh
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('order_placed', true);
      await prefs.setString('order_placed_id', widget.orderId);
      print('✅ Order placed flag saved');
    } catch (e) {
      print('⚠️ Could not save order flag: $e');
    }

    // Update order payment status to COMPLETED when payment is successful
    try {
      int? orderId = int.tryParse(widget.orderId);
      if (orderId != null) {
        print('🔄 Updating order payment status to COMPLETED...');
        final result = await OrderApi.updateOrderPaymentStatus(
          token: widget.token,
          orderId: orderId,
          paymentStatus: 'COMPLETED',
        );
        print('✅ Order payment status updated: ${result.success}');
      }
    } catch (e) {
      print('⚠️ Could not update order payment status: $e');
    }

    if (!mounted) return;

    // Simple success message
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text(
          'RWF ${widget.amount.toStringAsFixed(0)} paid successfully.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    print('🏁 Navigating to orders page...');
    Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => false);
  }

  Future<void> _onFailure() async {
    if (!mounted) return;

    print('❌ Processing failed payment...');

    // Update order payment status to FAILED when payment fails
    try {
      int? orderId = int.tryParse(widget.orderId);
      if (orderId != null) {
        print('🔄 Updating order payment status to FAILED...');
        await OrderApi.updateOrderPaymentStatus(
          token: widget.token,
          orderId: orderId,
          paymentStatus: 'FAILED',
        );
        print('✅ Order payment status updated to FAILED');
      }
    } catch (e) {
      print('⚠️ Could not update order payment status: $e');
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Not Completed'),
        content: const Text('Payment was declined or cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    print('🏁 Navigating to orders page...');
    Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => false);
  }

  Future<void> _onTimeout() async {
    if (!mounted) return;

    print('⏱️ Payment status check timed out after $_attempts attempts');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Checking Payment...'),
        content: const Text(
          'Payment confirmation is taking longer than expected. Please check your orders to see if payment completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    print('🏁 Navigating to orders page...');
    Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('Waiting for Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Waiting for payment confirmation...',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Status: $_status',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/orders',
                        (r) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      _startPolling();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
