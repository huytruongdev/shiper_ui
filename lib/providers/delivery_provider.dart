import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shipper_ui/models/order_model.dart';

enum DeliveryStatus {
  waitingForAcceptance,
  orderAccepted,
  pickingUp,
  destinationReached,
  enRoute,
  markingAsDelivered,
  delivered,
  rejected,
}

class DeliveryProvider extends ChangeNotifier {
  DeliveryStatus _status = DeliveryStatus.waitingForAcceptance;
  OrderModel? _currentOrder;

  // --- SOCKET & LOCATION VARS ---
  IO.Socket? _socket;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Vị trí hiện tại của Shipper
  LatLng? _currentDeliveryBoyPosition;

  // Lịch sử đường đi (vẽ tới đâu hiển thị tới đó)
  List<LatLng> _traveledRoute = [];

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  // Getters
  DeliveryStatus get status => _status;
  OrderModel? get currentOrder => _currentOrder;
  LatLng? get currentDeliveryBoyPosition => _currentDeliveryBoyPosition;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get markers => _markers;

  void initSocket() {
    _socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket?.connect();

    _socket?.onConnect((_) {
      debugPrint('Connected to Socket Server');
      if (_currentOrder != null) {
        _socket?.emit('join_order', _currentOrder!.id);
      }
    });

    _socket?.onDisconnect((_) => debugPrint('Disconnected from Socket'));
  }

  void initializeOrder() {
    _currentOrder = OrderModel(
      totalQuantity: 4,
      price: 320,
      pickupLocation: LatLng(10.800669, 106.661126),
      deliveryLocation: LatLng(10.7965184,106.6557884),
      pickupAddress: "670 Cầu Vượt Cộng Hoà",
      deliveryAddress: "Cao Đẳng Lý Tự Trọng", 
      userId: '', 
      items: [],
    );
    
    // Setup marker ban đầu (Điểm đi và điểm đến)
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId("pickup"),
      position: _currentOrder!.pickupLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: "Điểm đi"),
    ));
    _markers.add(Marker(
      markerId: MarkerId("delivery"),
      position: _currentOrder!.deliveryLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: "Điểm đến"),
    ));

    _status = DeliveryStatus.waitingForAcceptance;
    
    initSocket();
    notifyListeners();
  }

  // --- 2. XỬ LÝ LOGIC ---

  void acceptOrder() {
    _status = DeliveryStatus.orderAccepted;
    notifyListeners();
  }

  void rejectOrder() {
    resetDelivery();
    _status = DeliveryStatus.rejected;
    notifyListeners();
  }

  void startPickup() {
    _status = DeliveryStatus.pickingUp;
    // Bắt đầu theo dõi vị trí thật ngay khi đi lấy hàng
    startRealtimeLocationTracking();
    notifyListeners();
  }

  void markAsPickedUp() {
    _status = DeliveryStatus.enRoute;
    // Xóa đường cũ (nếu có đoạn đi từ nhà đến chỗ lấy hàng) để vẽ hành trình giao hàng mới
    _traveledRoute.clear(); 
    _polylines.clear();
    notifyListeners();
  }

  void markDestinationReached() {
    _status = DeliveryStatus.destinationReached;
    stopTracking(); // Dừng theo dõi GPS
    notifyListeners();
  }

  void markAdDelivered() {
    _status = DeliveryStatus.markingAsDelivered;
    notifyListeners();
  }

  void completeDelivery() {
    _status = DeliveryStatus.delivered;
    notifyListeners();
  }
  
  Future<void> startRealtimeLocationTracking() async {
    // A. Kiểm tra và xin quyền
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      return;
    }

    // B. Cấu hình luồng vị trí
    // Khi chạy Emulator Route, vị trí thay đổi rất nhanh, nên ta để filter thấp
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2, 
    );

    // C. Lắng nghe stream
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      LatLng currentPos = LatLng(position.latitude, position.longitude);
      double heading = position.heading; // Hướng di chuyển (Emulator tự tính)

      debugPrint("📍 Driver moved: ${currentPos.latitude}, ${currentPos.longitude}");

      // 1. Cập nhật UI trên máy Driver ngay lập tức
      _currentDeliveryBoyPosition = currentPos;
      _updateMarkerAndPolyline(currentPos, heading);

      // 2. Gửi toạ độ lên Socket Server (để App Khách Hàng nhận được)
      if (_socket != null && _socket!.connected && _currentOrder != null) {
        _socket!.emit('driver_send_location', {
          'orderId': _currentOrder!.id,
          'lat': position.latitude,
          'lng': position.longitude,
          'heading': heading,
        });
      }

      _checkArrival(currentPos);
    });
  }

  void _checkArrival(LatLng currentPos) {
    if (_currentOrder == null) return;

    LatLng targetLocation;
    
    // Xác định đích đến dựa trên trạng thái hiện tại
    if (_status == DeliveryStatus.pickingUp) {
      targetLocation = _currentOrder!.pickupLocation;
    } else if (_status == DeliveryStatus.enRoute) {
      targetLocation = _currentOrder!.deliveryLocation;
    } else {
      return; // Các trạng thái khác không cần check
    }

    // Tính khoảng cách giữa Xe và Đích (đơn vị: mét)
    double distanceInMeters = Geolocator.distanceBetween(
      currentPos.latitude, 
      currentPos.longitude, 
      targetLocation.latitude, 
      targetLocation.longitude
    );

    debugPrint("Distance to target: ${distanceInMeters.toStringAsFixed(2)} meters");

    // Nếu khoảng cách < 50 mét -> Coi như đã đến nơi
    if (distanceInMeters < 50) {
       if (_status == DeliveryStatus.enRoute) {
         debugPrint("✅ Arrived at Destination!");
         markDestinationReached(); // Tự động đổi status
       }
    }
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  void _updateMarkerAndPolyline(LatLng pos, double heading) {
    // 1. Cập nhật Marker Shipper
    _markers.removeWhere((m) => m.markerId.value == 'deliveryBoy');
    _markers.add(
      Marker(
        markerId: MarkerId("deliveryBoy"),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: heading, 
        anchor: Offset(0.5, 0.5),
        zIndex: 2, 
        infoWindow: InfoWindow(title: "You"),
      ),
    );

    // 2. Vẽ đường đi thực tế (Trail)
    // Chỉ thêm điểm mới vào đường vẽ
    _traveledRoute.add(pos);
    
    _polylines.removeWhere((p) => p.polylineId.value == 'route_traveled');
    _polylines.add(
      Polyline(
        polylineId: PolylineId("route_traveled"),
        points: List.from(_traveledRoute),
        color: Colors.blue,
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );

    notifyListeners();
  }

  void resetDelivery() {
    stopTracking();
    _socket?.disconnect(); 
    _socket?.dispose();
    _socket = null;

    _status = DeliveryStatus.waitingForAcceptance;
    _traveledRoute.clear();
    _polylines.clear();
    _markers.clear();
    _currentDeliveryBoyPosition = null;
    initializeOrder(); // Reset lại data giả lập
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    _socket?.dispose();
    super.dispose();
  }
}