import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipper_ui/providers/driver_orders_provider.dart';
import 'package:shipper_ui/screens/app_main_screen.dart';
import 'package:shipper_ui/utils/globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverOrdersProvider()..init()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        home: const AppMainScreen(),
      ),
    );
  }
}
