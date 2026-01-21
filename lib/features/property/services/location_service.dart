import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  final loc.Location _location = loc.Location();

  // Check if the location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await _location.serviceEnabled();
  }

  // Request to enable the location service
  Future<bool> requestLocationService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }
    return serviceEnabled;
  }

  // Check permission status
  Future<loc.PermissionStatus> checkPermission() async {
    return await _location.hasPermission();
  }

  // Request location permission
  Future<loc.PermissionStatus> requestPermission() async {
    loc.PermissionStatus permission = await _location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }
    return permission;
  }

  // Get current location
  Future<loc.LocationData?> getCurrentLocation() async {
    try {
      // Check if service is enabled
      bool serviceEnabled = await requestLocationService();
      if (!serviceEnabled) return null;

      // Check permission
      loc.PermissionStatus permission = await requestPermission();
      if (permission != loc.PermissionStatus.granted) return null;

      // Get location
      return await _location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get city name from coordinates
  Future<String?> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.administrativeArea}';
      }
      return null;
    } catch (e) {
      print('Error getting city name: $e');
      return null;
    }
  }

  // Complete flow: get location name city name
  Future<String> getCurrentCity() async {
    try {
      loc.LocationData? locationData = await getCurrentLocation();
      if (locationData != null &&
          locationData.latitude != null &&
          locationData.longitude != null) {
        String? city = await getCityFromCoordinates(
          locationData.latitude!,
          locationData.longitude!,
        );
        return city ?? 'Unknown Location';
      }
      return 'Location unavailable';
    } catch (e) {
      print('Error getting current city: $e');
      return 'Location unavailable';
    }
  }
}
