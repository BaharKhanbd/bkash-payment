import 'package:flutter/material.dart';
import 'package:flutter_bkash/flutter_bkash.dart';
import 'package:get/get.dart';

class BkashPaymentPage extends StatefulWidget {
  const BkashPaymentPage({super.key});

  @override
  State<BkashPaymentPage> createState() => _BkashPaymentPageState();
}

class _BkashPaymentPageState extends State<BkashPaymentPage> {
  final double totalPrice = 100.0;
  bool _isInitialized = false;
  bool _isLoading = false;
// Add WebViewController

  @override
  void initState() {
    super.initState();
    // Initialize WebView
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Create a hidden WebView to ensure the engine is initialized

      // Additional delay to ensure complete initialization
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize payment system: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> bkashPayment(BuildContext context) async {
    if (!_isInitialized || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final flutterBkash = FlutterBkash();

    try {
      final result = await flutterBkash.pay(
        context: context,
        amount: totalPrice,
        merchantInvoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result is Map<String, dynamic>) {
        Get.snackbar(
          'Payment Successful ✅',
          'Transaction ID: ${result.trxId}\n'
              'Payment ID: ${result.paymentId}\n'
              'Customer: ${result.customerMsisdn}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error ⚠️',
        'Payment failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bKash Payment'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isInitialized)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing payment system...'),
                ],
              ),
            if (_isInitialized)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => bkashPayment(context),
                icon: const Icon(Icons.payment),
                label: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Pay with bKash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
