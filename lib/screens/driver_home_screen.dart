import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shipper_ui/providers/current_location_provider.dart';
import 'package:shipper_ui/providers/delivery_provider.dart';
import 'package:shipper_ui/utils/utils.dart';
import 'package:shipper_ui/widgets/order_card.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  GoogleMapController? mapController;
  bool isOnline = true;

  bool isOrderExpanded = true;

  @override
  void initState() {
    Future.microtask(() {
      context.read<DeliveryProvider>().initializeOrder();
    });
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> _buildMarkers(LatLng currentLocation) {
    debugPrint(currentLocation.toString());
    return {
      Marker(
        markerId: MarkerId("current_location"),
        position: currentLocation,
        infoWindow: InfoWindow(
          title: "Current Location",
          snippet: "You are here !",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<CurrentLocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("Getting your location..."),
                ],
              ),
            );
          }
          if (locationProvider.errorMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showAppSnackbar(
                context: context,
                type: SnackbarType.error,
                description: locationProvider.errorMessage,
              );
            });
          }
          Size size = MediaQuery.of(context).size;
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                markers: _buildMarkers(locationProvider.currentLocation),
                initialCameraPosition: CameraPosition(
                  target: locationProvider.currentLocation,
                  zoom: 15,
                ),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapType: MapType.normal,
              ),
              if (locationProvider.errorMessage.isEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: isOrderExpanded
                        ? OrderCard(
                            // Khi bấm nút Close ở Card to -> Chuyển thành thu nhỏ
                            onTapClose: () {
                              setState(() {
                                isOrderExpanded = false;
                              });
                            },
                          )
                        : InkWell(
                            // Khi bấm vào Thanh thu nhỏ -> Mở to trở lại
                            onTap: () {
                              setState(() {
                                isOrderExpanded = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Để chiều rộng vừa đủ nội dung
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.orange,
                                  ), // Mũi tên chỉ lên
                                  SizedBox(width: 8),
                                  Text(
                                    "New Order Available (320)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size.height * 0.12,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Center(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 200,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Online",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
