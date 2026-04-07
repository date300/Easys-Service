import 'package:flutter/material.dart';
import '../widgets/payment_widgets.dart';
import '../models/payment_method.dart';

class BinancePaymentFlow extends StatelessWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const BinancePaymentFlow({super.key, required this.method, required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Binance Pay')),
      body: const Center(child: Text('Binance Payment Flow Coming Soon...')),
    );
  }
}
