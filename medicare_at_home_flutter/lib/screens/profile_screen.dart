import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'checkout_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const route = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>>? future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<AppState>();
    if (state.isLoggedIn && future == null) future = loadData();
  }

  Future<Map<String, dynamic>> loadData() async {
    final api = context.read<ApiClient>();
    final cartData = await api.getJson('/api/store/cart');
    final orderData = await api.getJson('/api/store/orders');
    return {
      'cart': (cartData['cart'] is List ? cartData['cart'] as List : const []).map(CartItem.fromJson).toList(),
      'orders': (orderData['orders'] is List ? orderData['orders'] as List : const []).map(OrderItem.fromJson).toList(),
    };
  }

  Future<void> removeCart(String id) async {
    try {
      await context.read<ApiClient>().deleteJson('/api/store/cart/$id');
      setState(() => future = loadData());
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    }
  }

  Future<void> cancelOrder(String id) async {
    try {
      await context.read<ApiClient>().patchJson('/api/store/orders/$id', {'action': 'cancel'});
      setState(() => future = loadData());
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AppSectionHeader(kicker: 'Account', title: 'Log in required', subtitle: 'Log in to view your cart and order status.'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, AuthScreen.route), child: const Text('Log in / Sign up')),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [IconButton(onPressed: () async { await state.logout(); if (mounted) Navigator.pop(context); }, icon: const Icon(Icons.logout))],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
          if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadData()));
          final cart = snapshot.data?['cart'] as List<CartItem>? ?? [];
          final orders = snapshot.data?['orders'] as List<OrderItem>? ?? [];
          final user = state.user!;
          return RefreshIndicator(
            onRefresh: () async => setState(() => future = loadData()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                SoftCard(
                  child: Row(children: [
                    AppImage(url: user.photoUrl, width: 72, height: 72, placeholderIcon: Icons.person),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      if (user.phone.isNotEmpty) Text(user.phone),
                      if (user.email.isNotEmpty) Text(user.email),
                    ])),
                  ]),
                ),
                const SizedBox(height: 24),
                Text('Cart', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (cart.isEmpty) const SoftCard(child: Text('Your cart is empty.')),
                ...cart.map((item) {
                  final product = item.product;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      child: Row(children: [
                        AppImage(url: product?.photoUrl ?? '', width: 64, height: 64),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(product?.name ?? 'Product', style: const TextStyle(fontWeight: FontWeight.w900)),
                          Text('Qty ${item.quantity} • ${money((product?.price ?? 0) * item.quantity)}'),
                        ])),
                        IconButton(onPressed: () => removeCart(item.id), icon: const Icon(Icons.delete_outline)),
                        if (product != null) IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(product: product, initialQuantity: item.quantity))), icon: const Icon(Icons.local_shipping_outlined)),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Text('Orders', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (orders.isEmpty) const SoftCard(child: Text('No orders yet.')),
                ...orders.map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(order.productName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
                            Chip(label: Text(_statusLabel(order.status))),
                          ]),
                          const SizedBox(height: 8),
                          Text('Qty ${order.quantity} • Total ${money(order.total)}'),
                          Text('Payment: ${order.paymentMethod}'),
                          if (order.transactionId.isNotEmpty) Text('TRX: ${order.transactionId}'),
                          if (order.status == 'pending' || order.status == 'pending_payment') ...[
                            const SizedBox(height: 10),
                            OutlinedButton.icon(onPressed: () => cancelOrder(order.id), icon: const Icon(Icons.cancel_outlined), label: const Text('Cancel order')),
                          ],
                        ]),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'pending_payment': return 'Pending Payment';
      case 'payment_submitted': return 'Payment Submitted';
      case 'confirmed': return 'Payment Confirmed';
      case 'on_the_way': return 'On the way';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return 'Pending';
    }
  }
}
