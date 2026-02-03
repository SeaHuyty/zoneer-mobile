import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:zoneer_mobile/features/property/widgets/image_widget.dart';
import 'package:zoneer_mobile/features/property/widgets/landlord_card.dart';
import 'package:zoneer_mobile/features/user/viewmodels/users_viewmodel.dart';

class PropertyDetailPage extends ConsumerWidget {
  final String id;

  const PropertyDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyViewModelProvider(id));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_outlined)),
        ],
      ),
      body: propertyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (property) {
          final landlordAsync = property.landlordId != null
              ? ref.watch(userViewModelProvider(property.landlordId!))
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageWidget(imageUrl: property.thumbnail),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('House in ${property.address}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    Text('\$${property.price.toString()} / month', style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
                const Divider(color: Colors.grey, thickness: 0.8),
                
                const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AmenityItem(icon: Icons.bed_outlined, label: 'Bedrooms', value: property.bedroom.toString()),
                    AmenityItem(icon: Icons.bathtub_outlined, label: 'Bathrooms', value: property.bathroom.toString()),
                    AmenityItem(icon: Icons.crop_square_outlined, label: 'Area', value: property.squareArea.toString()),
                  ],
                ),
                const Divider(color: Colors.grey, thickness: 0.8),
                
                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                if (property.description != null && property.description!.isNotEmpty)
                  Text(property.description!),
                const SizedBox(height: 16),

                if (landlordAsync != null)
                  landlordAsync.maybeWhen(
                    data: (landlord) => LandlordCard(landlord: landlord),
                    orElse: () => const SizedBox(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AmenityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AmenityItem({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(value),
          ],
        ),
      ],
    );
  }
}
