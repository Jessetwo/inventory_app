import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventory/Add_new.dart';
import 'package:inventory/database/database_helper.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/product_details.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Product> _products = [];
  String _search = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshProducts();
    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text;
      });
      _refreshProducts(query: _search);
    });
  }

  Future<void> _refreshProducts({String? query}) async {
    final items = await _db.getProducts(query: query);
    setState(() => _products = items);
  }

  void _goToAddNew({Product? product}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNew(product: product)),
    );
    _refreshProducts(query: _search);
  }

  void _openDetails(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetails(product: product)),
    );
    _refreshProducts(query: _search);
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && product.id != null) {
      await _db.deleteProduct(product.id!);
      _refreshProducts(query: _search);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item deleted')));
      }
    }
  }

  Widget _buildProductItem(Product product) {
    return GestureDetector(
      onTap: () => _openDetails(product),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(.3), width: .8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Product info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  product.category,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'Qty: ${product.quantity}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₦${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            // Image and  Actions row
            Row(
              children: [
                GestureDetector(
                  onTap: () => _goToAddNew(product: product),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => _deleteProduct(product),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                const SizedBox(width: 5),

                // Product image
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _getProductImage(product),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getProductImage(Product product) {
    if (product.imagePath == null || product.imagePath!.isEmpty) {
      return const AssetImage('assets/images/shoe.jpg');
    } else if (File(product.imagePath!).existsSync()) {
      return FileImage(File(product.imagePath!));
    } else {
      return const AssetImage('assets/images/shoe.jpg');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshProducts(query: _search),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Inventory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _goToAddNew(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.blue,
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.add, size: 16, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              'Add item',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search item...',
                      prefixIcon: Icon(Icons.search, size: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Product List
                Expanded(
                  child: _products.isEmpty
                      ? const Center(
                          child: Text(
                            'No items yet.\nTap "Add item" to create one.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: _products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) =>
                              _buildProductItem(_products[index]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
