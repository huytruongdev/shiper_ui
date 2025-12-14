import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shipper_ui/models/order_model.dart'; // Đảm bảo bạn đã có model này

class DriverOrderService {
  final String baseUrl = "http://10.0.2.2:3000"; 

  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/pending'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi lấy đơn hàng: $e");
      return [];
    }
  }

  Future<List<OrderModel>> getMyOrders(String shipperId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/driver/$shipperId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi lấy đơn của tôi: $e");
      return [];
    }
  }

  Future<bool> acceptOrder(String orderId, String shipperId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/accept/$orderId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "shipperId": shipperId,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Thành công
      } else {
        print("Lỗi server: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/update-status/$orderId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "status": newStatus,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi cập nhật trạng thái: $e");
      return false;
    }
  }
}