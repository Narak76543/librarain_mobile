import 'package:flutter/material.dart';

import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel(this._orderRepository);

  final OrderRepository _orderRepository;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'All';

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<OrderModel> get filteredOrders {
    if (_selectedStatus == 'All') {
      return List.unmodifiable(_orders);
    }
    return _orders
        .where((order) => order.status.toLowerCase() == _selectedStatus.toLowerCase())
        .toList();
  }
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      _orders = await _orderRepository.getOrders();
      _error = null;
    } on OrderException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
