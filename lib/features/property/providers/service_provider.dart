import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zoneer_mobile/features/property/services/location_service.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current city state provider
final currentCityProvider = StateNotifierProvider<CurrentCityNotifier, String>((ref) {
  return CurrentCityNotifier(ref.read(locationServiceProvider));
});
class CurrentCityNotifier extends StateNotifier<String> {
  final LocationService _locationService;

  CurrentCityNotifier(this._locationService): super('Current Location');
  
  // Fetch current location 
  Future<void> fetchCurrentCity() async {
    String city = await _locationService.getCurrentCity();
    state = city;
  }

  // Reset to default
  void resetToDefault() {
    state = 'Current Location';
  }
}