import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check if the location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request to enable the location service
  Future<bool> requestLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // On mobile, this will prompt user to enable location
      // On web, this just returns the current status
      return false;
    }
    return serviceEnabled;
  }

  // Check permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission first (more important than service check on macOS)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied. Please enable in system settings.');
        return null;
      }

      // Check if service is enabled after permission check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled. Please enable in system settings.');
        // On some platforms, we can still try to get location
        // Continue anyway for web/desktop platforms
      }

      // Get location with timeout
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Location request timed out');
          throw Exception('Location request timed out');
        },
      );
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
        
        // Build city string from available fields (handles null values on web)
        String? locality = place.locality;
        String? adminArea = place.administrativeArea;
        String? subLocality = place.subLocality;
        String? country = place.country;
        
        // Try to build a meaningful location string
        if (locality != null && adminArea != null) {
          return '$locality, $adminArea';
        } else if (locality != null && country != null) {
          return '$locality, $country';
        } else if (subLocality != null && adminArea != null) {
          return '$subLocality, $adminArea';
        } else if (adminArea != null) {
          return adminArea;
        } else if (locality != null) {
          return locality;
        } else if (country != null) {
          return country;
        }
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
      Position? position = await getCurrentLocation();
      if (position != null) {
        String? city = await getCityFromCoordinates(
          position.latitude,
          position.longitude,
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
