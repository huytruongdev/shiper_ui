import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  List<LatLng> _routePoints = [];
  int _currentStep = 0;
  LatLng? _currentDeliveryBoyPosition;
  Timer? _animationTimer;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  DeliveryStatus get status => _status;
  OrderModel? get currentOrder => _currentOrder;
  List<LatLng> get routePoints => _routePoints;
  LatLng? get currentDeliveryBoyPosition => _currentDeliveryBoyPosition;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get markers => _markers;

  static const List<LatLng> _preCalculatedRoute = [
    LatLng(27.7033, 85.3066),
    LatLng(27.7020, 85.3078),
    LatLng(27.7005, 85.3101),
    LatLng(27.6980, 85.3135),
    LatLng(27.6950, 85.3160),
    LatLng(27.6915, 85.3190),
    LatLng(27.6880, 85.3220),
    LatLng(27.6845, 85.3235),
    LatLng(27.6810, 85.3245),
    LatLng(27.6780, 85.3250),
    LatLng(27.6750, 85.3252),
    LatLng(27.6710, 85.3250),
  ];

  void initializeOrder() {
    _currentOrder = OrderModel(
      id: "ORD123",
      customerName: "John Doe",
      customerPhone: "014542765",
      item: "Tender Coconut (Normal)",
      quantity: 4,
      price: 320,
      pickupLocation: LatLng(27.7033, 85.3066),
      deliveryLocation: LatLng(27.6710, 85.3250),
      pickupAddress: "Kathmandu Durbar Square",
      deliveryAddress: "Patan Durbar Square",
    );
    _status = DeliveryStatus.waitingForAcceptance;
    notifyListeners();
  }

  void acceptOrder() {
    _status = DeliveryStatus.orderAccepted;
    notifyListeners();

    Timer(Duration(seconds: 5), () {
      _generateRoutePoints();
      _setupMapOverlays();
      notifyListeners();
    });
  }

  void rejectOrder() {
    _status = DeliveryStatus.rejected;
    _routePoints.clear();
    _polylines.clear();
    _markers.clear();
    _currentDeliveryBoyPosition = null;
    _stopAnimation();
    notifyListeners();
  }

  void startPickup() {
    _status = DeliveryStatus.pickingUp;
    _currentDeliveryBoyPosition = _currentDeliveryBoyPosition;
    _updateDeliveryBoyMarker();
  }

  void markAsPickedUp() {
    _status = DeliveryStatus.enRoute;
    _startDeliverySimulation();
  }

  void markDestinationReached() {
    _status = DeliveryStatus.destinationReached;
    _stopAnimation();
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

  void _generateRoutePoints() {
    _routePoints = _preCalculatedRoute;
    _currentDeliveryBoyPosition = _routePoints[0];
    _currentStep = 0;
  }

  void _setupMapOverlays() {
    _polylines.add(
      Polyline(
        polylineId: PolylineId("delivery"),
        points: _routePoints,
        color: Colors.blue,
        width: 5,
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId("pickup"),
        position: _currentOrder?.pickupLocation?? LatLng(0.0, 0.0),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: "Pickup location"),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId("delivery"),
        position: _currentOrder?.deliveryLocation?? LatLng(0.0, 0.0),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: "Delivery location"),
      ),
    );
    _updateDeliveryBoyMarker();
  }

  void _updateDeliveryBoyMarker() {
    _markers.removeWhere((m) => m.markerId.value == 'deliveryBoy');
    if (_currentDeliveryBoyPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId("deliveryBoy"),
          position: _currentDeliveryBoyPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation: _calculateBearing(),
          infoWindow: InfoWindow(title: "Delivery Partner"),
        ),
      );
    }
  }

  double _calculateBearing() {
    if (_currentStep == 0 || _routePoints.isEmpty) return 0;

    LatLng previousPoint = _routePoints[_currentStep - 1];
    LatLng currentPoint = _routePoints[_currentStep];

    double pi = 3.1415926535897932;
    double lat1 = previousPoint.latitude * pi / 180;
    double lon1 = previousPoint.longitude * pi / 180;
    double lat2 = currentPoint.latitude * pi / 180;
    double lon2 = currentPoint.longitude * pi / 180;

    double y = sin(lon2 - lon1) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    return atan2(y, x) * 180 / pi + 360 % 360;
  }

  void _startDeliverySimulation() {
    const duration = Duration(milliseconds: 300);
    _animationTimer = Timer.periodic(duration, (timer) {
      if (_currentStep < _routePoints.length - 1) {
        _currentStep++;
        _currentDeliveryBoyPosition = _routePoints[_currentStep];
        _updateDeliveryBoyMarker();
        notifyListeners();
      } else {
        _stopAnimation();
        _onDestinationReached();
      }
    });
  }

  void _onDestinationReached() {
    _status = DeliveryStatus.destinationReached;
    notifyListeners();
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  void resetDelivery() {
    _stopAnimation();
    _status = DeliveryStatus.waitingForAcceptance;
    _routePoints = [];
    _polylines.clear();
    _markers.clear();
    _currentStep = 0;
    _currentDeliveryBoyPosition = null;
    initializeOrder();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAnimation();
    super.dispose();
  }
}
