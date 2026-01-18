import 'package:zoneer_mobile/features/property/models/enums/media_type.dart';

class MediaModel {
  final String id;
  final String url;
  final String propertyId;

  final MediaType type;

  const MediaModel({
    required this.id,
    required this.url,
    this.type = MediaType.defaultType,
    required this.propertyId,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      url: json['url'] as String,
      type: MediaType.fromValue(json['type']),
      propertyId: json['property_id'] as String,
    );
  }
}
