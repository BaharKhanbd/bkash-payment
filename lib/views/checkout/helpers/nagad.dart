import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NagadPaymentPage extends StatefulWidget {
  const NagadPaymentPage({super.key});

  @override
  State<NagadPaymentPage> createState() => _NagadPaymentPageState();
}

class _NagadPaymentPageState extends State<NagadPaymentPage> {
  final double totalPrice = 100.0;
  bool _isLoading = false;

  Future<void> nagadPayment() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            "http://10.0.2.2:3000/api/initiate-nagad-payment"), // for Android emulator
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": totalPrice.toString(),
          "orderId": "ORDER_${DateTime.now().millisecondsSinceEpoch}",
          "customerMobile": "01XXXXXXXXX"
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["payment_url"] != null) {
        final paymentUrl = data["payment_url"];

        if (await canLaunchUrl(Uri.parse(paymentUrl))) {
          await launchUrl(Uri.parse(paymentUrl),
              mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch payment URL';
        }
      } else {
        throw data['message'] ?? 'Something went wrong.';
      }
    } catch (e) {
      Get.snackbar(
        'Payment Failed ❌',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nagad Payment'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : nagadPayment,
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
              : const Text('Pay with Nagad'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),
    );
  }
}
