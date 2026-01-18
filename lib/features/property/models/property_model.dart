import 'package:zoneer_mobile/features/property/models/enums/property_status.dart';
import 'package:zoneer_mobile/shared/models/enums/verify_status.dart';

class PropertyModel {
  final String id;
  final double price;
  final int bedroom;
  final int bathroom;
  final double squareArea;
  final String address;
  final String locationUrl;
  final String? description;

  final Map<String, dynamic>? securityFeatures;
  final Map<String, dynamic>? propertyFeatures;
  final Map<String, dynamic>? badgeOptions;

  final VerifyStatus verifyStatus;
  final PropertyStatus propertyStatus;

  final String? landlordId;
  final String? verifiedByAdmin;

  PropertyModel({
    required this.id,
    required this.price,
    required this.bedroom,
    required this.bathroom,
    required this.squareArea,
    required this.address,
    required this.locationUrl,
    this.description,
    this.securityFeatures,
    this.propertyFeatures,
    this.badgeOptions,
    this.verifyStatus = VerifyStatus.defaultStatus,
    this.propertyStatus = PropertyStatus.available,
    this.landlordId,
    this.verifiedByAdmin,
  });

  // Create object from API/Database JSON
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      price: (json['price'] as num).toDouble(),
      bedroom: json['bedroom'] as int,
      bathroom: json['bathroom'] as int,
      squareArea: (json['square_area'] as num).toDouble(),
      address: json['address'] as String,
      locationUrl: json['location_url'] as String,
      description: json['description'] as String?,
      securityFeatures: json['security_features'] as Map<String, dynamic>?,
      propertyFeatures: json['property_features'] as Map<String, dynamic>?,
      badgeOptions: json['badge_options'] as Map<String, dynamic>?,
      verifyStatus: VerifyStatus.fromValue(json['verify_status']),
      propertyStatus: PropertyStatus.fromValue(json['property_status']),
      landlordId: json['landlord_id'] as String?,
      verifiedByAdmin: json['verified_by_admin'] as String?,
    );
  }
}
