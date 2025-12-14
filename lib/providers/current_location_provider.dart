import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocationProvider extends ChangeNotifier {
  LatLng _currentLocation = LatLng(10.762622, 106.660172);
  bool _isLoading = true;
  String _errorMessage = '';

  LatLng get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  CurrentLocationProvider() {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = "Location permission denied. Use default location";
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = "Location service are disable";
        _isLoading = false;
        notifyListeners();
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage =
          "Error getting location ${e.toString()}. Use default location";
      _isLoading = false;
      notifyListeners();
      debugPrint(e.toString());
    }
  }
  void refreshLocation() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    _getCurrentLocation();
  }
}

