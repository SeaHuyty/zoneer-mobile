enum VerifyStatus {
  defaultStatus('pending'),
  verified('verified'),
  rejected('rejected');

  final String value;

  const VerifyStatus(this.value);

  static VerifyStatus fromValue(String? value) {
    return VerifyStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VerifyStatus.defaultStatus,
    );
  }
}
