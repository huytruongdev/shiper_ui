// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shipper_ui/models/order_model.dart';

// class ShipperOrderService {
//   final String _baseUrl = "http://10.0.2.2:3000/orders"; 

//   Future<List<OrderModel>> getPendingOrders() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/pending'),
//         headers: <String, String>{
          
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = jsonDecode(response.body);
//         return jsonList.map((json) => OrderModel.fromJson(json)).toList();
//       } else {
//         print("Lỗi khi lấy đơn hàng chờ: Mã trạng thái ${response.statusCode}");
//         return []; 
//       }
//     } catch (e) {
//       print("Lỗi kết nối mạng khi lấy đơn hàng chờ: $e");
//       return []; 
//     }
//   }

//   Future<OrderModel?> acceptOrder(String orderId, String shipperId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$_baseUrl/accept/$orderId'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode({'shipperId': shipperId}),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//         print("Đơn hàng $orderId đã được shipper $shipperId nhận.");
//         return OrderModel.fromJson(json);
//       } else {
//         print("Lỗi khi nhận đơn hàng: Mã trạng thái ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("Lỗi kết nối mạng khi nhận đơn hàng: $e");
//       return null;
//     }
//   }
// }