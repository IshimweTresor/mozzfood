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

      final resp = await OrderApi.momoStatus(
        token: widget.token,
        requestId: widget.requestId,
      );

      _isChecking = false;

      if (resp.success && resp.data != null) {
        final data = resp.data!;
        // Try multiple shapes for status
        String? serverStatus;
        if (data['status'] != null) {
          serverStatus = data['status'].toString();
        } else if (data['data'] != null && data['data']['status'] != null) {
          serverStatus = data['data']['status'].toString();
        } else if (data['paymentStatus'] != null) {
          serverStatus = data['paymentStatus'].toString();
        }

        serverStatus = serverStatus?.toUpperCase();

        setState(() {
          _status = serverStatus ?? 'PENDING';
        });

        if (serverStatus != null) {
          if (serverStatus.contains('SUCCESS') ||
              serverStatus.contains('COMPLETED') ||
              serverStatus.contains('PAID') ||
              serverStatus.contains('SUCCEEDED')) {
            _timer?.cancel();
            await _onSuccess();
            return;
          }

          if (serverStatus.contains('FAILED') ||
              serverStatus.contains('CANCELLED')) {
            _timer?.cancel();
            await _onFailure();
            return;
          }
        }
      }

      if (_attempts >= _maxAttempts) {
        _timer?.cancel();
        await _onTimeout();
      }
    });
  }

  Future<void> _onSuccess() async {
    // Mark order placed flag so Orders page will refresh
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('order_placed', true);
      await prefs.setString('order_placed_id', widget.orderId);
    } catch (e) {
      // ignore
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => false);
  }

  Future<void> _onFailure() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment failed'),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => false);
  }

  Future<void> _onTimeout() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment not confirmed. Please try again or check your wallet.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
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
