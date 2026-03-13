enum VerifyStatus {
  defaultStatus('rejected'),
  verified('verified'),
  pending('pending');

  final String value;

  const VerifyStatus(this.value);

  static VerifyStatus fromValue(String? value) {
    return VerifyStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VerifyStatus.pending,
    );
  }
}
