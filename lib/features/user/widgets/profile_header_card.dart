import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_decoration.dart';


class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDecoration.card(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFFE9E9E9),
            child: const Icon(Icons.person, size: 46, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sophavisnuka',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFFEFEFEF),
            ),
            child: const Text(
              'Landlord',
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}