import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/providers/profile_type_provider.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_provider.dart';
import 'package:zoneer_mobile/features/user/views/auth/auth_required_screen.dart';
import 'package:zoneer_mobile/features/user/views/landlord/landlord_profile_setting.dart';
import 'package:zoneer_mobile/features/user/widgets/action_row.dart';
import 'package:zoneer_mobile/features/user/widgets/profile_header_card.dart';
import 'package:zoneer_mobile/features/user/widgets/section_card.dart';

class LandlordProfile extends ConsumerWidget {
  const LandlordProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      return const AuthRequiredScreen();
    }

    final userAsync = ref.watch(userByIdProvider(authUser.id));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Landlord Profile',
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
        error: (error, stackTrace) => const SizedBox(),
        loading: () => CircularProgressIndicator(),
        data: (user) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            ProfileHeaderCard(
              user: user,
              onEdit: () {
                // TODO: navigate to edit profile
              },
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'Action',
              children: [
                ActionRow(
                  icon: Icons.add,
                  label: "Create Property",
                  onTap: () {
                    // TODO: navigate to edit profile
                  },
                ),
                ActionRow(
                  icon: Icons.swap_horiz_outlined,
                  label: "Switch to Tenant",
                  onTap: () async {
                    if (context.mounted) {
                      ref.read(profileTypeProvider.notifier).switchToTenant();
                    }
                  },
                ),
                ActionRow(
                  icon: Icons.edit,
                  label: "Setting",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (builder) => LandlordProfileSetting(),
                      ),
                    );
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
