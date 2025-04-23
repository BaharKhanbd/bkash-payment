import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:get/get.dart';

class SSLCOMMERZPayment extends StatefulWidget {
  final double amount;

  const SSLCOMMERZPayment({super.key, required this.amount});

  @override
  State<SSLCOMMERZPayment> createState() => _SSLCOMMERZPaymentState();
}

class _SSLCOMMERZPaymentState extends State<SSLCOMMERZPayment> {
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentSystem();
  }

  Future<void> _initializePaymentSystem() async {
    try {
      // Simulate initialization
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

  Future<void> _payWithSSLCOMMERZ() async {
    if (!_isInitialized || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        multi_card_name: "visa,master,bkash",
        currency: SSLCurrencyType.BDT,
        product_category: "Digital Product",
        sdkType: SSLCSdkType.TESTBOX, // Use LIVE in production
        store_id: "linku680927a0670da",
        store_passwd: "linku680927a0670da@ssl",
        total_amount: widget.amount,
        tran_id: "TestTRX-${DateTime.now().millisecondsSinceEpoch}",
      ),
    );

    final response = await sslcommerz.payNow();

    setState(() {
      _isLoading = false;
    });

    if (response.status == 'VALID') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Payment Success'),
          content: Text('Transaction ID: ${response.tranId}'),
        ),
      );
    } else if (response.status == 'FAILED') {
      Get.snackbar('Failed', 'Payment failed', backgroundColor: Colors.red);
    } else if (response.status == 'Closed') {
      Get.snackbar('Cancelled', 'Payment was closed by user',
          backgroundColor: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSLCOMMERZ Payment')),
      body: Center(
        child: _isInitialized
            ? ElevatedButton(
                onPressed: _isLoading ? null : _payWithSSLCOMMERZ,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text('Pay ৳${widget.amount}'),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing payment system...'),
                ],
              ),
      ),
    );
  }
}
