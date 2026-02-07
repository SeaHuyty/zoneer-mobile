import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/user/views/auth/auth_required_screen.dart';
import 'package:zoneer_mobile/features/wishlist/widgets/wishlist_empty_state.dart';
import 'package:zoneer_mobile/shared/widgets/cards/property_wishlist_card.dart';

class WishlistView extends ConsumerWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      return const AuthRequiredScreen();
    } 

    final wishlist = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: wishlist.isEmpty
          ? WishlistEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final property = wishlist[index];
                return WishlistPropertyCard(
                  property: property,
                  onRemove: () {
                    // TODO: Implement remove from wishlist
                    // ref.read(wishlistNotifierProvider.notifier).removeProperty(property.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Removed from wishlist'),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
