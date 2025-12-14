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

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "name": name,
      "quantity": quantity,
      "price": price,
    };
  }
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json["productId"] ?? "",
      name: json["name"] ?? "",
      quantity: json["quantity"] ?? 0,
      price: json["price"] ?? 0,
    );
  }
}