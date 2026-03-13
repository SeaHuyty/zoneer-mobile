import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/providers/saved_properties_provider.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';

/// Simple bottom sheet card shown when a map marker is tapped.
/// Shows thumbnail + key info and lets the user navigate to the full detail page.
class PropertyMapDetailSheet extends ConsumerWidget {
  final PropertyModel selectedProperty;

  // Kept for API compatibility but not used in this simplified design.
  final List<PropertyModel> allProperties;
  final void Function(PropertyModel) onPropertySelected;

  const PropertyMapDetailSheet({
    super.key,
    required this.selectedProperty,
    required this.allProperties,
    required this.onPropertySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = selectedProperty;
    final savedIds = ref.watch(savedPropertiesProvider);
    final isSaved = savedIds.contains(p.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Card row ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 110,
                    height: 90,
                    child: p.thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: p.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.home, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price + favorite
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '\$${p.price.toStringAsFixed(0)}/mo',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(savedPropertiesProvider.notifier)
                                .toggle(p.id),
                            child: Icon(
                              isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Address
                      Text(
                        p.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Beds / Baths / Area
                      Row(
                        children: [
                          _chip(Icons.bed, '${p.bedroom}'),
                          const SizedBox(width: 8),
                          _chip(Icons.bathroom, '${p.bathroom}'),
                          const SizedBox(width: 8),
                          _chip(Icons.square_foot,
                              '${p.squareArea.toInt()} m²'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── View Details button ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyDetailPage(id: p.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'View Full Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
