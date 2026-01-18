enum VerifyStatus {
  defaultStatus('default'),
  verified('verified'),
  pending('pending');

  final String value;

  const VerifyStatus(this.value);

  static VerifyStatus fromValue(String? value) {
    return VerifyStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VerifyStatus.defaultStatus,
    );
  }
}
