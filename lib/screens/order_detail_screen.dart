import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipper_ui/providers/delivery_provider.dart';
import 'package:shipper_ui/route.dart';
import 'package:shipper_ui/screens/delivery_map_screen.dart';
import 'package:shipper_ui/utils/colors.dart';
import 'package:shipper_ui/utils/utils.dart';
import 'package:shipper_ui/widgets/custom_button.dart';
import 'package:shipper_ui/widgets/dash_vertical_line.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Order Details"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // customer information
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      "Customer Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        "https://static0.srcdn.com/wordpress/wp-content/uploads/2025/02/avatar-the-last-airbender-had-the-perfect-ending-but-i-m-happy-that-we-re-getting-more1.jpg?w=1600&h=900&fit=crop",
                      ),
                    ),
                    title: Text(
                      "John Doe",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Delivery * 0342134123432"),
                    trailing: CircleAvatar(
                      backgroundColor: iconColor,
                      child: Icon(Icons.phone, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tenderCoconut,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(text: "Tender Coconut (Normal) "),
                              TextSpan(
                                text: " * 4",
                                style: TextStyle(color: Colors.black38),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.credit_card_outlined),
                        SizedBox(width: 10),
                        Text(
                          "320",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.check_circle_sharp, color: iconColor),
                        SizedBox(width: 10),
                        Text(
                          "Paid",
                          style: TextStyle(
                            fontSize: 16,
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              height: 80,
                              child: DashVerticalLine(
                                dashHeight: 5,
                                dashGap: 5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pickup Location",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text("", style: TextStyle(fontSize: 13)),
                              SizedBox(height: 2),
                              Text(
                                "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: iconColor,
                          child: Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 20),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.red.shade50,
                          child: Transform.rotate(
                            angle: -pi / 4,
                            child: Icon(Icons.send, color: buttonMainColor),
                          ),
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
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text("", style: TextStyle(fontSize: 13)),
                              SizedBox(height: 2),
                              Text(
                                "John Doe",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.red.shade50,
                          child: Transform.rotate(
                            angle: -pi / 4,
                            child: Icon(
                              Icons.send,
                              size: 18,
                              color: buttonMainColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<DeliveryProvider>(
        builder: (context, provider, child) {
          return Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: provider.status == DeliveryStatus.orderAccepted
                  ? CustomButton(
                      title: "Start Pickup",
                      onPressed: () {
                        context.read<DeliveryProvider>().startPickup();
                        NavigationHelper.push(context, DeliveryMapScreen());
                      },
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            color: declineOrder,
                            textColor: Colors.black54,
                            title: "Decline Order",
                            onPressed: () {
                              context.read<DeliveryProvider>().rejectOrder();
                              Navigator.pop(context);
                              showAppSnackbar(
                                context: context,
                                type: SnackbarType.error,
                                description: "Order is not accepted",
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            title: "Accept Order",
                            onPressed: () {
                              context.read<DeliveryProvider>().acceptOrder();
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
