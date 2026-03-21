import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:zoneer_mobile/core/providers/location_permission_provider.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/core/utils/responsive.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';
import 'package:zoneer_mobile/features/property/viewmodels/property_sections_viewmodel.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card_skeleton.dart';

/// Displays all properties for a given section in a responsive grid.
/// [sectionKey] values: 'all', 'nearby', 'phnom_penh', 'siem_reap'
class SectionAllPropertiesScreen extends ConsumerWidget {
  final String title;
  final String sectionKey;

  const SectionAllPropertiesScreen({
    super.key,
    required this.title,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedHomeCategoryProvider);
    final locationState = ref.watch(locationPermissionProvider);
    final userLocation = locationState.userLocation;

    final propertiesAsync = _buildProvider(ref, selectedType, userLocation);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: propertiesAsync.when(
        loading: () => _buildSkeletonGrid(context),
        error: (err, _) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Something went wrong. Please try again.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    _emptyMessage(),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final crossAxisCount = Responsive.cardCrossAxisCount(context);

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: crossAxisCount > 2 ? 1.6 : 1.25,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final property = item.$1;
              final distance = item.$2;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailPage(id: property.id),
                  ),
                ),
                child: PropertyCard(
                  property: property,
                  distanceMeters: sectionKey == 'nearby' ? distance : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  AsyncValue<List<(dynamic, double?)>> _buildProvider(
    WidgetRef ref,
    String type,
    LatLng? userLocation,
  ) {
    if (sectionKey == 'nearby' && userLocation != null) {
      return ref
          .watch(nearbyPropertiesSectionProvider(
            (lat: userLocation.latitude, lng: userLocation.longitude, type: type),
          ))
          .whenData((list) => list.map((e) => (e.$1, e.$2 as double?)).toList());
    }

    // For non-nearby sections, fetch with higher limit
    final provider = _nonNearbyProvider(ref, type);
    return provider.whenData(
      (list) => list.map((p) => (p, null as double?)).toList(),
    );
  }

  AsyncValue<List<dynamic>> _nonNearbyProvider(WidgetRef ref, String type) {
    switch (sectionKey) {
      case 'phnom_penh':
        return ref.watch(_phnomPenhAllProvider(type));
      case 'siem_reap':
        return ref.watch(_siemReapAllProvider(type));
      default:
        return ref.watch(_allPropertiesAllProvider(type));
    }
  }

  String _emptyMessage() {
    switch (sectionKey) {
      case 'nearby':
        return 'No properties found within 20 km\nof your location.';
      case 'phnom_penh':
        return 'No properties found in\nPhnom Penh yet.';
      case 'siem_reap':
        return 'No properties found in\nSiem Reap yet.';
      default:
        return 'No properties available right now.';
    }
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    final count = Responsive.cardCrossAxisCount(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: count > 2 ? 1.6 : 1.25,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const PropertyCardSkeleton(),
    );
  }
}

// Higher-limit providers for "See All" pages
final _allPropertiesAllProvider =
    FutureProvider.family<List<dynamic>, String>((ref, type) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getVerifiedPropertiesSection(
    limit: 100,
    type: type.isEmpty ? null : type,
  );
});

final _phnomPenhAllProvider =
    FutureProvider.family<List<dynamic>, String>((ref, type) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getVerifiedPropertiesSection(
    limit: 100,
    addressContains: 'Phnom Penh',
    type: type.isEmpty ? null : type,
  );
});

final _siemReapAllProvider =
    FutureProvider.family<List<dynamic>, String>((ref, type) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getVerifiedPropertiesSection(
    limit: 100,
    addressContains: 'Siem Reap',
    type: type.isEmpty ? null : type,
  );
});
