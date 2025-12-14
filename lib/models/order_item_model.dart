class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final int price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  // Convert sang JSON để gửi lên Server
  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "name": name,
      "quantity": quantity,
      "price": price,
    };
  }

  // Convert từ JSON Server trả về thanh Object
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json["productId"] ?? "",
      name: json["name"] ?? "",
      quantity: json["quantity"] ?? 0,
      price: json["price"] ?? 0,
    );
  }
}