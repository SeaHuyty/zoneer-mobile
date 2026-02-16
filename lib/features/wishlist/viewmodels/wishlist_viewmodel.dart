import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';
import 'package:zoneer_mobile/features/wishlist/models/wishlist_model.dart';
import 'package:zoneer_mobile/features/wishlist/repositories/wishlist_repository.dart';

class WishlistViewmodel extends AsyncNotifier<List<WishlistModel>> {
  @override
  Future<List<WishlistModel>> build() async => [];

  Future<void> loadWishlist(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return ref.read(wishlistRepositoryProvider).getWishlistByUserId(userId);
    });
  }

  Future<bool> addToWishlist(WishlistModel wishlist) async {
    state = await AsyncValue.guard(() async {
      await ref.read(wishlistRepositoryProvider).addToWishlist(wishlist);

      final currentState = state;

      if (currentState is AsyncData<List<WishlistModel>>) {
        return [...currentState.value, wishlist];
      }

      return [wishlist];
    });

    // Return true if success, false if error
    return state.hasValue && !state.hasError;
  }

  Future<bool> removeFromWishlist(String userId, String propertyId) async {
    state = await AsyncValue.guard(() async {
      await ref
          .read(wishlistRepositoryProvider)
          .removeFromWishlist(userId, propertyId);

      final currentState = state;

      if (currentState is AsyncData<List<WishlistModel>>) {
        return currentState.value
            .where((w) => !(w.userId == userId && w.propertyId == propertyId))
            .toList();
      }

      return currentState.value ?? <WishlistModel>[];
    });

    // Return true if success, false if error
    return state.hasValue && !state.hasError;
  }

  Future<void> clearWishlist(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await ref.read(wishlistRepositoryProvider).clearWishlist(userId);

      return <WishlistModel>[];
    });
  }
}

final wishlistViewmodelProvider =
    AsyncNotifierProvider<WishlistViewmodel, List<WishlistModel>>(
      WishlistViewmodel.new,
    );

final isPropertyInWishlistProvider = FutureProvider.family<bool, String>((
  ref,
  propertyId,
) async {
  final authUser = Supabase.instance.client.auth.currentUser;

  if (authUser == null) {
    return false;
  }

  return ref
      .read(wishlistRepositoryProvider)
      .isPropertyInWishlist(authUser.id, propertyId);
});

final wishlistPropertiesProvider = FutureProvider.autoDispose<List<PropertyModel>>((ref) async {
  final authUser = Supabase.instance.client.auth.currentUser;

  if (authUser == null) {
    return [];
  }

  final wishlistItems = await ref.watch(wishlistViewmodelProvider.future);

  if (wishlistItems.isEmpty) {
    return [];
  }

  final propertyIds = wishlistItems.map((item) => item.propertyId).toList();
  
  return ref.read(propertyRepositoryProvider).getPropertiesByIds(propertyIds);
});