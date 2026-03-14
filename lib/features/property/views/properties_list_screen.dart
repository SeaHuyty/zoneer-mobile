import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/providers/navigation_provider.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';
import 'package:zoneer_mobile/features/property/widgets/home_properties_category.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card.dart';
import 'package:zoneer_mobile/features/property/widgets/search_filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _activeFilters;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () {
            ref.read(mapTabViewProvider.notifier).showMap();
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.map, color: Colors.white, size: 18),
          label: const Text(
            'Map View',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading properties: $error')),
        data: (properties) {
          final searchQueryLower = _searchQuery.toLowerCase();
          final filtered = properties.where((p) {
            if (_searchQuery.isNotEmpty &&
                !p.address.toLowerCase().contains(searchQueryLower)) {
              return false;
            }
            if (_activeFilters != null) {
              final range = _activeFilters!['priceRange'] as RangeValues;
              if (p.price < range.start || p.price > range.end) return false;
              final beds = _activeFilters!['beds'] as int;
              if (p.bedroom < beds) return false;
              final baths = _activeFilters!['baths'] as int;
              if (p.bathroom < baths) return false;
            }
            return true;
          }).toList();
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xFFF6F6F6),
                  floating: true,
                  snap: true,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(
                      _activeFilters != null ? 120 : 100,
                    ),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF6F6F6),
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const HomePropertiesCategory(),
                          const SizedBox(height: 10),
                          Text(
                            '${filtered.length} Properties Found',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (_activeFilters != null)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _activeFilters = null),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Clear filters',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  title: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search location...",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.tune,
                              color: AppColors.primary,
                            ),
                            onPressed: _openFilterSheet,
                          ),
                          if (_activeFilters != null)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No properties match your criteria.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 5),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 1.25,
                                ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final property = filtered[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PropertyDetailPage(id: property.id),
                                  ),
                                ),
                                child: PropertyCard(property: property),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const SearchFilterSheet(),
    );
    if (result != null) {
      setState(() => _activeFilters = result);
    }
  }
}
