import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shipper_ui/models/order_model.dart';
import 'package:shipper_ui/utils/colors.dart'; 

class OrderItemCard extends StatelessWidget {
  final OrderModel order;
  final bool isMyOrder;
  final VoidCallback onActionPressed;

  const OrderItemCard({
    super.key,
    required this.order,
    required this.isMyOrder,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool isDelivered = order.status == 'delivered';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${order.id?.substring(0, 6).toUpperCase() ?? '...'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isMyOrder)
                  _buildStatusBadge(order.status ?? 'Unknown'),
                if (!isMyOrder)
                  Text(
                    NumberFormat.currency(locale: 'vi', symbol: 'đ').format(order.price),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const Divider(),
            
            _buildInfoRow("Từ:", order.pickupAddress),
            const SizedBox(height: 5),
            _buildInfoRow("Đến:", order.deliveryAddress),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isDelivered ? null : onActionPressed,
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMyOrder ? Colors.blue : buttonMainColor,
                  
                  disabledBackgroundColor: Colors.grey[400],
                  disabledForegroundColor: Colors.white,
                  
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _getButtonLabel(isDelivered),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Hàm phụ để lấy chữ hiển thị trên nút
  String _getButtonLabel(bool isDelivered) {
    if (isDelivered) {
      return "Đã giao thành công";
    }
    if (isMyOrder) {
      return "Tiếp tục giao hàng";
    }
    return "Nhận đơn ngay";
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor = Colors.blue;
    Color textColor = Colors.blue;

    if (status == 'delivered') {
      badgeColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(5)
      ),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 40, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
        Expanded(child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}