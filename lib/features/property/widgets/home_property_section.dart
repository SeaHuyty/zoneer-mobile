import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/utils/responsive.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card_skeleton.dart';

/// A horizontal-scroll (phone) or wrapped-grid (web) property section.
///
/// [nearbyItems] — if provided, cards show distance badges (for Nearby section).
/// [propertiesAsync] — used for non-nearby sections.
/// Exactly one of these must be non-null.
class HomePropertySection extends ConsumerWidget {
  final String title;
  final String emptyMessage;
  final VoidCallback onSeeAll;

  // For regular sections
  final AsyncValue<List<PropertyModel>>? propertiesAsync;

  // For nearby section: tuples of (property, distanceMeters)
  final AsyncValue<List<(PropertyModel, double)>>? nearbyAsync;

  const HomePropertySection({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.onSeeAll,
    this.propertiesAsync,
    this.nearbyAsync,
  }) : assert(
          propertiesAsync != null || nearbyAsync != null,
          'Provide either propertiesAsync or nearbyAsync',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhone = Responsive.isPhone(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Content
        if (nearbyAsync != null)
          _buildNearbyContent(context, nearbyAsync!, isPhone)
        else
          _buildRegularContent(context, propertiesAsync!, isPhone),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRegularContent(
    BuildContext context,
    AsyncValue<List<PropertyModel>> async,
    bool isPhone,
  ) {
    return async.when(
      loading: () => _buildSkeletonRow(isPhone),
      error: (_, __) => _buildError(),
      data: (properties) {
        if (properties.isEmpty) return _buildEmpty();
        final cards = properties
            .map(
              (p) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailPage(id: p.id),
                  ),
                ),
                child: PropertyCard(property: p),
              ),
            )
            .toList();
        return isPhone ? _horizontalScroll(cards) : _wrappedGrid(cards);
      },
    );
  }

  Widget _buildNearbyContent(
    BuildContext context,
    AsyncValue<List<(PropertyModel, double)>> async,
    bool isPhone,
  ) {
    return async.when(
      loading: () => _buildSkeletonRow(isPhone),
      error: (_, __) => _buildError(),
      data: (items) {
        if (items.isEmpty) return _buildEmpty();
        final cards = items
            .map(
              (item) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailPage(id: item.$1.id),
                  ),
                ),
                child: PropertyCard(
                  property: item.$1,
                  distanceMeters: item.$2,
                ),
              ),
            )
            .toList();
        return isPhone ? _horizontalScroll(cards) : _wrappedGrid(cards);
      },
    );
  }

  Widget _horizontalScroll(List<Widget> cards) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: c,
                ))
            .toList(),
      ),
    );
  }

  Widget _wrappedGrid(List<Widget> cards) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards,
    );
  }

  Widget _buildSkeletonRow(bool isPhone) {
    const skeletons = [
      PropertyCardSkeleton(),
      PropertyCardSkeleton(),
      PropertyCardSkeleton(),
    ];
    if (isPhone) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: skeletons
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: s,
                  ))
              .toList(),
        ),
      );
    }
    return Wrap(spacing: 12, runSpacing: 12, children: skeletons);
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 36, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return const SizedBox(
      height: 120,
      child: Center(
        child: Text(
          'Something went wrong. Please try again.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}
