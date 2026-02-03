import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';

class LandlordCard extends StatelessWidget {
  final UserModel landlord;

  const LandlordCard({super.key, required this.landlord});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Landlord',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // TODO: CHECK Verify status
              if (true)
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (landlord.profileUrl != null &&
                            landlord.profileUrl!.isNotEmpty)
                        ? NetworkImage(landlord.profileUrl!)
                        : null,
                    child: (landlord.profileUrl == null ||
                            landlord.profileUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: Text(
                      landlord.fullname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  ActionButton(
                    icon: Icons.phone_outlined,
                    onTap: () {
                      // TODO: Add call functionality
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    icon: Icons.message_outlined,
                    onTap: () {
                      // TODO: Add message functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
