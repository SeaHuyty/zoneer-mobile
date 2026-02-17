import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/views/property_detail_page.dart';
import 'package:zoneer_mobile/features/property/widgets/property_card.dart';
import 'package:zoneer_mobile/features/user/views/auth/auth_required_screen.dart';
import 'package:zoneer_mobile/features/wishlist/viewmodels/wishlist_viewmodel.dart';
import 'package:zoneer_mobile/features/wishlist/widgets/wishlist_empty_state.dart';

class WishlistView extends ConsumerStatefulWidget {
  const WishlistView({super.key});

  @override
  ConsumerState<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends ConsumerState<WishlistView> {
  @override
  void initState() {
    super.initState();
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser != null) {
      Future.microtask(() {
        ref.read(wishlistViewmodelProvider.notifier).loadWishlist(authUser.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      return const AuthRequiredScreen();
    }

    final wishlistAsync = ref.watch(wishlistViewmodelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading wishlist: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(wishlistViewmodelProvider.notifier)
                      .loadWishlist(authUser.id);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (wishlistItems) {
          if (wishlistItems.isEmpty) {
            return const WishlistEmptyState();
          }

          // Watch the batch properties provider
          final propertiesAsync = ref.watch(wishlistPropertiesProvider);

          return propertiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading properties: $err'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(wishlistPropertiesProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (properties) {
              final propertyMap = {
                for (var property in properties) property.id: property,
              };

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final wishlistItem = wishlistItems[index];
                  final property = propertyMap[wishlistItem.propertyId];

                  if (property == null) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    child: PropertyCard(property: property),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PropertyDetailPage(id: property.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
