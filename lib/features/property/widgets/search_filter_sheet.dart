import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  RangeValues priceRange = const RangeValues(500, 5000);

  int beds = 1;
  int baths = 1;

  String selectedType = "Apartment";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filters",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),

            const SizedBox(height: 20),

            /// PRICE
            const Text("Price Range"),
            RangeSlider(
              values: priceRange,
              min: 0,
              max: 10000,
              divisions: 100,
              labels: RangeLabels(
                "\$${priceRange.start.round()}",
                "\$${priceRange.end.round()}",
              ),
              onChanged: (values) {
                setState(() => priceRange = values);
              },
            ),

            const SizedBox(height: 20),

            /// BEDS
            const Text("Bedrooms"),
            Row(
              children: List.generate(5, (index) {
                return ChoiceChip(
                  label: Text("${index + 1}+"),
                  selected: beds == index + 1,
                  onSelected: (_) {
                    setState(() => beds = index + 1);
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            /// BATHS
            const Text("Bathrooms"),
            Row(
              children: List.generate(5, (index) {
                return ChoiceChip(
                  label: Text("${index + 1}+"),
                  selected: baths == index + 1,
                  onSelected: (_) {
                    setState(() => baths = index + 1);
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            /// HOUSE TYPE
            const Text("Property Type"),
            Wrap(
              spacing: 8,
              children: ["Apartment", "House", "Villa", "Studio"]
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type),
                      selected: selectedType == type,
                      onSelected: (_) {
                        setState(() => selectedType = type);
                      },
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 30),

            /// APPLY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Apply Filters"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
