import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipper_ui/providers/driver_orders_provider.dart'; // Import provider
import 'package:shipper_ui/screens/driver_tracking_screen.dart';
import 'package:shipper_ui/widgets/order_item_card.dart'; // Import widget card
import 'package:shipper_ui/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _buildListState(
    bool isLoading,
    bool isEmpty,
    String emptyMsg,
    Widget content,
  ) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(emptyMsg, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Provider ở đây
    return ChangeNotifierProvider(
      create: (_) => DriverOrdersProvider()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý đơn hàng"),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: buttonMainColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: buttonMainColor,
            tabs: const [
              Tab(text: "Đơn mới"),
              Tab(text: "Đã nhận"),
            ],
          ),
        ),

        body: Consumer<DriverOrdersProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: AVAILABLE
                RefreshIndicator(
                  onRefresh: provider.fetchAvailableOrders,
                  child: _buildListState(
                    provider.isLoadingAvailable,
                    provider.availableOrders.isEmpty,
                    "Không có đơn mới",
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.availableOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final order = provider.availableOrders[i];
                        return OrderItemCard(
                          order: order,
                          isMyOrder: false,
                          onActionPressed: () async {
                            // Xử lý nhận đơn
                            _showLoading(context);
                            bool success = await provider.acceptOrder(
                              order.id!,
                            );
                            Navigator.pop(context); // Tắt loading

                            if (success) {
                              _tabController.animateTo(1); // Chuyển tab
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Nhận đơn thành công!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Lỗi nhận đơn"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),

                // TAB 2: MY ORDERS
                RefreshIndicator(
                  onRefresh: provider.fetchMyOrders,
                  child: _buildListState(
                    provider.isLoadingMyOrders,
                    provider.myOrders.isEmpty,
                    "Bạn chưa nhận đơn nào",
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.myOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final order = provider.myOrders[i];
                        return OrderItemCard(
                          order: order,
                          isMyOrder: true,
                          onActionPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DriverTrackingScreen(order: order),
                              ),
                            ).then((_) {
                              // Khi quay lại (pop), refresh lại list để cập nhật trạng thái mới
                              provider.refreshAll();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
