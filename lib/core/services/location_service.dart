import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // Get current location (does NOT request permission, only gets position if already granted)
  // Use locationPermissionProvider to request permission first
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission first - do NOT request if denied
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print(
          'Location permission not granted. Please request permission first.',
        );
        return null;
      }

      // Platform-specific handling
      if (kIsWeb) {
        // Web platform - browser geolocation API
        print('Getting location on web platform');

        // For web, try to get location with more lenient settings
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            print('Location request timed out on web');
            throw Exception(
              'Location request timed out. Please ensure location is enabled in your browser.',
            );
          },
        );
      } else {
        // Mobile/Desktop platforms
        // Check if service is enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print(
            'Location services are disabled. Please enable in system settings.',
          );
          // On macOS/Desktop, we might still try if permission is granted
          // Continue anyway for desktop platforms
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
      }
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
    print('🌍 getCityFromCoordinates called with: $latitude, $longitude');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      print('✅ Placemarks received: ${placemarks.length}');

      if (placemarks.isEmpty) {
        print('❌ No placemarks found for coordinates: $latitude, $longitude');
        return null;
      }

      Placemark place = placemarks[0];

      // Safely extract fields with extensive null/error handling for web compatibility
      String? locality;
      String? adminArea;
      String? subLocality;
      String? subAdminArea;
      String? country;

      try {
        locality = place.locality?.isNotEmpty == true ? place.locality : null;
      } catch (e) {
        print('⚠️ Error reading locality: $e');
        locality = null;
      }

      try {
        adminArea = place.administrativeArea?.isNotEmpty == true
            ? place.administrativeArea
            : null;
      } catch (e) {
        print('⚠️ Error reading administrativeArea: $e');
        adminArea = null;
      }

      try {
        subLocality = place.subLocality?.isNotEmpty == true
            ? place.subLocality
            : null;
      } catch (e) {
        print('⚠️ Error reading subLocality: $e');
        subLocality = null;
      }

      try {
        subAdminArea = place.subAdministrativeArea?.isNotEmpty == true
            ? place.subAdministrativeArea
            : null;
      } catch (e) {
        print('⚠️ Error reading subAdministrativeArea: $e');
        subAdminArea = null;
      }

      try {
        country = place.country?.isNotEmpty == true ? place.country : null;
      } catch (e) {
        print('⚠️ Error reading country: $e');
        country = null;
      }

      print(
        '📍 Extracted - locality: $locality, adminArea: $adminArea, subLocality: $subLocality, subAdminArea: $subAdminArea, country: $country',
      );

      // Priority format for Cambodia and similar locations:
      // "District, City" (e.g., "Chroy Changvar, Phnom Penh")
      // This provides the most useful location information

      String? result;

      if (subLocality != null && locality != null) {
        // Best case: District/Commune, City
        result = '$subLocality, $locality';
      } else if (locality != null && adminArea != null) {
        // Fallback: City, Province/State
        result = '$locality, $adminArea';
      } else if (subAdminArea != null && locality != null) {
        // Alternative: Sub-region, City
        result = '$subAdminArea, $locality';
      } else if (subLocality != null && adminArea != null) {
        // Alternative: District, Province
        result = '$subLocality, $adminArea';
      } else if (locality != null && country != null) {
        // Fallback: City, Country
        result = '$locality, $country';
      } else if (adminArea != null) {
        // Only province/state
        result = adminArea;
      } else if (locality != null) {
        // Only city
        result = locality;
      } else if (subLocality != null) {
        // Only district
        result = subLocality;
      } else if (subAdminArea != null) {
        // Only sub-region
        result = subAdminArea;
      } else if (country != null) {
        // Only country
        result = country;
      }

      if (result != null) {
        print('✅ City found: $result');
        return result;
      }

      print('❌ No valid location data found in placemark');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error getting city name: $e');
      print('Stack trace: $stackTrace');
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
        return city ?? 'Unknown location';
      }
      return 'Location unavailable';
    } catch (e) {
      print('Error getting current city: $e');
      return 'Location unavailable';
    }
  }

  // Get detailed error message based on permission status
  Future<LocationErrorInfo> getLocationErrorInfo() async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // Platform-specific messages
    String settingsInstructions = '';
    if (kIsWeb) {
      settingsInstructions =
          'Please check your browser settings and ensure:\n'
          '• The site is using HTTPS (required for geolocation)\n'
          '• Location permission is allowed in your browser\n'
          '• Click the location icon in the address bar to manage permissions';
    } else if (!kIsWeb && Platform.isMacOS) {
      settingsInstructions =
          'Please enable location access in:\n'
          'System Settings → Security & Privacy → Privacy → Location Services\n'
          'Make sure Location Services is ON and this app is allowed.';
    } else if (!kIsWeb && Platform.isIOS) {
      settingsInstructions =
          'Please enable location access in:\n'
          'Settings → Privacy & Security → Location Services';
    } else {
      settingsInstructions =
          'Please enable location access in your system settings.';
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationErrorInfo(
        title: 'Location Permission Denied',
        message:
            'Location permission has been permanently denied.\n\n$settingsInstructions',
        canRequest: false,
      );
    } else if (permission == LocationPermission.denied) {
      return LocationErrorInfo(
        title: 'Location Permission Required',
        message: kIsWeb
            ? 'We need your location to show properties near you.\n\n$settingsInstructions'
            : 'We need your location to show properties near you. Please allow location access when prompted.',
        canRequest: true,
      );
    } else if (!serviceEnabled && !kIsWeb) {
      return LocationErrorInfo(
        title: 'Location Service Disabled',
        message: 'Location services are disabled.\n\n$settingsInstructions',
        canRequest: false,
      );
    }

    return LocationErrorInfo(
      title: 'Location Unavailable',
      message: kIsWeb
          ? 'Unable to determine your location.\n\n$settingsInstructions'
          : 'Unable to determine your location. Please try again.',
      canRequest: true,
    );
  }
}

class LocationErrorInfo {
  final String title;
  final String message;
  final bool canRequest;

  LocationErrorInfo({
    required this.title,
    required this.message,
    required this.canRequest,
  });
}
