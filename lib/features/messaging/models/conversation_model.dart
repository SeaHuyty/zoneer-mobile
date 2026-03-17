class ConversationModel {
  final String? id;
  final String inquiryId;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final String? createdAt;
  final String? lastMessageAt;
  final String? lastMessagePreview;

  const ConversationModel({
    this.id,
    required this.inquiryId,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String?,
      inquiryId: json['inquiry_id'] as String, 
      propertyId: json['property_id'] as String, 
      tenantId: json['tenant_id'] as String, 
      landlordId: json['landlord_id'] as String,
      lastMessageAt: json['last_message_at'] as String?,
      lastMessagePreview: json['last_message_preview'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'inquiry_id': inquiryId,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'last_message_at': lastMessageAt,
      'last_message_preview': lastMessagePreview
    };

    data.removeWhere((key, value) => value == null);
    return data;
  }
}
