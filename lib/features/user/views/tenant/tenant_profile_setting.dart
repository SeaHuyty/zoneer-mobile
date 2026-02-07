import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/providers/profile_type_provider.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_provider.dart';
import 'package:zoneer_mobile/features/user/views/auth/auth_required_screen.dart';
import 'package:zoneer_mobile/features/user/widgets/profile_header_card.dart';
import 'package:zoneer_mobile/features/user/widgets/section_card.dart';

class TenantProfileSetting extends ConsumerWidget {
  const TenantProfileSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      return const AuthRequiredScreen();
    } 

    final userAsync = ref.watch(userByIdProvider(authUser.id));
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Tenant Profile Setting',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFF6F6F6),
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: userAsync.when(
        error: (error, stackTrace) {
          // DETAILED ERROR DISPLAY
          print('❌ Error loading user:');
          print('Error: $error');
          print('Stack trace: $stackTrace');

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'User not found in database',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your account exists but user profile is missing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Try to create the user record manually
                      final authUser =
                          Supabase.instance.client.auth.currentUser;
                      if (authUser != null) {
                        try {
                          // This would require importing and using your user mutation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please contact support or re-register',
                              ),
                            ),
                          );
                        } catch (e) {
                          print('Error: $e');
                        }
                      }
                    },
                    child: Text('Contact Support'),
                  ),
                ],
              ),
            ),
          );
        },

        loading: () => CircularProgressIndicator(),
        data: (user) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            ProfileHeaderCard(user: user),
            const SizedBox(height: 14),
            SectionCard(
              title: "Personal Info",
              children: [
                InfoIconRow(
                  rowIcon: Icons.email_outlined,
                  text: user.fullname,
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
                  text: 'tenant',
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
                ActionRow(
                  icon: Icons.swap_horiz_outlined,
                  label: "Switch to landlord",
                  onTap: () async {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    // Simulate loading (remove this when backend is implemented)
                    await Future.delayed(const Duration(milliseconds: 800));

                    // Close loading dialog
                    if (context.mounted) Navigator.of(context).pop();

                    // Switch profile type using provider
                    if (context.mounted) {
                      ref.read(profileTypeProvider.notifier).switchToLandlord();
                    }
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
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
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
