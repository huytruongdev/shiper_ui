import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Vẫn cần import package này để dùng Consumer bên trong các Tab
import 'package:shipper_ui/providers/driver_orders_provider.dart';
import 'package:shipper_ui/utils/colors.dart';
import 'package:shipper_ui/widgets/order_list_tab.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý đơn hàng"),
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrderListTab(isMyOrder: false), 
          OrderListTab(isMyOrder: true),
        ],
      ),
    );
  }
}