import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  ProductStatus _status = ProductStatus.initial;
  ProductStatus get status => _status;

  String _error = '';
  String get error => _error;

  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  static const String baseUrl = 'https://fakestoreapi.com';

  Future<void> fetchProducts() async {
    try {
      _status = ProductStatus.loading;
      notifyListeners();

      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _products = jsonData.map((json) => Product.fromJson(json)).toList();
        _status = ProductStatus.loaded;
      } else {
        _error = 'Failed to load products';
        _status = ProductStatus.error;
      }
    } catch (e) {
      _error = e.toString();
      _status = ProductStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchProductById(int id) async {
    try {
      _status = ProductStatus.loading;
      notifyListeners();

      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        _selectedProduct = Product.fromJson(json.decode(response.body));
        _status = ProductStatus.loaded;
      } else {
        _error = 'Failed to load product';
        _status = ProductStatus.error;
      }
    } catch (e) {
      _error = e.toString();
      _status = ProductStatus.error;
    }
    notifyListeners();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) =>
    product.title.toLowerCase().contains(lowercaseQuery) ||
        product.description.toLowerCase().contains(lowercaseQuery)).toList();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}