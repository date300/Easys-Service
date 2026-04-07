import 'package:flutter/material.dart';
import '../widgets/payment_widgets.dart';
import '../models/payment_method.dart';

class NagadPaymentFlow extends StatelessWidget {
  final PaymentMethod method;
  final double amount;
  final String purpose;

  const NagadPaymentFlow({super.key, required this.method, required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nagad Payment')),
      body: const Center(child: Text('Nagad Payment Flow Coming Soon...')),
    );
  }
}
