import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/wishlist/models/wishlist_model.dart';
import 'package:zoneer_mobile/features/wishlist/repositories/wishlist_repository.dart';

class WishlistViewmodel extends Notifier<AsyncValue<List<WishlistModel>>> {
  @override
  AsyncValue<List<WishlistModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadWishlist(String userId) async {
    state = AsyncValue.loading();
    try {
      final wishlist = await ref.read(wishlistRepositoryProvider).getWishlistByUserId(userId);
      state = AsyncValue.data(wishlist);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addToWishlist(WishlistModel wishlist) async {
    try {
      await ref.read(wishlistRepositoryProvider).addToWishlist(wishlist);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeFromWishlist(String userId, String propertyId) async {
    try {
      await ref.read(wishlistRepositoryProvider).removeFromWishlist(userId, propertyId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearWishlist(String userId) async {
    try {
      await ref.read(wishlistRepositoryProvider).clearWishlist(userId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final wishlistViewmodelProvider = NotifierProvider<WishlistViewmodel, AsyncValue<List<WishlistModel>>>(() {
  return WishlistViewmodel();
});