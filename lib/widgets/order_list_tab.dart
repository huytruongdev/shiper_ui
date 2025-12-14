import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipper_ui/providers/driver_orders_provider.dart';
import 'package:shipper_ui/screens/driver_tracking_screen.dart';
import 'package:shipper_ui/widgets/order_item_card.dart';

class OrderListTab extends StatefulWidget {
  final bool isMyOrder;
  const OrderListTab({super.key, required this.isMyOrder});

  @override
  State<OrderListTab> createState() => _OrderListTabState();
}

class _OrderListTabState extends State<OrderListTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<DriverOrdersProvider>(
      builder: (context, provider, child) {
        final orders = widget.isMyOrder ? provider.myOrders : provider.availableOrders;
        final isLoading = widget.isMyOrder ? provider.isLoadingMyOrders : provider.isLoadingAvailable;

        if (isLoading) return const Center(child: CircularProgressIndicator());
        
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  widget.isMyOrder ? "Bạn chưa nhận đơn nào" : "Không có đơn mới",
                  style: const TextStyle(color: Colors.grey)
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: widget.isMyOrder ? provider.fetchMyOrders : provider.fetchAvailableOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final order = orders[i];
              return OrderItemCard(
                order: order,
                isMyOrder: widget.isMyOrder,
                onActionPressed: () async {
                  if (widget.isMyOrder) {
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DriverTrackingScreen(order: order)),
                      ).then((_) => provider.refreshAll());
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => const Center(child: CircularProgressIndicator()),
                    );

                    bool success = await provider.acceptOrder(order.id!);

                    if (!context.mounted) return; 
                    Navigator.of(context).pop(); 

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nhận đơn thành công!"),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Thất bại. Đơn có thể đã bị người khác nhận."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}