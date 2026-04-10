import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../models/payment_method.dart';

class AmountCard extends StatelessWidget {
  final double amount;
  final String purpose;
  const AmountCard({super.key, required this.amount, required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(purpose, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text('৳ ${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Lottie.asset('assets/lottie/wallet.json', width: 48, height: 48, fit: BoxFit.contain, repeat: true),
        ],
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback? onTap;
  const PaymentMethodCard({super.key, required this.method, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = method.available;
    final Color textColor = isAvailable ? (isSelected ? method.primaryColor : Colors.black) : Colors.grey[500]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isAvailable ? (isSelected ? method.primaryColor.withOpacity(0.07) : Colors.white) : Colors.grey[50],
          border: Border.all(color: isAvailable ? (isSelected ? method.primaryColor : const Color(0xFFEEEEEE)) : Colors.grey[300]!, width: isSelected && isAvailable ? 2 : 1.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected && isAvailable
              ? [BoxShadow(color: method.primaryColor.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]
              : [const BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Opacity(
              opacity: isAvailable ? 1.0 : 0.6,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: method.primaryColor.withOpacity(isAvailable ? 0.12 : 0.06), borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(method.logoAsset, fit: BoxFit.contain)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(method.subtitle + (isAvailable ? '' : ' • Locked'), style: TextStyle(color: isAvailable ? Colors.black45 : Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            if (!isAvailable) Lottie.asset('assets/lottie/lock.json', width: 28, height: 28, repeat: true)
            else AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22, height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? method.primaryColor : Colors.black26, width: 2), color: isSelected ? method.primaryColor : Colors.transparent),
                child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class ProceedButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;
  const ProceedButton({super.key, required this.enabled, required this.isLoading, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: double.infinity, height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? LinearGradient(colors: [color, color.withOpacity(0.75)]) : const LinearGradient(colors: [Color(0xFFDDDDDD), Color(0xFFDDDDDD)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))] : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled && !isLoading ? onTap : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Proceed to Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int current;
  final Color color;
  const StepIndicator({super.key, required this.current, required this.color});

  @override
  Widget build(BuildContext context) {
    final labels = ['Number', 'OTP', 'PIN'];
    return Row(
      children: List.generate(3, (i) {
        final isDone = i < current;
        final isActive = i == current;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(duration: const Duration(milliseconds: 300), height: 4, decoration: BoxDecoration(color: isDone || isActive ? color : const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Text(labels[i], style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? color : isDone ? Colors.black45 : Colors.black26)),
                  ],
                ),
              ),
              if (i < 2) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }
}

class PaymentSummaryHeader extends StatelessWidget {
  final PaymentMethod method;
  final double amount;
  const PaymentSummaryHeader({super.key, required this.method, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: method.primaryColor.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: method.primaryColor.withOpacity(0.2))),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: method.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(method.logoAsset, fit: BoxFit.contain))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(method.name, style: TextStyle(color: method.primaryColor, fontSize: 14, fontWeight: FontWeight.w700)), Text(method.subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12))])),
          Text('৳ ${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class PaymentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint, label;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final IconData prefixIcon;
  final Color accentColor;
  final bool obscureText;
  final Widget? suffixIcon;

  const PaymentTextField({super.key, required this.controller, required this.hint, required this.label, required this.keyboardType, required this.inputFormatters, required this.prefixIcon, required this.accentColor, this.obscureText = false, this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters, obscureText: obscureText,
      style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint, labelText: label, hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14),
        labelStyle: TextStyle(color: accentColor.withOpacity(0.8)), prefixIcon: Icon(prefixIcon, color: accentColor, size: 20), suffixIcon: suffixIcon, filled: true, fillColor: accentColor.withOpacity(0.04),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor.withOpacity(0.25), width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor, width: 1.8)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class OtpInputRow extends StatefulWidget {
  final TextEditingController controller;
  final Color accentColor;
  const OtpInputRow({super.key, required this.controller, required this.accentColor});

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    widget.controller.text = _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 44, height: 52,
          child: TextField(
            controller: _controllers[i], focusNode: _focusNodes[i], textAlign: TextAlign.center, keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)], style: TextStyle(color: widget.accentColor, fontSize: 20, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              filled: true, fillColor: widget.accentColor.withOpacity(0.06), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.accentColor.withOpacity(0.25), width: 1.2)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.accentColor, width: 2)), contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => _onChanged(v, i),
          ),
        );
      }),
    );
  }
}

class PaymentResultDialog extends StatelessWidget {
  final bool success;
  const PaymentResultDialog({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(success ? 'assets/lottie/payment_success.json' : 'assets/lottie/payment_failed.json', width: 110, height: 110, repeat: false),
            const SizedBox(height: 20),
            Text(success ? 'Payment Successful!' : 'Payment Failed', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(success ? 'Your payment has been completed successfully.' : 'Something went wrong. Please try again.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFF6C63FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                onPressed: () { Navigator.pop(context); if (success) Navigator.pop(context); },
                child: Text(success ? 'Done' : 'Try Again', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
