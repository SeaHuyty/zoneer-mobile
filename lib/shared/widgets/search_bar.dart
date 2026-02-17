import 'package:flutter/material.dart';
import 'package:zoneer_mobile/features/property/views/properties_list_screen.dart';

class SearchBarApp extends StatelessWidget {
  const SearchBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SearchScreen(),
          ),
        );
      },
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Search properties...",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.filter_list, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}