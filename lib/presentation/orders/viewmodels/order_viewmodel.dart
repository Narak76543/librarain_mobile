import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/di/injection.dart';

class OrderViewModel extends ChangeNotifier {
  final _repo = sl<OrderRepository>();

  List<OrderModel>    orders       = [];
  OrderSummaryModel?  summary;
  bool                isLoading    = false;
  String              errorMessage = '';

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      orders = await _repo.getOrders();
    } catch (e) {
      errorMessage = 'Failed to load orders';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderSummary(String orderId) async {
    isLoading = true;
    summary   = null;
    notifyListeners();
    try {
      summary = await _repo.getOrderSummary(orderId);
    } catch (e) {
      errorMessage = 'Failed to load order summary';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();
    try {
      await _repo.cancelOrder(orderId);
      // Reload summary if it's the one we just cancelled
      if (summary?.orderId == orderId) {
        await loadOrderSummary(orderId);
      }
      // Also reload orders list so history is updated
      await loadOrders();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
