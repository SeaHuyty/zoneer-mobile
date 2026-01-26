class WishlistModel {
  final String userId;
  final String propertyId;
  final String? createdAt;

  const WishlistModel({
    required this.userId,
    required this.propertyId,
    this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'user_id': userId,
      'property_id': propertyId,
    };

    data.removeWhere((key, value) => value == null);
    return data;
  }
}
