import 'dart:typed_data';
import 'package:zoneer_mobile/features/notification/models/enums/notification_type.dart';
import 'package:zoneer_mobile/features/notification/models/notification_model.dart';
import 'package:zoneer_mobile/features/notification/providers/in_app_notification_provider.dart';
import 'package:zoneer_mobile/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:zoneer_mobile/features/property/viewmodels/property_sections_viewmodel.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

/// Holds data for one photo slot (either new bytes or an existing URL).
typedef PhotoData = ({Uint8List? bytes, String? ext, String? existingUrl});

class UploadPropertyViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> submit({
    // Thumbnail – index 0 of the photo list
    required Uint8List? thumbnailBytes,
    required String? thumbnailExt,
    required String? existingThumbnailUrl,
    // Additional photos (indices 1–9)
    required List<PhotoData> additionalPhotos,
    // Existing URLs the user removed — will be deleted from storage
    required List<String> removedImageUrls,
    // The property being edited, or null when creating
    required PropertyModel? existingProperty,
    // Basic fields
    required double price,
    required int bedroom,
    required int bathroom,
    required double squareArea,
    required String address,
    required double latitude,
    required double longitude,
    required String description,
    required String type,
    required String name,
    // Amenities
    required Map<String, dynamic>? propertyFeatures,
    required Map<String, dynamic>? securityFeatures,
    required Map<String, dynamic>? badgeOptions,
  }) async {
    final locationUrl = 'https://www.google.com/maps?q=$latitude,$longitude';

    state = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final repo = ref.read(propertyRepositoryProvider);

      // --- Upload thumbnail ---
      String thumbnailUrl = existingThumbnailUrl ?? '';
      if (thumbnailBytes != null) {
        thumbnailUrl = await repo.uploadImage(
          thumbnailBytes,
          thumbnailExt ?? 'jpg',
          userId,
          index: 0,
        );
      }

      // --- Upload any new additional images ---
      final additionalUrls = <String>[];
      for (var i = 0; i < additionalPhotos.length; i++) {
        final photo = additionalPhotos[i];
        if (photo.bytes != null) {
          final url = await repo.uploadImage(
            photo.bytes!,
            photo.ext ?? 'jpg',
            userId,
            index: i + 1,
          );
          additionalUrls.add(url);
        } else if (photo.existingUrl != null) {
          additionalUrls.add(photo.existingUrl!);
        }
      }

      // --- Persist property ---
      final String propertyId;
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
            type: type,
            name: name,
            landlordId: userId,
            verifyStatus: existingProperty.verifyStatus,
            propertyStatus: existingProperty.propertyStatus,
            propertyFeatures: propertyFeatures,
            securityFeatures: securityFeatures,
            badgeOptions: badgeOptions,
          ),
        );
        propertyId = existingProperty.id;
      } else {
        final createdProperty = await repo.createProperty(
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
            type: type,
            name: name,
            landlordId: userId,
            propertyFeatures: propertyFeatures,
            securityFeatures: securityFeatures,
            badgeOptions: badgeOptions,
          ),
        );
        propertyId = createdProperty.id;

        // Instantly add the new property to the landlord list — no reload needed.
        ref
            .read(landlordPropertiesProvider(userId).notifier)
            .prependProperty(createdProperty);

        // Notify user the newly created property is under review.
        var helper = NotificationHelper.upload;
        final newNotification = NotificationModel(
          userId: userId,
          title: helper.title,
          message: helper.message,
          type: NotificationType.propertyVerification,
          metadata: {'property_id': propertyId},
        );
        await ref
            .read(notificationsViewModelProvider.notifier)
            .createNotification(newNotification);

        // Show in-app banner immediately after upload.
        ref.read(inAppNotificationProvider.notifier).show(newNotification);
      }

      // --- Manage property_media records ---
      if (existingProperty != null) {
        // Replace all existing media
        await repo.deletePropertyMediasByPropertyId(propertyId);
      }
      if (additionalUrls.isNotEmpty) {
        await repo.insertPropertyMedias(propertyId, additionalUrls);
      }

      // --- Delete removed files from storage ---
      if (removedImageUrls.isNotEmpty) {
        await repo.deleteStorageImages(removedImageUrls);
      }

      // For edit: reload landlord list to reflect changes (create case handled
      // instantly above via prependProperty).
      if (existingProperty != null) {
        ref.invalidate(landlordPropertiesProvider(userId));
      }
      // Refresh public-facing property queries.
      ref.invalidate(mapPropertiesProvider);
      ref.invalidate(allPropertiesSectionProvider);
      ref.invalidate(phnomPenhSectionProvider);
      ref.invalidate(siemReapSectionProvider);
      ref.invalidate(nearbyPropertiesSectionProvider);
    } finally {
      state = false;
    }
  }
}

final uploadPropertyViewModelProvider =
    NotifierProvider<UploadPropertyViewModel, bool>(
      UploadPropertyViewModel.new,
    );
