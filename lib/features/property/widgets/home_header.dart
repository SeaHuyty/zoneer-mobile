import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/core/providers/service_provider.dart';
import 'package:zoneer_mobile/core/providers/location_permission_provider.dart';
import 'package:zoneer_mobile/features/notification/views/notification_screen.dart';
import 'package:zoneer_mobile/shared/widgets/location_permission_dialog.dart';

class HomeHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader>
    with TickerProviderStateMixin {
  late AnimationController _notificationController;
  late AnimationController _accountController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _notificationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _accountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _handleLocationRequest() async {
    final permissionState = ref.read(locationPermissionProvider);

    // If already has permission, just get city from current location
    if (permissionState.hasPermission && permissionState.userLocation != null) {
      setState(() => _isLoadingLocation = true);
      try {
        // Get city from the cached location in permission provider
        final locationService = ref.read(locationServiceProvider);
        final city = await locationService.getCityFromCoordinates(
          permissionState.userLocation!.latitude,
          permissionState.userLocation!.longitude,
        );

        if (city != null && mounted) {
          ref.read(currentCityProvider.notifier).updateCity(city);
        } else if (mounted) {
          // Fallback to fetching fresh location
          await ref.read(locationPermissionProvider.notifier).refreshLocation();
          final updatedState = ref.read(locationPermissionProvider);

          if (updatedState.userLocation != null) {
            final newCity = await locationService.getCityFromCoordinates(
              updatedState.userLocation!.latitude,
              updatedState.userLocation!.longitude,
            );
            if (newCity != null) {
              ref.read(currentCityProvider.notifier).updateCity(newCity);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
      }
      return;
    }

    // Show custom permission dialog
    final granted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LocationPermissionDialog(),
    );

    if (granted == true && mounted) {
      setState(() => _isLoadingLocation = true);
      try {
        // After permission granted, get location and reverse geocode
        final updatedState = ref.read(locationPermissionProvider);

        if (updatedState.userLocation != null) {
          final locationService = ref.read(locationServiceProvider);
          final city = await locationService.getCityFromCoordinates(
            updatedState.userLocation!.latitude,
            updatedState.userLocation!.longitude,
          );

          if (city != null && mounted) {
            ref.read(currentCityProvider.notifier).updateCity(city);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
      }
    }
  }

  Future<void> _autoUpdateCityFromLocation(LatLng location) async {
    final currentCity = ref.read(currentCityProvider);
    if (currentCity != 'Current Location') return;

    try {
      final locationService = ref.read(locationServiceProvider);
      final city = await locationService.getCityFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (city != null && mounted) {
        ref.read(currentCityProvider.notifier).updateCity(city);
      }
    } catch (_) {
      // Silent failure — user can still tap to retry
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCity = ref.watch(currentCityProvider);

    ref.listen<LocationPermissionState>(
      locationPermissionProvider,
      (previous, next) {
        final hadLocation = previous?.userLocation != null;
        final hasLocation = next.userLocation != null;

        if (!hadLocation && hasLocation && !_isLoadingLocation) {
          _autoUpdateCityFromLocation(next.userLocation!);
        }
      },
    );

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      toolbarHeight: 140,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _isLoadingLocation
                            ? null
                            : _handleLocationRequest,
                        child: SvgPicture.asset(
                          'assets/icons/map-pin-house.svg',
                          width: 32,
                          height: 32,
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isLoadingLocation
                            ? null
                            : _handleLocationRequest,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  currentCity,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  IconButton(
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.greyLight),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Lottie.asset(
                      'assets/icons/system-solid-46-notification-bell-hover-bell.json',
                      controller: _notificationController,
                      width: 28,
                      height: 28,
                      onLoaded: (composition) {
                        _notificationController.duration = composition.duration;
                      },
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Text(
                "Discover your perfect place to stay today.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
