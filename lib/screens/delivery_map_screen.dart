import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shipper_ui/providers/delivery_provider.dart';
import 'package:shipper_ui/screens/app_main_screen.dart';
import 'package:shipper_ui/widgets/custom_button.dart';
import 'package:shipper_ui/widgets/order_on_the_way.dart';

class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({super.key});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              _buildGoogleMap(provider),
              Consumer<DeliveryProvider>(
                builder: (context, provider, child) {
                  if (provider.currentOrder == null) return SizedBox();
                  if (provider.status == DeliveryStatus.rejected) {
                    return SizedBox();
                  }
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(1),
                      child: OrderOnTheWay(
                        order: provider.currentOrder!,
                        status: provider.status,
                        onButtonPressed: () {
                          switch (provider.status) {
                            case DeliveryStatus.pickingUp:
                              provider.markAsPickedUp();
                              break;
                            case DeliveryStatus.destinationReached:
                              provider.markAdDelivered();
                              break;
                            case DeliveryStatus.markingAsDelivered:
                              provider.completeDelivery();
                              break;
                            default:
                              break;
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              if(provider.status == DeliveryStatus.delivered)
              _buildDeliveryCompletedCard(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeliveryCompletedCard(DeliveryProvider provider) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/success.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Delivery Complete",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Great Job! Your delivery has been successfully completed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    title: "Go Home",
                    onPressed: () {
                      Navigator.of(context).pop();
                      provider.resetDelivery();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => AppMainScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleMap(DeliveryProvider provider) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        // Nếu muốn camera focus vào xe shipper khi bắt đầu
        if (provider.currentDeliveryBoyPosition != null) {
             _moveToLocation(provider.currentDeliveryBoyPosition!);
        } else if (provider.currentOrder != null) {
          _moveToLocation(provider.currentOrder!.pickupLocation);
        }
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(10.762622, 106.660172),
        zoom: 14.0,
      ),
      markers: _buildMarkers(provider), 
      polylines: _buildPolylines(provider),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
    );
  }

  Set<Marker> _buildMarkers(DeliveryProvider provider) {
    return provider.markers;
  }

  Set<Polyline> _buildPolylines(DeliveryProvider provider) {
    return provider.polylines;
  }

  void _moveToLocation(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 14));
  }
}
