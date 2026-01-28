import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/wishlist/models/wishlist_model.dart';
import 'package:zoneer_mobile/features/wishlist/repositories/wishlist_repository.dart';

class WishlistViewmodel extends AsyncNotifier<List<WishlistModel>> {
  @override
  Future<List<WishlistModel>> build() async => [];

  Future<void> loadWishlist(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() {
      return ref.read(wishlistRepositoryProvider).getWishlistByUserId(userId);
    });
  }

  Future<void> addToWishlist(WishlistModel wishlist) async {
    await AsyncValue.guard(() async {
      await ref.read(wishlistRepositoryProvider).addToWishlist(wishlist);

      final currentState = state;

      if (currentState is AsyncData<List<WishlistModel>>) {
        state = AsyncValue.data([...currentState.value, wishlist]);
      }
    });
  }

  Future<void> removeFromWishlist(String userId, String propertyId) async {
    await AsyncValue.guard(() async {
      await ref
          .read(wishlistRepositoryProvider)
          .removeFromWishlist(userId, propertyId);

      final currentState = state;

      if (currentState is AsyncData<List<WishlistModel>>) {
        state = AsyncValue.data(
          currentState.value
              .where((w) => !(w.userId == userId && w.propertyId == propertyId))
              .toList(),
        );
      }
    });
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
