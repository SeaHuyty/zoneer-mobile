import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/providers/profile_type_provider.dart';
import 'package:zoneer_mobile/core/utils/app_decoration.dart';
import 'package:zoneer_mobile/features/user/views/landlord/landlord_profile_setting.dart';
import 'package:zoneer_mobile/features/user/widgets/profile_header_card.dart';
import 'package:zoneer_mobile/features/user/widgets/section_card.dart';

class LandlordProfile extends ConsumerWidget {
  const LandlordProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // soft page background
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
        scrolledUnderElevation: 0,      // remove scroll elevation color change
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          ProfileHeaderCard(),
          const SizedBox(height: 14,),
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
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Simulate loading (remove this when backend is implemented)
                  await Future.delayed(const Duration(milliseconds: 800));
                  
                  // Close loading dialog
                  if (context.mounted) Navigator.of(context).pop();
                  
                  // Switch profile type using provider
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
                    MaterialPageRoute(builder: (builder) => LandlordProfileSetting())
                  );
                },
              ),
            ]
          ),
          const SizedBox(height: 14,),
          SectionCard(
            title: 'Your Properties', 
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(6, (index) {
                  return Container(
                    decoration: AppDecoration.card(),
                    height: 50,
                    alignment: Alignment.center,
                    child: Text('Card $index'),
                  );
                }),
              )
            ],
          )
        ],
      ),
    );
  }
}