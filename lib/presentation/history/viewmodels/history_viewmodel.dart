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
  DateTime? _selectedDate;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  
  List<OrderModel> get filteredOrders {
    var result = _orders;
    
    if (_selectedStatus != 'All') {
      result = result
          .where((order) => order.status.toLowerCase() == _selectedStatus.toLowerCase())
          .toList();
    }
    
    if (_selectedDate != null) {
      result = result.where((order) {
        try {
          final orderDate = DateTime.parse(order.createdAt).toLocal();
          return orderDate.year == _selectedDate!.year &&
                 orderDate.month == _selectedDate!.month &&
                 orderDate.day == _selectedDate!.day;
        } catch (e) {
          return true;
        }
      }).toList();
    }
    
    return List.unmodifiable(result);
  }
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;
  DateTime? get selectedDate => _selectedDate;

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    _selectedDate = date;
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
