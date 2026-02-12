import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum to define user profile types
enum ProfileType {
  landlord,
  tenant,
}

/// Provider to manage the current profile type
///
/// This allows switching between landlord and tenant profiles
/// Usage:
/// - Read: `ref.watch(profileTypeProvider)`
/// - Update: `ref.read(profileTypeProvider.notifier).switchProfile(ProfileType.tenant)`
final profileTypeProvider = NotifierProvider<ProfileTypeNotifier, ProfileType>(
  ProfileTypeNotifier.new,
);

/// Profile type notifier to manage profile state
class ProfileTypeNotifier extends Notifier<ProfileType> {
  @override
  ProfileType build() => ProfileType.tenant; // Initial state is tenant

  void switchProfile(ProfileType type) {
    state = type;
  }
  
  void switchToLandlord() {
    state = ProfileType.landlord;
  }
  
  void switchToTenant() {
    state = ProfileType.tenant;
  }
}
