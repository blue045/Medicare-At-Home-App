import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.product, this.initialQuantity = 1});

  final Product product;
  final int initialQuantity;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController address;
  late final TextEditingController area;
  late final TextEditingController phone;
  late final TextEditingController quantity;
  final sender = TextEditingController();
  final trx = TextEditingController();
  String paymentMethod = 'cod';
  String deliveryPaymentMethod = 'bkash';
  bool submitting = false;
  PaymentSettings? paymentSettings;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    name = TextEditingController(text: user?.fullName ?? '');
    address = TextEditingController();
    area = TextEditingController(text: 'Feni');
    phone = TextEditingController(text: user?.phone ?? '');
    quantity = TextEditingController(text: widget.initialQuantity.toString());
    loadPaymentSettings();
  }

  Future<void> loadPaymentSettings() async {
    try {
      final data = await context.read<ApiClient>().getJson('/api/store/payment-settings');
      setState(() => paymentSettings = PaymentSettings.fromJson(data['paymentSettings']));
    } catch (_) {}
  }

  @override
  void dispose() {
    name.dispose();
    address.dispose();
    area.dispose();
    phone.dispose();
    quantity.dispose();
    sender.dispose();
    trx.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final state = context.read<AppState>();
    if (!state.isLoggedIn) {
      Navigator.pushNamed(context, AuthScreen.route);
      return;
    }
    if (!formKey.currentState!.validate()) return;
    setState(() => submitting = true);
    try {
      await context.read<ApiClient>().postJson('/api/store/orders', {
        'productId': widget.product.id,
        'fullName': name.text.trim(),
        'address': address.text.trim(),
        'deliveryLocation': area.text.trim(),
        'phone': phone.text.trim(),
        'quantity': int.tryParse(quantity.text.trim()) ?? 1,
        'paymentMethod': paymentMethod,
        'deliveryPaymentMethod': paymentMethod == 'cod' ? deliveryPaymentMethod : '',
        'senderNumber': sender.text.trim(),
        'transactionId': trx.text.trim(),
      });
      if (!mounted) return;
      showSnack(context, 'Order placed successfully.');
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentNumber = paymentMethod == 'cod'
        ? (deliveryPaymentMethod == 'bkash' ? paymentSettings?.bkashNumber : paymentSettings?.nagadNumber)
        : 'Use bKash/Nagad number shown by admin';
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            SoftCard(
              child: Row(children: [
                AppImage(url: widget.product.photoUrl, width: 70, height: 70),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(money(widget.product.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF2367FF), fontWeight: FontWeight.w900)),
                ])),
              ]),
            ),
            const SizedBox(height: 18),
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full Name'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: area, decoration: const InputDecoration(labelText: 'Delivery Location / Area'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: address, maxLines: 3, decoration: const InputDecoration(labelText: 'Full Address'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'), validator: _required),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: const [
                DropdownMenuItem(value: 'cod', child: Text('Cash on Delivery')),
                DropdownMenuItem(value: 'bkash_nagad', child: Text('bKash / Nagad')),
              ],
              onChanged: (value) => setState(() => paymentMethod = value ?? 'cod'),
            ),
            if (paymentMethod == 'cod') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: deliveryPaymentMethod,
                decoration: const InputDecoration(labelText: 'Pay Delivery Fee With'),
                items: const [
                  DropdownMenuItem(value: 'bkash', child: Text('bKash delivery fee')),
                  DropdownMenuItem(value: 'nagad', child: Text('Nagad delivery fee')),
                ],
                onChanged: (value) => setState(() => deliveryPaymentMethod = value ?? 'bkash'),
              ),
            ],
            const SizedBox(height: 14),
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Payment instruction', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text(paymentSettings?.instructions.isNotEmpty == true ? paymentSettings!.instructions : 'Pay first, then enter sender number and transaction ID.'),
                const SizedBox(height: 8),
                Text('Number: ${paymentNumber?.isNotEmpty == true ? paymentNumber : 'Not configured'}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: sender, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Sender Number'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: trx, decoration: const InputDecoration(labelText: 'Transaction ID'), validator: _required),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: ElevatedButton.icon(
            onPressed: submitting ? null : submit,
            icon: submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle),
            label: const Text('Place Order'),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}
