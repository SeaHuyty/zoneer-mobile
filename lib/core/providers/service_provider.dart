import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/services/location_service.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current city state provider
final currentCityProvider = NotifierProvider<CurrentCityNotifier, String>(() {
  return CurrentCityNotifier();
});

class CurrentCityNotifier extends Notifier<String> {
  @override
  String build() => 'Current Location';

  // Fetch current location
  Future<LocationResult> fetchCurrentCity() async {
    final locationService = ref.read(locationServiceProvider);

    try {
      String city = await locationService.getCurrentCity();
      state = city;

      // Check if we got an error message instead of a location
      if (city == 'Location unavailable' || city == 'Unknown location') {
        final errorInfo = await locationService.getLocationErrorInfo();
        return LocationResult(
          success: false,
          location: city,
          errorInfo: errorInfo,
        );
      }

      return LocationResult(success: true, location: city);
    } catch (e) {
      state = 'Location unavailable';
      return LocationResult(
        success: false,
        location: 'Location unavailable',
        errorInfo: null,
      );
    }
  }

  // Reset to default
  void resetToDefault() {
    state = 'Current Location';
  }
}

class LocationResult {
  final bool success;
  final String location;
  final dynamic errorInfo;

  LocationResult({
    required this.success,
    required this.location,
    this.errorInfo,
  });
}
