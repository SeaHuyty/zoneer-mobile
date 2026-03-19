import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';

class HomePropertiesCategory extends StatefulWidget {
  const HomePropertiesCategory({super.key});

  @override
  State<HomePropertiesCategory> createState() => _HomePropertiesCategoryState();
}

class _HomePropertiesCategoryState extends State<HomePropertiesCategory> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.home, 'label': 'Room'},
    {'icon': Icons.apartment_outlined, 'label': 'Apartment'},
    {'icon': Icons.villa, 'label': 'Condo'},
    {'icon': Icons.cabin_outlined, 'label': 'House'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE0E0E0),
                  width: 1.2,
                ),

              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    categories[index]['icon'] as IconData,
                    size: 20,
                    color: isSelected ? AppColors.white : AppColors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    categories[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
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
}
