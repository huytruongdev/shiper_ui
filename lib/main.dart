import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipper_ui/provider/current_location_provider.dart';
import 'package:shipper_ui/provider/delivery_provider.dart';
import 'package:shipper_ui/screen/app_main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>CurrentLocationProvider()),
        ChangeNotifierProvider(create: (_)=>DeliveryProvider()),

      ],
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppMainScreen(),
      ),
    );
  }
}
