import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_decoration.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecoration.card(),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          CircleAvatar(
  radius: 48,
  backgroundImage: (user.profileUrl != null && user.profileUrl!.isNotEmpty)
      ? NetworkImage(user.profileUrl!)
      : null,
  backgroundColor: const Color(0xFFE9E9E9),
  child: (user.profileUrl == null || user.profileUrl!.isEmpty)
      ? const Icon(Icons.person, size: 48, color: Colors.grey)
      : null,
),

          const SizedBox(height: 12),
          Text(
            user.fullname,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onEdit, child: const Text("Edit Profile")),
        ],
      ),
    );
  }
}
