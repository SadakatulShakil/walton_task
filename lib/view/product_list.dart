import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart/controllers/product_provider.dart';
import 'package:shopping_cart/view/productDetailsScreen.dart';

import '../models/product_model.dart';
import 'checkout_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final Set<int> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  double _calculateTotal(List<Product> products) {
    return products
        .where((product) => _selectedProducts.contains(product.id))
        .fold(0, (sum, product) => sum + product.price);
  }

  void _handleCheckout() {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final selectedProductsList = productProvider.products
        .where((product) => _selectedProducts.contains(product.id))
        .toList();
    final totalAmount = _calculateTotal(productProvider.products);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckOutScreen(
          selectedProducts: selectedProductsList,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          switch (productProvider.status) {
            case ProductStatus.initial:
            case ProductStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case ProductStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${productProvider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => productProvider.fetchProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case ProductStatus.loaded:
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      await productProvider.fetchProducts();
                    },
                    child: ListView.builder(
                      itemCount: productProvider.products.length,
                      padding: const EdgeInsets.only(bottom: 80), // Space for bottom bar
                      itemBuilder: (context, index) {
                        final product = productProvider.products[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: Image.network(
                              product.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                            ),
                            title: Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            trailing: Checkbox(
                              value: _selectedProducts.contains(product.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value ?? false) {
                                    _selectedProducts.add(product.id);
                                  } else {
                                    _selectedProducts.remove(product.id);
                                  }
                                });
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  if (productProvider.products.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: \$${_calculateTotal(productProvider.products).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _handleCheckout,
                              child: const Text('Checkout'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
          }
        },
      ),
    );
  }
}