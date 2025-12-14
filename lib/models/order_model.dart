import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shipper_ui/models/order_item_model.dart';

class OrderModel {
  final String? id; 
  final String userId; 
  final List<OrderItem> items;
  final int totalQuantity;
  final int price;
  final LatLng pickupLocation;
  final LatLng deliveryLocation;
  final String pickupAddress;
  final String deliveryAddress;
  final String? status;
  final String? createdAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalQuantity,
    required this.price,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.status,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "items": items.map((e) => e.toJson()).toList(),
      "totalQuantity": totalQuantity,
      "price": price,
      "pickupLocation": {
        "lat": pickupLocation.latitude,
        "lng": pickupLocation.longitude,
      },
      "deliveryLocation": {
        "lat": deliveryLocation.latitude,
        "lng": deliveryLocation.longitude,
      },
      "pickupAddress": pickupAddress,
      "deliveryAddress": deliveryAddress,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json["id"] ?? json["_id"],
      userId: json["userId"],
      items: (json["items"] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      totalQuantity: json["totalQuantity"],
      price: json["price"],
      pickupLocation: LatLng(
        json["pickupLocation"]["lat"],
        json["pickupLocation"]["lng"],
      ),
      deliveryLocation: LatLng(
        json["deliveryLocation"]["lat"],
        json["deliveryLocation"]["lng"],
      ),
      pickupAddress: json["pickupAddress"],
      deliveryAddress: json["deliveryAddress"],
      status: json["status"],
      createdAt: json['createdAt']
    );
  }
}
