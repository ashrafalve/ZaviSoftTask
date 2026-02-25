import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/fakestore_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _loading = false;

  List<Product> get products => _products;
  bool get loading => _loading;

  final FakestoreService _service = FakestoreService();

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();
    _products = await _service.fetchProducts();
    _loading = false;
    notifyListeners();
  }
}