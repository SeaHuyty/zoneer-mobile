import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/services/location_service.dart';

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
  Future<void> fetchCurrentCity() async {
    final locationService = ref.read(locationServiceProvider);
    String city = await locationService.getCurrentCity();
    state = city;
  }

  // Reset to default
  void resetToDefault() {
    state = 'Current Location';
  }
}
