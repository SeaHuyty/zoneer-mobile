import 'package:flutter/material.dart';

class HomePropertiesCategory extends StatefulWidget {
  const HomePropertiesCategory({super.key});

  @override
  State<HomePropertiesCategory> createState() => _HomePropertiesCategoryState();
}

class _HomePropertiesCategoryState extends State<HomePropertiesCategory> {
  final List<Map<String, String>> categories = [
    {'icon': 'assets/icons/category1.png', 'label': 'Rent House'},
    {'icon': 'assets/icons/category2.png', 'label': 'Apartment'},
    {'icon': 'assets/icons/category3.png', 'label': 'Resident'},
    {'icon': 'assets/icons/category4.png', 'label': 'Traditional'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 128,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Image.asset(
                    categories[index]['icon']!,
                    width: 76,
                    height: 76,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(categories[index]['label']!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
