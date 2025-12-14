import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Cần import cái này
import 'package:shipper_ui/models/order_model.dart';
import 'package:shipper_ui/services/driver_order_service.dart';
import 'package:shipper_ui/services/socket_service.dart'; // Dùng lại service socket cũ

class DriverTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const DriverTrackingScreen({super.key, required this.order});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final SocketService _socketService = SocketService();
  final DriverOrderService _orderService = DriverOrderService();

  StreamSubscription<Position>? _positionStream;

  late LatLng shopLocation;
  late LatLng userLocation;
  LatLng driverCurrentLocation = const LatLng(10.762622, 106.660172); // Default
  
  Set<Marker> _markers = {};
  String currentStatus = "";

  @override
  void initState() {
    super.initState();
    shopLocation = widget.order.pickupLocation;
    userLocation = widget.order.deliveryLocation;
    currentStatus = widget.order.status ?? "accepted";

    _setupMarkers();
    // _drawStaticRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTracking();
    });
  }

  void _setupMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId("shop"),
        position: shopLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "Lấy hàng ở đây"),
      ),
      Marker(
        markerId: const MarkerId("user"),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Giao cho khách"),
      ),
    };
    setState(() {});
  }

  Future<void> _startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _socketService.initSocket();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Di chuyển 5m thì cập nhật
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      LatLng newPos = LatLng(position.latitude, position.longitude);
      _animateCamera(newPos, position.heading);

      _socketService.getSocket()?.emit('driver_send_location', {
        'orderId': widget.order.id,
        'lat': position.latitude,
        'lng': position.longitude,
        'heading': position.heading,
      });
    });
  }

  Future<void> _animateCamera(LatLng pos, double heading) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: pos, zoom: 17, bearing: heading),
    ));
  }

  void _onStatusButtonPressed() async {
    String nextStatus = "";
    String buttonText = "";

    if (currentStatus == "accepted") {
      nextStatus = "shipping";
      buttonText = "Bắt đầu giao hàng";
    } else if (currentStatus == "shipping") {
      nextStatus = "delivered"; // Giao xong
      buttonText = "Hoàn thành đơn hàng";
    } else {
      return;
    }

    bool success = await _orderService.updateOrderStatus(widget.order.id!, nextStatus);

    if (success) {
      setState(() {
        currentStatus = nextStatus;
      });
      
      if (nextStatus == "delivered") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đơn hàng hoàn tất!")));
        Navigator.pop(context); // Quay về trang chủ
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(buttonText)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi cập nhật trạng thái")));
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String btnLabel = "Đã lấy hàng";
    Color btnColor = Colors.blue;

    if (currentStatus == "shipping") {
      btnLabel = "Xác nhận đã giao (Hoàn thành)";
      btnColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: Text("Đang giao đơn #${widget.order.id?.substring(0, 6)}")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: shopLocation, zoom: 14),
            markers: _markers,
            myLocationEnabled: true,
            onMapCreated: (c) => _controller.complete(c),
          ),
          
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Trạng thái: $currentStatus", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Đến: ${widget.order.deliveryAddress}", maxLines: 2),
                  const SizedBox(height: 20),
                  
                  // Nút bấm cập nhật trạng thái
                  ElevatedButton(
                    onPressed: _onStatusButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(btnLabel, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}