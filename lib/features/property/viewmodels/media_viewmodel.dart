import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/media_model.dart';
import 'package:zoneer_mobile/features/property/repositories/media_repository.dart';

final mediaViewmodelProvider = FutureProvider.family<List<MediaModel>, String>((ref, propertyId) async {
  final repository = ref.read(mediaRepositoryProvider);

  final media = await repository.getMediaByPropertyId(propertyId);

  return media;
});
