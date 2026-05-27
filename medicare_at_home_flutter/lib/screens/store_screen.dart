import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'checkout_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<List<Product>> future;
  String query = '';

  @override
  void initState() {
    super.initState();
    future = loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    final api = context.read<ApiClient>();
    final data = await api.getJson('/api/store/products');
    return (data['products'] is List ? data['products'] as List : const []).map(Product.fromJson).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Product>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const LoadingState();
          if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: () => setState(() => future = loadProducts()));
          final products = snapshot.data ?? [];
          final filtered = products.where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || p.productType.toLowerCase().contains(query.toLowerCase())).toList();
          return RefreshIndicator(
            onRefresh: () async => setState(() => future = loadProducts()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                const AppSectionHeader(kicker: 'Store', title: 'Buy medicine online', subtitle: 'Browse available products, add items to cart, and place orders through your existing backend.'),
                const SizedBox(height: 18),
                TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search medicine or equipment'),
                  onChanged: (value) => setState(() => query = value),
                ),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  const EmptyState(message: 'No products found.')
                else
                  ...filtered.map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: SoftCard(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))).then((_) => setState(() => future = loadProducts())),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppImage(url: product.photoUrl, width: 92, height: 92, placeholderIcon: product.productType == 'equipment' ? Icons.medical_services : Icons.medication),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 8),
                                  Text(product.productType.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF2367FF), fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                                  const SizedBox(height: 8),
                                  Text(money(product.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF2367FF), fontWeight: FontWeight.w900)),
                                  Text(product.stock > 0 ? 'In stock: ${product.stock}' : 'Out of stock', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: product.stock > 0 ? const Color(0xFF16A34A) : Colors.red)),
                                ]),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AppState>(
        builder: (context, state, _) => FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, state.isLoggedIn ? '/profile' : AuthScreen.route),
          icon: Icon(state.isLoggedIn ? Icons.shopping_cart : Icons.login),
          label: Text(state.isLoggedIn ? 'Cart' : 'Login'),
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool adding = false;

  Future<void> addToCart() async {
    final state = context.read<AppState>();
    if (!state.isLoggedIn) {
      Navigator.pushNamed(context, AuthScreen.route);
      return;
    }
    setState(() => adding = true);
    try {
      await context.read<ApiClient>().postJson('/api/store/cart', {'productId': widget.product.id, 'quantity': 1});
      if (mounted) showSnack(context, 'Added to cart.');
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final gallery = product.gallery;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        children: [
          SizedBox(
            height: 280,
            child: gallery.isEmpty
                ? AppImage(url: '', height: 280, width: double.infinity)
                : PageView.builder(
                    itemCount: gallery.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppImage(url: gallery[i], height: 280, width: double.infinity, borderRadius: 30),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 12),
          Row(children: [
            Text(money(product.price), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF2367FF), fontWeight: FontWeight.w900)),
            const Spacer(),
            Chip(label: Text(product.stock > 0 ? 'Stock ${product.stock}' : 'Out of stock')),
          ]),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Delivery charge', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text('Feni: ${money(product.feniDeliveryCharge)}'),
              Text('Outside Feni: ${money(product.outsideFeniDeliveryCharge)}'),
            ]),
          ),
          const SizedBox(height: 16),
          if (product.description.isNotEmpty)
            Text(product.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF475467), height: 1.7)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: adding || product.stock <= 0 ? null : addToCart, icon: adding ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_shopping_cart), label: const Text('Add Cart'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: product.stock <= 0 ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(product: product))), icon: const Icon(Icons.local_shipping), label: const Text('Order Now'))),
            ],
          ),
        ),
      ),
    );
  }
}
