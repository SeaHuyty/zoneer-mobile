enum MediaType {
  defaultType('default'),
  cover('cover');

  final String value;

  const MediaType(this.value);

  static MediaType fromValue(String? value) {
    return MediaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MediaType.defaultType,
    );
  }
}
