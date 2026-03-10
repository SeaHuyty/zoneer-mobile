import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoneer_mobile/core/providers/location_permission_provider.dart';
import 'package:zoneer_mobile/core/services/map_migration_service.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:zoneer_mobile/features/property/viewmodels/property_filter_provider.dart';
import 'package:zoneer_mobile/features/property/widgets/property_filter_sheet.dart';
import 'package:zoneer_mobile/features/property/widgets/property_map_detail_sheet.dart';
import 'package:zoneer_mobile/shared/widgets/location_permission_dialog.dart';

class PropertyMapPage extends ConsumerStatefulWidget {
  const PropertyMapPage({super.key});

  @override
  ConsumerState<PropertyMapPage> createState() => _PropertyMapPageState();
}

class _PropertyMapPageState extends ConsumerState<PropertyMapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  PropertyModel? _selectedProperty;

  // Initial center position (Phnom Penh, Cambodia)
  static const LatLng _initialCenter = LatLng(11.5564, 104.9282);

  // Mock demo properties
  List<PropertyModel> get _demoProperties => [
    PropertyModel(
      id: 'demo-aeon-mall',
      price: 800,
      bedroom: 2,
      bathroom: 2,
      squareArea: 65,
      address: 'Near AEON MALL Mean Chey, Phnom Penh',
      locationUrl: 'https://maps.google.com/?q=11.4840931,104.9181828',
      latitude: 11.4840931,
      longitude: 104.9181828,
      thumbnail:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      description:
          'Modern apartment near AEON MALL with easy access to shopping and entertainment',
    ),
    PropertyModel(
      id: 'demo-central-market',
      price: 650,
      bedroom: 1,
      bathroom: 1,
      squareArea: 45,
      address: 'Central Market Area, Phnom Penh',
      locationUrl: 'https://maps.google.com/?q=11.5696,104.9211',
      latitude: 11.5696,
      longitude: 104.9211,
      thumbnail:
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      description: 'Cozy studio near Central Market, perfect for students',
    ),
    PropertyModel(
      id: 'demo-riverside',
      price: 1200,
      bedroom: 3,
      bathroom: 2,
      squareArea: 95,
      address: 'Riverside, Phnom Penh',
      locationUrl: 'https://maps.google.com/?q=11.5624,104.9280',
      latitude: 11.5624,
      longitude: 104.9280,
      thumbnail:
          'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      description: 'Luxury apartment with river view and modern amenities',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _runCoordinateMigration();
  }

  /// Run one-time migration to add coordinates to existing properties
  Future<void> _runCoordinateMigration() async {
    const migrationKey = 'map_coordinates_migration_done';

    try {
      final prefs = await SharedPreferences.getInstance();
      final migrationDone = prefs.getBool(migrationKey) ?? false;

      if (!migrationDone) {
        // Run migration
        final migrationService = ref.read(mapMigrationServiceProvider);
        final updatedCount = await migrationService
            .addCoordinatesToExistingProperties();

        // Mark migration as done
        await prefs.setBool(migrationKey, true);

        if (updatedCount > 0) {
          // Refresh properties to show updated coordinates
          ref.invalidate(propertiesViewModelProvider);
        }
      }
    } catch (e) {
      // Silently fail - migration is not critical
      print('Map coordinate migration error: $e');
    }
  }

  List<PropertyModel> _getAllProperties(
    AsyncValue<List<PropertyModel>> propertiesAsync,
  ) {
    return propertiesAsync.maybeWhen(
      data: (properties) => [..._demoProperties, ...properties],
      orElse: () => _demoProperties,
    );
  }

  List<PropertyModel> _filterProperties(List<PropertyModel> properties) {
    final filter = ref.watch(propertyFilterProvider);
    var filtered = properties;

    // Apply search filter
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.address.toLowerCase().contains(
              filter.searchQuery!.toLowerCase(),
            ) ||
            p.description?.toLowerCase().contains(
                  filter.searchQuery!.toLowerCase(),
                ) ==
                true;
      }).toList();
    }

    // Apply property type filter
    if (filter.propertyType != null) {
      // This is a simple filter - you can improve based on your data model
      filtered = filtered.where((p) {
        // You might need to add propertyType field to your model
        // For now, filter by description
        return true;
      }).toList();
    }

    // Apply price filter
    filtered = filtered.where((p) {
      return p.price >= filter.minPrice && p.price <= filter.maxPrice;
    }).toList();

    // Apply beds filter
    if (filter.beds != null) {
      if (filter.beds == 5) {
        // 5+ beds
        filtered = filtered.where((p) => p.bedroom >= 5).toList();
      } else {
        filtered = filtered.where((p) => p.bedroom == filter.beds).toList();
      }
    }

    return filtered;
  }

  void _onMarkerTapped(PropertyModel property) {
    setState(() {
      _selectedProperty = property;
    });

    // Show modern property details bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PropertyMapDetailSheet(property: property),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PropertyFilterSheet(),
    );
  }

  List<Marker> _buildMarkers(List<PropertyModel> properties) {
    final permissionState = ref.watch(locationPermissionProvider);
    final markers = <Marker>[];

    for (var property in properties) {
      // Skip properties without coordinates
      if (property.latitude == null || property.longitude == null) {
        continue;
      }

      final isSelected = _selectedProperty?.id == property.id;

      markers.add(
        Marker(
          width: 100,
          height: 65,
          point: LatLng(property.latitude!, property.longitude!),
          child: GestureDetector(
            onTap: () => _onMarkerTapped(property),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE91E63)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatPrice(property.price),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Icon(
                  Icons.location_pin,
                  color: isSelected
                      ? const Color(0xFFE91E63)
                      : Colors.grey[400],
                  size: 26,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Add user location marker if available
    if (permissionState.userLocation != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: permissionState.userLocation!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: const Icon(Icons.person, color: Colors.blue, size: 20),
          ),
        ),
      );
    }

    return markers;
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesViewModelProvider);
    final allProperties = _getAllProperties(propertiesAsync);
    final filteredProperties = _filterProperties(allProperties);
    final filter = ref.watch(propertyFilterProvider);
    final permissionState = ref.watch(locationPermissionProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConfig.mapboxTileUrl,
                userAgentPackageName: 'com.zoneer.mobile',
              ),
              MarkerLayer(markers: _buildMarkers(filteredProperties)),
            ],
          ),

          // Search Bar and Filter overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref
                            .read(propertyFilterProvider.notifier)
                            .updateSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Place...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Filter Button
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: filter.hasActiveFilters
                          ? const Color(0xFFE91E63)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune,
                          color: filter.hasActiveFilters
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                        if (filter.hasActiveFilters)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Property Count Badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 76,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${filteredProperties.length} properties',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                if (permissionState.userLocation != null) {
                  _mapController.move(permissionState.userLocation!, 14);
                } else {
                  // Request permission via dialog
                  final granted = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const LocationPermissionDialog(),
                  );

                  if (granted == true && permissionState.userLocation != null) {
                    _mapController.move(permissionState.userLocation!, 14);
                  }
                }
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: permissionState.hasPermission
                    ? const Color(0xFFE91E63)
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
