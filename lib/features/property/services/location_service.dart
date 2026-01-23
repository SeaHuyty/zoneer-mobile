import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationService {
  // Development mode: Set to true to use mock location for testing
  // Set to false for production
  static const bool _useMockLocationForWeb = false;
  
  // Mock location: Phnom Penh, Cambodia (for development/testing)
  static const double _mockLatitude = 11.5564;
  static const double _mockLongitude = 104.9282;
  
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
      // Platform-specific handling
      if (kIsWeb) {
        // Development fallback: Use mock location if enabled
        if (_useMockLocationForWeb) {
          print('🧪 Using mock location for web development');
          await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
          return Position(
            latitude: _mockLatitude,
            longitude: _mockLongitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
        
        // Web platform - browser geolocation API
        print('🌐 Requesting location on web platform');
        print('🌐 URL: ${Uri.base}');
        print('🌐 To test manually, open Console and run:');
        print('   navigator.geolocation.getCurrentPosition(pos => console.log(pos), err => console.error(err))');
        
        // Check permission first
        LocationPermission permission = await Geolocator.checkPermission();
        print('🌐 Current permission status: $permission');
        
        if (permission == LocationPermission.denied) {
          print('🌐 Permission denied, requesting...');
          permission = await Geolocator.requestPermission();
          print('🌐 Permission after request: $permission');
          
          if (permission == LocationPermission.denied) {
            print('❌ Location permissions are denied on web. User must allow in browser.');
            return null;
          }
        }
        
        if (permission == LocationPermission.deniedForever) {
          print('❌ Location permissions are permanently denied on web.');
          return null;
        }
        
        print('✅ Permission granted, fetching location...');
        
        // For web, try to get location with more lenient settings
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            print('⏱️ Location request timed out on web');
            throw Exception('Location request timed out. Please ensure location is enabled in your browser.');
          },
        );
        
        print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
        return position;
      } else {
        // Mobile/Desktop platforms
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
    } catch (e, stackTrace) {
      print('❌ Error getting location: $e');
      print('Stack trace: $stackTrace');
      
      // Check if it's a specific geolocation error
      if (e.toString().contains('User denied')) {
        print('❌ User denied location permission');
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        print('❌ Permission denied by browser');
      } else if (e.toString().contains('POSITION_UNAVAILABLE')) {
        print('❌ Location position unavailable');
      } else if (e.toString().contains('TIMEOUT')) {
        print('❌ Location request timeout');
      }
      
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
        String? locality = place.locality; // City
        String? adminArea = place.administrativeArea; // Province/State
        String? subLocality = place.subLocality; // District/Neighborhood
        String? country = place.country;
        
        // Priority format for Cambodia and similar locations:
        // "District, City" (e.g., "Chba Ampov, Phnom Penh")
        // This provides the most useful location information
        
        if (subLocality != null && locality != null) {
          // Best case: District, City
          return '$subLocality, $locality';
        } else if (locality != null && adminArea != null) {
          // Fallback: City, Province/State
          return '$locality, $adminArea';
        } else if (subLocality != null && adminArea != null) {
          // Alternative: District, Province
          return '$subLocality, $adminArea';
        } else if (locality != null && country != null) {
          // Fallback: City, Country
          return '$locality, $country';
        } else if (adminArea != null) {
          // Only province/state
          return adminArea;
        } else if (locality != null) {
          // Only city
          return locality;
        } else if (subLocality != null) {
          // Only district
          return subLocality;
        } else if (country != null) {
          // Only country
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
      settingsInstructions = 'Please check your browser settings and ensure:\n'
          '• The site is using HTTPS (required for geolocation)\n'
          '• Location permission is allowed in your browser\n'
          '• Click the location icon in the address bar to manage permissions';
    } else if (!kIsWeb && Platform.isMacOS) {
      settingsInstructions = 'Please enable location access in:\n'
          'System Settings → Security & Privacy → Privacy → Location Services\n'
          'Make sure Location Services is ON and this app is allowed.';
    } else if (!kIsWeb && Platform.isIOS) {
      settingsInstructions = 'Please enable location access in:\n'
          'Settings → Privacy & Security → Location Services';
    } else {
      settingsInstructions = 'Please enable location access in your system settings.';
    }
    
    if (permission == LocationPermission.deniedForever) {
      return LocationErrorInfo(
        title: 'Location Permission Denied',
        message: 'Location permission has been permanently denied.\n\n$settingsInstructions',
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
