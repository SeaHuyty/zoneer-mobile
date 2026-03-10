import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final locationPermissionProvider =
    NotifierProvider<LocationPermissionNotifier, LocationPermissionState>(() {
      return LocationPermissionNotifier();
    });

class LocationPermissionState {
  final bool hasPermission;
  final bool isRequesting;
  final LatLng? userLocation;

  const LocationPermissionState({
    this.hasPermission = false,
    this.isRequesting = false,
    this.userLocation,
  });

  LocationPermissionState copyWith({
    bool? hasPermission,
    bool? isRequesting,
    LatLng? userLocation,
    bool clearLocation = false,
  }) {
    return LocationPermissionState(
      hasPermission: hasPermission ?? this.hasPermission,
      isRequesting: isRequesting ?? this.isRequesting,
      userLocation: clearLocation ? null : userLocation ?? this.userLocation,
    );
  }
}

class LocationPermissionNotifier extends Notifier<LocationPermissionState> {
  @override
  LocationPermissionState build() {
    // Check initial permission state
    _checkInitialPermission();
    return const LocationPermissionState();
  }

  Future<void> _checkInitialPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      state = state.copyWith(hasPermission: true);
      _getUserLocation();
    }
  }

  Future<bool> requestPermission() async {
    state = state.copyWith(isRequesting: true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(isRequesting: false);
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(isRequesting: false, hasPermission: false);
        return false;
      }

      if (permission == LocationPermission.denied) {
        state = state.copyWith(isRequesting: false, hasPermission: false);
        return false;
      }

      state = state.copyWith(isRequesting: false, hasPermission: true);
      await _getUserLocation();
      return true;
    } catch (e) {
      state = state.copyWith(isRequesting: false, hasPermission: false);
      return false;
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      state = state.copyWith(
        userLocation: LatLng(position.latitude, position.longitude),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  void rejectPermission() {
    state = state.copyWith(isRequesting: false, hasPermission: false);
  }

  Future<void> refreshLocation() async {
    if (state.hasPermission) {
      await _getUserLocation();
    }
  }
}
