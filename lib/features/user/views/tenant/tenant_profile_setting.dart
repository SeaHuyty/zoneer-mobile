import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/providers/profile_type_provider.dart';
import 'package:zoneer_mobile/features/inquiry/views/my_inquiries.dart';
import 'package:zoneer_mobile/features/notification/views/notification_screen.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_provider.dart';
import 'package:zoneer_mobile/features/user/views/auth/auth_required_screen.dart';
import 'package:zoneer_mobile/features/user/views/tenant/edit_profile_screen.dart';
import 'package:zoneer_mobile/features/user/widgets/action_row.dart';
import 'package:zoneer_mobile/features/user/widgets/profile_header_card.dart';
import 'package:zoneer_mobile/features/user/widgets/section_card.dart';
import 'package:zoneer_mobile/features/wishlist/views/wishlist_view.dart';

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
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            ProfileHeaderCard(
              user: user,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// My Activity
            SectionCard(
              title: "My Activity",
              children: [
                ActionRow(
                  icon: Icons.favorite_border,
                  label: "Saved Properties",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistView(),
                      ),
                    );
                  },
                ),
                ActionRow(
                  icon: Icons.assignment_outlined,
                  label: "My Applications",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyInquiries(),
                      ),
                    );
                  },
                ),
                ActionRow(
                  icon: Icons.chat_bubble_outline,
                  label: "Messages",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.event_outlined,
                  label: "Scheduled Visits",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Profile Info
            SectionCard(
              title: "Profile Information",
              children: [
                ActionRow(
                  icon: Icons.person_outline,
                  label: "Personal Information",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.home_work_outlined,
                  label: "Rental Preferences",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.work_outline,
                  label: "Employment & Income",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Documents
            SectionCard(
              title: "Documents & Verification",
              children: [
                ActionRow(
                  icon: Icons.folder_open,
                  label: "My Documents",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.verified_user_outlined,
                  label: "Verification Status",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Settings
            SectionCard(
              title: "Settings",
              children: [
                ActionRow(
                  icon: Icons.notifications_outlined,
                  label: "Notifications",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                ActionRow(
                  icon: Icons.lock_outline,
                  label: "Privacy & Security",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.swap_horiz_outlined,
                  label: "Switch to Landlord",
                  onTap: () {
                    ref.read(profileTypeProvider.notifier).switchToLandlord();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Support
            SectionCard(
              title: "Support",
              children: [
                ActionRow(
                  icon: Icons.help_outline,
                  label: "Help Center",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.support_agent,
                  label: "Contact Support",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Logout
            SectionCard(
              title: "Account",
              children: [
                ActionRow(
                  icon: Icons.logout,
                  label: "Logout",
                  textColor: Colors.red,
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
