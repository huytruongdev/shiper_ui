import 'package:flutter/material.dart';
import 'package:shipper_ui/route.dart';
import 'package:shipper_ui/screen/order_detail_screen.dart';
import 'package:shipper_ui/utils/colors.dart';
import 'package:shipper_ui/utils/utils.dart';
import 'package:shipper_ui/widgets/custom_button.dart';
import 'package:shipper_ui/widgets/dash_vertical_line.dart';

class OrderCard extends StatelessWidget {
  final VoidCallback onTapClose;

  const OrderCard({
    super.key, 
    required this.onTapClose, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "New Order Available",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 15),
                Text(
                  " 320",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: buttonMainColor,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {

                    // Navigator.pop(context);
                    onTapClose();
                  },
                  child: Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.white,
                  elevation: 1,
                  shadowColor: Colors.black26,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.brown[100],
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(tenderCoconut),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(text: "Tender Coconut (Nomall)"),
                            TextSpan(
                              text: " * 4",
                              style: TextStyle(color: Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          color: Colors.black54,
                          size: 20,
                        ),
                        SizedBox(
                          height: 35,
                          child: DashVerticalLine(dashHeight: 6, dashWidth: 5),
                        ),
                      ],
                    ),
                    SizedBox(width: 4),
                    pickupAndDeliveryInfo(
                      "Pick up - ",
                      "Ly Tu Trong Colloge",
                      "Green Valley Coconut Store",
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: buttonMainColor,
                      size: 22,
                    ),
                    SizedBox(width: 5),
                    pickupAndDeliveryInfo(
                      "Delivery - ",
                      "Thong Nhat Hopistal - 300m from the pickup location",
                      "Tri Ú",
                    ),
                  ],
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.maxFinite,
                  child: CustomButton(
                    title: "View order details",
                    onPressed: () {
                      NavigationHelper.push(context, OrderDetailScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded pickupAndDeliveryInfo(title, address, subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Expanded(
                flex: 9,
                child: Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ),
            ],
          ),
          Text(subtitle, style: TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }
}
