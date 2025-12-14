import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shipper_ui/models/order_model.dart';
import 'package:shipper_ui/services/driver_order_service.dart';
import 'package:shipper_ui/services/socket_service.dart';
import 'package:shipper_ui/utils/globals.dart';

class DriverOrdersProvider extends ChangeNotifier {
  final DriverOrderService _service = DriverOrderService();
  final SocketService _socketService = SocketService();
  
  List<OrderModel> availableOrders = [];
  List<OrderModel> myOrders = [];
  
  bool isLoadingAvailable = false;
  bool isLoadingMyOrders = false;
  String? currentShipperId;

  Future<void> init() async {
    await _loadShipperId();
    refreshAll();
    _listenToSocketEvents();
  }

  void _listenToSocketEvents() {
    _socketService.initSocket();
    final socket = _socketService.getSocket();

    if (socket == null) return;

    socket.on('new_order_available', (data) {
      fetchAvailableOrders(isSilent: true);
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.notifications_active, color: Colors.white),
              SizedBox(width: 10),
              Text("Có đơn hàng mới! Kiểm tra ngay.", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    });
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

  Future<void> fetchAvailableOrders({bool isSilent = false}) async {
    if (!isSilent) {
      isLoadingAvailable = true;
      notifyListeners();
    }
    
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

  @override
  void dispose() {
    _socketService.getSocket()?.off('new_order_available');
    super.dispose();
  }
}