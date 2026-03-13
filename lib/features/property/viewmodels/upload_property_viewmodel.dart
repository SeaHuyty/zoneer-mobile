import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

class UploadPropertyViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  /// Returns the URL of the saved thumbnail.
  /// Uploads a new image if [thumbnailBytes] is provided, otherwise reuses [existingThumbnailUrl].
  Future<void> submit({
    required Uint8List? thumbnailBytes,
    required String? thumbnailExt,
    required String? existingThumbnailUrl,
    required PropertyModel? existingProperty,
    required double price,
    required int bedroom,
    required int bathroom,
    required double squareArea,
    required String address,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    final locationUrl = 'https://www.google.com/maps?q=$latitude,$longitude';
    final propertiesNotifier =
        ref.read(propertiesViewModelProvider.notifier);

    // --- Optimistic local state update ---
    if (existingProperty != null) {
      propertiesNotifier.optimisticallyUpdate(
        existingProperty.copyWith(
          price: price,
          bedroom: bedroom,
          bathroom: bathroom,
          squareArea: squareArea,
          address: address,
          locationUrl: locationUrl,
          latitude: latitude,
          longitude: longitude,
          description: description,
          thumbnail: existingThumbnailUrl ?? existingProperty.thumbnail,
        ),
      );
    } else {
      propertiesNotifier.optimisticallyAdd(
        PropertyModel(
          id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}',
          price: price,
          bedroom: bedroom,
          bathroom: bathroom,
          squareArea: squareArea,
          address: address,
          locationUrl: locationUrl,
          latitude: latitude,
          longitude: longitude,
          description: description,
          thumbnail: existingThumbnailUrl ?? '',
        ),
      );
    }

    state = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final repo = ref.read(propertyRepositoryProvider);

      String thumbnailUrl = existingThumbnailUrl ?? '';
      if (thumbnailBytes != null) {
        thumbnailUrl = await repo.uploadThumbnail(
          thumbnailBytes,
          thumbnailExt ?? 'jpg',
          userId,
        );
      }

      if (existingProperty != null) {
        await repo.updateProperty(
          PropertyModel(
            id: existingProperty.id,
            price: price,
            bedroom: bedroom,
            bathroom: bathroom,
            squareArea: squareArea,
            address: address,
            locationUrl: locationUrl,
            latitude: latitude,
            longitude: longitude,
            description: description,
            thumbnail: thumbnailUrl,
            landlordId: userId,
            verifyStatus: existingProperty.verifyStatus,
            propertyStatus: existingProperty.propertyStatus,
          ),
        );
      } else {
        await repo.createProperty(
          PropertyModel(
            id: '',
            price: price,
            bedroom: bedroom,
            bathroom: bathroom,
            squareArea: squareArea,
            address: address,
            locationUrl: locationUrl,
            latitude: latitude,
            longitude: longitude,
            description: description,
            thumbnail: thumbnailUrl,
            landlordId: userId,
          ),
        );
      }

    } finally {
      state = false;
    }
  }
}

final uploadPropertyViewModelProvider =
    NotifierProvider<UploadPropertyViewModel, bool>(
  UploadPropertyViewModel.new,
);
