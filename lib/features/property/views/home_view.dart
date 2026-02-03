import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';
import 'package:zoneer_mobile/features/property/widgets/home_header.dart';
import 'package:zoneer_mobile/features/property/widgets/home_properties_category.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card.dart';
import 'package:zoneer_mobile/shared/widgets/search_bar.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesViewModelProvider);

    return Scaffold(
      appBar: const HomeHeader(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SearchBarApp(),
              const SizedBox(height: 20),
              const HomePropertiesCategory(),

              propertiesAsync.when(
                data: (properties) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  builder: (context) => PropertyDetailPage(id: property.id),
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
            ],
          ),
        ),
      ),
    );
  }
}
