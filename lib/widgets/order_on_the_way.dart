import 'package:flutter/material.dart';
import 'package:shipper_ui/models/order_model.dart';
import 'package:shipper_ui/providers/delivery_provider.dart';
import 'package:shipper_ui/utils/colors.dart';
import 'package:shipper_ui/widgets/custom_button.dart';

class OrderOnTheWay extends StatelessWidget {
  final OrderModel order;
  final DeliveryStatus status;
  final VoidCallback? onButtonPressed;
  const OrderOnTheWay({
    super.key,
    required this.order,
    required this.status,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black26,
            ),
          ),
          ListTile(
            leading: Icon(_getPickupIcon(), color: _getPickupIconColor()),
            title: Text(
              "Pickup Location",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(order.pickupAddress),
            trailing: CircleAvatar(
              radius: 18,
              backgroundColor: iconColor,
              child: Icon(Icons.phone, color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(_getDeliveryIcon(), color: _getDeliveryIconColor()),
            title: Text(
              "Delivery - ${order.id}",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(order.deliveryAddress),
            trailing: CircleAvatar(
              radius: 18,
              backgroundColor: iconColor,
              child: Icon(Icons.phone, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(width: double.maxFinite, child: _buttonStyle()),
          ),
        ],
      ),
    );
  }

  Widget _buttonStyle() {
    switch (status) {
      case DeliveryStatus.destinationReached:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: GestureDetector(
            onTap: _isButtonEnabled()
                ? (onButtonPressed ?? () {})
                : () {},
                    child:
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: pickedUpColor.withAlpha(170),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(30),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 17,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _getButtonColor(),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(30),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getButtonTitle(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        );
      default:
        return CustomButton(
          title: _getButtonTitle(),
          onPressed: _isButtonEnabled() ? (onButtonPressed ?? () {}) : () {},
          color: _getButtonColor(),
        );
    }
  }

  Color _getButtonColor() {
    switch (status) {
      case DeliveryStatus.pickingUp:
        return pickedUpColor;
      case DeliveryStatus.enRoute:
        return Colors.orange.withAlpha(150);
      case DeliveryStatus.destinationReached:
        return pickedUpColor;
      case DeliveryStatus.markingAsDelivered:
        return buttonMainColor;
      case DeliveryStatus.delivered:
      default:
        return buttonMainColor;
    }
  }

  String _getButtonTitle() {
    switch (status) {
      case DeliveryStatus.pickingUp:
        return "Mark as Picked Up";
      case DeliveryStatus.enRoute:
        return "Delivering...";
      case DeliveryStatus.destinationReached:
        return "Mark as Destination Reached";
      case DeliveryStatus.markingAsDelivered:
        return "Mark as Delivered";
      case DeliveryStatus.delivered:
        return "Marking as Delivered...";
      default:
        return "Start Pickup";
    }
  }

  bool _isButtonEnabled() {
    switch (status) {
      case DeliveryStatus.enRoute:
      case DeliveryStatus.delivered:
        return false;
      default:
        return true;
    }
  }

  IconData _getPickupIcon() {
    switch (status) {
      case DeliveryStatus.enRoute:
      case DeliveryStatus.destinationReached:
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      default:
        return Icons.radio_button_checked;
    }
  }

  Color _getPickupIconColor() {
    switch (status) {
      case DeliveryStatus.enRoute:
      case DeliveryStatus.destinationReached:
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
        return buttonMainColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getDeliveryIcon() {
    switch (status) {
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      default:
        return Icons.location_on_outlined;
    }
  }

  Color _getDeliveryIconColor() {
    switch (status) {
      case DeliveryStatus.markingAsDelivered:
      case DeliveryStatus.delivered:
        return buttonMainColor;
      default:
        return Colors.red;
    }
  }
}
