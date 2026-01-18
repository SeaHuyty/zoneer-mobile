enum NotificationType {
  system('system'),
  propertyVerification('property_verification'),
  tenantVerification('tenant_verification'),
  landlordVerification('landlord_verification'),
  transaction('transaction'),
  inquiryResponse('inquiry_response'),
  reminder('reminder');

  final String value;

  const NotificationType(this.value);

  static NotificationType fromValue(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.system,
    );
  }
}
