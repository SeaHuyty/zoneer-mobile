import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_provider.dart';
import 'package:zoneer_mobile/features/user/widgets/profile_header_card.dart';
import 'package:zoneer_mobile/features/user/widgets/section_card.dart';

class LandlordProfileSetting extends ConsumerWidget {
  const LandlordProfileSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = Supabase.instance.client.auth.currentUser;
    final userAsync = ref.watch(userByIdProvider(authUser!.id));

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
        scrolledUnderElevation: 0, // remove scroll elevation color change
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: userAsync.when(
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load profile information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        data: (user) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            ProfileHeaderCard(user: user),
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
                  icon: Icons.dangerous,
                  label: "Danger Zone",
                  onTap: () {
                    // TODO: switch role
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            SectionCard(
              title: 'Logout',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, //keeps content centered
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, size: 18, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
