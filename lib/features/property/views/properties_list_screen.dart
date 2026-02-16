import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card.dart';
import 'package:zoneer_mobile/features/property/widgets/search_filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading properties: $error')),
        data: (properties) => NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: const Color(0xFFF6F6F6),
                floating: true, // 👈 Appears when scrolling up
                snap: true, // 👈 Smooth snap animation
                elevation: 0,
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
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.black),
                    onPressed: _openFilterSheet,
                  ),
                ],
              ),
            ];
          },

          /// SCROLLABLE CONTENT
          body: ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              /// RESULT COUNT
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  "${properties.length} Properties Found",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              /// PROPERTY CARDS
              ...properties.map(
                (property) => GestureDetector(
                  child: PropertyCard(property: property),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailPage(id: property.id),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const SearchFilterSheet(),
    );
  }
}
