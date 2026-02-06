import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card.dart';

class HomePropertySection extends StatelessWidget {
  final String title;
  final AsyncValue<List<PropertyModel>> propertiesAsync;
  final VoidCallback? onSeeAll;

  const HomePropertySection({super.key, required this.title, required this.propertiesAsync, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(onPressed: onSeeAll, child: Text('See all')),
          ],
        ),
        propertiesAsync.when(
          data: (properties) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: properties
                  .map(
                    (property) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        child: PropertyCard(property: property),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PropertyDetailPage(id: property.id),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
