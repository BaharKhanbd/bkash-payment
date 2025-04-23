import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SSLCOMMERZPayment {
  static Future<void> initiatePayment(BuildContext context) async {
    final uri =
        Uri.parse('https://sandbox.sslcommerz.com/gwprocess/v4/api.php');

    final response = await http.post(uri, body: {
      'store_id': 'your_store_id', // তোমার Sandbox store_id
      'store_passwd': 'your_store_passwd', // তোমার Sandbox store_passwd
      'total_amount': '100',
      'currency': 'BDT',
      'tran_id': 'TEST12345678',
      'success_url': 'https://yourdomain.com/success',
      'fail_url': 'https://yourdomain.com/fail',
      'cancel_url': 'https://yourdomain.com/cancel',
      'cus_name': 'Customer Name',
      'cus_email': 'test@test.com',
      'cus_add1': 'Dhaka',
      'cus_phone': '01711111111',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'SUCCESS') {
        final gatewayUrl = data['GatewayPageURL'];
        if (await canLaunchUrl(Uri.parse(gatewayUrl))) {
          await launchUrl(Uri.parse(gatewayUrl),
              mode: LaunchMode.externalApplication);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('পেমেন্ট শুরু করতে সমস্যা হয়েছে।')),
      );
    }
  }
}
