import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shipper_ui/models/order_model.dart';
import 'package:shipper_ui/services/driver_order_service.dart';
import 'package:shipper_ui/services/socket_service.dart';

class StatusConfig {
  final String label;
  final Color color;
  final String nextStatus;
  final bool isFinalStep;

  const StatusConfig({
    required this.label,
    required this.color,
    required this.nextStatus,
    this.isFinalStep = false,
  });
}

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
  Set<Marker> _markers = {};
  
  String currentStatus = "";
  bool _isApiCalling = false;
  
  double? _currentDistance; 

  final Map<String, StatusConfig> _statusConfigs = {
    'accepted': const StatusConfig(
      label: "Bắt đầu giao hàng",
      color: Colors.blue,
      nextStatus: 'shipping',
    ),
    'shipping': const StatusConfig(
      label: "Đã tới nơi",
      color: Colors.orange,
      nextStatus: 'arrived',
    ),
    'arrived': const StatusConfig(
      label: "Hoàn thành đơn hàng",
      color: Colors.green,
      nextStatus: 'delivered',
      isFinalStep: true,
    ),
  };

  @override
  void initState() {
    super.initState();
    shopLocation = widget.order.pickupLocation;
    userLocation = widget.order.deliveryLocation;
    
    currentStatus = widget.order.status ?? "accepted";

    _setupMarkers();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTracking();
    });
  }

  void _setupMarkers() {
    setState(() {
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
    });
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
      distanceFilter: 5, 
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      LatLng driverPos = LatLng(position.latitude, position.longitude);
      
      _animateCamera(driverPos, position.heading);
      
      _socketService.getSocket()?.emit('driver_send_location', {
        'orderId': widget.order.id,
        'lat': position.latitude,
        'lng': position.longitude,
        'heading': position.heading,
      });

      // Tính toán và lưu lại khoảng cách hiện tại
      double distance = Geolocator.distanceBetween(
        driverPos.latitude, driverPos.longitude,
        userLocation.latitude, userLocation.longitude,
      );
      
      _currentDistance = distance;

      // Check tự động đến nơi
      _checkAutoArrival(distance);
    });
  }

  void _checkAutoArrival(double distance) async {
    // Chỉ tự động khi đang đi giao
    if (currentStatus != 'shipping') return;
    if (_isApiCalling) return;

    if (distance < 100) {
      await _executeStatusChange(targetStatus: 'arrived');
    }
  }

  Future<void> _animateCamera(LatLng pos, double heading) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: pos, zoom: 17, bearing: heading),
    ));
  }

  Future<void> _executeStatusChange({String? targetStatus}) async {
    if (_isApiCalling) return;

    String nextStatus = targetStatus ?? _statusConfigs[currentStatus]?.nextStatus ?? "";
    if (nextStatus.isEmpty) return;

    setState(() => _isApiCalling = true);

    bool success = await _orderService.updateOrderStatus(widget.order.id!, nextStatus);

    if (!mounted) return;

    if (success) {
      setState(() {
        currentStatus = nextStatus;
      });

      if (nextStatus == 'arrived') {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Bạn đã tới điểm giao!"), backgroundColor: Colors.green),
         );
      } else if (nextStatus == 'delivered') {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Đơn hàng hoàn tất!")),
         );
         Navigator.pop(context);
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi cập nhật trạng thái"), backgroundColor: Colors.red),
      );
    }

    if (mounted) {
      setState(() => _isApiCalling = false);
    }
  }

  void _onStatusButtonPressed() {
    if (currentStatus == 'shipping' || currentStatus == 'arrived') {
      
      // Nếu chưa lấy được vị trí GPS
      if (_currentDistance == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đang định vị... Vui lòng đợi!"), backgroundColor: Colors.orange),
        );
        return;
      }

      // Nếu khoảng cách lớn hơn 100m
      if (_currentDistance! > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bạn còn cách điểm giao ${_currentDistance!.toStringAsFixed(0)}m. Hãy đến gần hơn (<100m) để xác nhận!"), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    _executeStatusChange();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _statusConfigs[currentStatus];
    final bool showButton = config != null;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Trạng thái:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Chip(
                        label: Text(currentStatus.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: config?.color ?? Colors.grey,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Giao Đến: ${widget.order.deliveryAddress}", maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 20),
                  
                  if (showButton)
                    ElevatedButton(
                      onPressed: _isApiCalling ? null : _onStatusButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: config!.color,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isApiCalling 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(config.label, style: const TextStyle(color: Colors.white, fontSize: 16)),
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