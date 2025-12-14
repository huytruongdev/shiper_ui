import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shipper_ui/models/order_model.dart';
import 'package:shipper_ui/services/driver_order_service.dart';

class DriverOrdersProvider extends ChangeNotifier {
  final DriverOrderService _service = DriverOrderService();
  
  List<OrderModel> availableOrders = [];
  List<OrderModel> myOrders = [];
  
  bool isLoadingAvailable = false;
  bool isLoadingMyOrders = false;
  String? currentShipperId;

  Future<void> init() async {
    await _loadShipperId();
    refreshAll();
  }

  Future<void> _loadShipperId() async {
    final prefs = await SharedPreferences.getInstance();
    currentShipperId = prefs.getString('userId') ?? "u003"; 
    notifyListeners();
  }

  Future<void> refreshAll() async {
    if (currentShipperId == null) return;
    
    await Future.wait([
      fetchAvailableOrders(),
      fetchMyOrders(),
    ]);
  }

  Future<void> fetchAvailableOrders() async {
    isLoadingAvailable = true;
    notifyListeners();
    
    try {
      availableOrders = await _service.getPendingOrders();
    } catch (e) {
      print("Lỗi lấy đơn mới: $e");
    } finally {
      isLoadingAvailable = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyOrders() async {
    if (currentShipperId == null) return;

    isLoadingMyOrders = true;
    notifyListeners();

    try {
      myOrders = await _service.getMyOrders(currentShipperId!);
    } catch (e) {
      print("Lỗi lấy đơn của tôi: $e");
    } finally {
      isLoadingMyOrders = false;
      notifyListeners();
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    if (currentShipperId == null) return false;

    bool success = await _service.acceptOrder(orderId, currentShipperId!);
    
    if (success) {
      await refreshAll(); 
    }
    return success;
  }
}