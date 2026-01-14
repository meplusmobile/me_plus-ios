import 'dart:io';
import 'package:flutter/material.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/data/models/order_model.dart';
import 'package:me_plus/data/repositories/market_repository.dart';

class MarketOwnerProvider extends ChangeNotifier {
  final MarketRepository _repository = MarketRepository();

  List<StoreReward> _items = [];
  List<OrderModel> _thisMonthOrders = [];
  List<OrderModel> _lastMonthOrders = [];
  bool _isLoading = false;
  String? _error;

  List<StoreReward> get items => _items;
  List<OrderModel> get thisMonthOrders => _thisMonthOrders;
  List<OrderModel> get lastMonthOrders => _lastMonthOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItems([
    String sortType = 'sortBy',
    String sortValue = 'oldest',
  ]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getMarketItems(
        sortType: sortType,
        sortValue: sortValue,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(String name, int price, File? image) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.addMarketItem(name, price, image);
      await loadItems('sortBy', 'newest'); // Refresh list with newest first
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _repository.deleteMarketItem(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateItem(int id, String name, int price, File? image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateMarketItem(id, name, price, image);
      await loadItems(); // Refresh list
    } catch (e) {
      _error = e.toString();
      rethrow; // Re-throw to let the UI handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadThisMonthOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _thisMonthOrders = await _repository.getThisMonthOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLastMonthOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastMonthOrders = await _repository.getLastMonthOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveOrder(int orderId) async {
    try {
      await _repository.approveOrder(orderId);
      _thisMonthOrders.removeWhere((order) => order.id == orderId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectOrder(int orderId) async {
    try {
      await _repository.rejectOrder(orderId);
      _thisMonthOrders.removeWhere((order) => order.id == orderId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
