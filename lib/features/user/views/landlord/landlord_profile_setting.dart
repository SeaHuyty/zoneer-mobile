import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/providers/profile_type_provider.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_provider.dart';
import 'package:zoneer_mobile/features/user/widgets/action_row.dart';
import 'package:zoneer_mobile/features/user/widgets/profile_header_card.dart';
import 'package:zoneer_mobile/features/user/widgets/section_card.dart';

class LandlordProfileSetting extends ConsumerWidget {
  const LandlordProfileSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      return const SizedBox();
    }

    final userAsync = ref.watch(userByIdProvider(authUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (user) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            /// Header
            ProfileHeaderCard(
              user: user,
              onEdit: () {
                // TODO: navigate to edit profile
              },
            ),

            const SizedBox(height: 20),

            /// Landlord Activity
            SectionCard(
              title: "My Activity",
              children: [
                ActionRow(
                  icon: Icons.home_work_outlined,
                  label: "My Properties",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.assignment_outlined,
                  label: "Tenant Applications",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.chat_bubble_outline,
                  label: "Messages",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.people_outline,
                  label: "My Tenants",
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
                  icon: Icons.business_outlined,
                  label: "Business / Ownership Info",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.account_balance_outlined,
                  label: "Payment & Payout Details",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Properties & Management
            SectionCard(
              title: "Property Management",
              children: [
                ActionRow(
                  icon: Icons.add_home_outlined,
                  label: "Add New Property",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.settings_outlined,
                  label: "Property Settings",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Verification
            SectionCard(
              title: "Verification & Documents",
              children: [
                ActionRow(
                  icon: Icons.verified_user_outlined,
                  label: "Verification Status",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.folder_open,
                  label: "My Documents",
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
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.lock_outline,
                  label: "Privacy & Security",
                  onTap: () {},
                ),
                ActionRow(
                  icon: Icons.swap_horiz_outlined,
                  label: "Switch to Tenant",
                  onTap: () {
                    ref.read(profileTypeProvider.notifier).switchToTenant();
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
