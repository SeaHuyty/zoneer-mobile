import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/user/widgets/profile_header_card.dart';
import 'package:zoneer_mobile/features/user/widgets/section_card.dart';

class LandlordProfileSetting extends ConsumerWidget {
  const LandlordProfileSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // soft page background
      appBar: AppBar(
        title: const Text(
          'Profile Setting',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFF6F6F6), // soft page background
        surfaceTintColor: Colors.white, // Material 3 tint
        scrolledUnderElevation: 0,      // remove scroll elevation color change
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          ProfileHeaderCard(),
          const SizedBox(height: 14),
          SectionCard(
            title: "Personal Info",
            children: const [
              InfoIconRow(
                rowIcon: Icons.email_outlined,
                text: 'username@gmail.com',
                iconColor: AppColors.primary,
                textColor: Colors.black,
                textSize: 14,
                iconSize: 18,
              ),
              SizedBox(height: 12),
              InfoIconRow(
                rowIcon: Icons.phone,
                text: '+855 016 260 218',
                iconColor: AppColors.primary,
                textColor: Colors.black,
                textSize: 14,
                iconSize: 18,
              ),
              SizedBox(height: 12),
              InfoIconRow(
                rowIcon: Icons.person_pin,
                text: 'Landlord',
                iconColor: AppColors.primary,
                textColor: Colors.black,
                textSize: 14,
                iconSize: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SectionCard(
            title: "Profile Action",
            children: [
              ActionRow(
                icon: Icons.edit,
                label: "Edit Profile",
                onTap: () {
                  // TODO: navigate to edit profile
                },
              ),
              const SizedBox(height: 10),
              ActionRow(
                icon: Icons.swap_horiz_outlined,
                label: "Switch to Tenant",
                onTap: () {
                  // TODO: switch role
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          SectionCard(
            title: 'Danger Zone', 
            children: [
              //Logout button styled like a card action
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // logout logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, //keeps content centered
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.delete_forever,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]
          )
        ],
      ),
    );
  }
}