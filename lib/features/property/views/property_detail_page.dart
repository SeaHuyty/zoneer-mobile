import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/inquiry/views/inquiry.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:zoneer_mobile/features/property/widgets/amenity_item.dart';
import 'package:zoneer_mobile/features/property/widgets/circle_icon.dart';
import 'package:zoneer_mobile/features/property/widgets/image_widget.dart';
import 'package:zoneer_mobile/features/property/widgets/landlord_card.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_provider.dart';
import 'package:zoneer_mobile/features/user/views/auth/auth_required_screen.dart';
import 'package:zoneer_mobile/features/wishlist/models/wishlist_model.dart';
import 'package:zoneer_mobile/features/wishlist/viewmodels/wishlist_viewmodel.dart';

class PropertyDetailPage extends ConsumerWidget {
  final String id;

  const PropertyDetailPage({super.key, required this.id});

  void _toggleWishlist(WidgetRef ref, BuildContext context) async {
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthRequiredScreen()),
      );
      return;
    }

    try {
      final isInWishlist = await ref.read(
        isPropertyInWishlistProvider(id).future,
      );

      bool success;
      String successMessage;

      if (isInWishlist) {
        // Remove from wishlist
        success = await ref
            .read(wishlistViewmodelProvider.notifier)
            .removeFromWishlist(authUser.id, id);
        successMessage = 'Removed from wishlist';
      } else {
        // Add to wishlist
        final wishlistModel = WishlistModel(
          userId: authUser.id,
          propertyId: id,
        );
        success = await ref
            .read(wishlistViewmodelProvider.notifier)
            .addToWishlist(wishlistModel);
        successMessage = 'Added to wishlist';
      }

      if (context.mounted) {
        if (success) {
          ref.invalidate(isPropertyInWishlistProvider(id));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              duration: const Duration(seconds: 2),
              backgroundColor: isInWishlist ? Colors.red : AppColors.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update wishlist'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Wishlist error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scheduleTour(BuildContext context, PropertyModel property) {
    final authUser = Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthRequiredScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Inquiry(property: property)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = ref.watch(propertyViewModelProvider(id));
    final isInWishlistAsync = ref.watch(isPropertyInWishlistProvider(id));

    return Scaffold(
      body: property.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (property) {
          final landlordAsync = property.landlordId != null
              ? ref.watch(userByIdProvider(property.landlordId!))
              : null;

          final isInWishlist = isInWishlistAsync.value ?? false;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ImageWidget(thumbnail: property.thumbnail, propertyId: id),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleIcon(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.pop(context),
                            ),
                            Row(
                              children: [
                                CircleIcon(
                                  icon: Icons.share_outlined,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 8),
                                CircleIcon(
                                  icon: isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  onTap: () => _toggleWishlist(ref, context),
                                  iconColor: isInWishlist ? Colors.red : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'House in ${property.address}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '\$${property.price} / month',
                            style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 118, 118, 118),
                          ),
                          Text(
                            property.address,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 118, 118, 118),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AmenityItem(
                            icon: Icons.bed_outlined,
                            label: 'Bedrooms',
                            value: property.bedroom.toString(),
                          ),
                          AmenityItem(
                            icon: Icons.bathtub_outlined,
                            label: 'Bathrooms',
                            value: property.bathroom.toString(),
                          ),
                          AmenityItem(
                            icon: Icons.crop_square_outlined,
                            label: 'Area',
                            value: property.squareArea.toString(),
                          ),
                        ],
                      ),

                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (property.description != null &&
                          property.description!.isNotEmpty)
                        Text(property.description!),

                      const SizedBox(height: 16),

                      if (landlordAsync != null)
                        landlordAsync.maybeWhen(
                          data: (landlord) => LandlordCard(landlord: landlord),
                          orElse: () => const SizedBox(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: property.maybeWhen(
        orElse: () => const SizedBox(),
        data: (property) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '\$${property.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ' /Month',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _scheduleTour(context, property),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    'Schedule Tour',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
