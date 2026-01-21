import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/wishlist/widgets/wishlist_empty_state.dart';
import 'package:zoneer_mobile/shared/widgets/cards/property_wishlist_card.dart';

class WishlistView extends ConsumerWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with your actual auth provider to check if user is logged in
    // final isLoggedIn = ref.watch(authStateProvider);
    final isLoggedIn =
        false; // Change to false to test empty state for non-logged-in users

    // TODO: Replace with your actual wishlist provider
    // final wishlistAsync = ref.watch(wishlistNotifierProvider);

    // Mock data for UI testing (remove when backend is ready)
    final List<PropertyModel> wishlist = [
      // PropertyModel(
      //   id: '1',
      //   price: 1200,
      //   bedroom: 2,
      //   bathroom: 2,
      //   squareArea: 1200,
      //   address: 'Rich House',
      //   locationUrl: 'downtown',
      // ),
      // PropertyModel(
      //   id: '2',
      //   price: 950,
      //   bedroom: 1,
      //   bathroom: 1,
      //   squareArea: 800,
      //   address: 'Cozy Studio',
      //   locationUrl: 'park',
      // ),
      // PropertyModel(
      //   id: '3',
      //   price: 1500,
      //   bedroom: 3,
      //   bathroom: 2,
      //   squareArea: 1800,
      //   address: 'Family Home',
      //   locationUrl: 'residential',
      // ),
      // PropertyModel(
      //   id: '4',
      //   price: 1100,
      //   bedroom: 2,
      //   bathroom: 1,
      //   squareArea: 1000,
      //   address: 'Modern Condo',
      //   locationUrl: 'midtown',
      // ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body:
          wishlist.isEmpty
              ? WishlistEmptyState(
                isLoggedIn: isLoggedIn,
                onRegister: () {
                  // TODO: Navigate to register screen
                  // Navigator.of(context).pushNamed('/register');
                },
                onLogin: () {
                  // TODO: Navigate to login screen
                  // Navigator.of(context).pushNamed('/login');
                },
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final property = wishlist[index];
                  return PropertyCard(
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
