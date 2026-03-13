import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

class PropertiesViewmodel extends AsyncNotifier<List<PropertyModel>> {
  @override
  Future<List<PropertyModel>> build() async {
    return ref.read(propertyRepositoryProvider).getProperties();
  }

  Future<void> loadProperties() async {
    state = await AsyncValue.guard(() async {
      return ref.read(propertyRepositoryProvider).getProperties();
    });
  }

  Future<void> loadLandlordProperties(String landlordId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return ref
          .read(propertyRepositoryProvider)
          .getPropertiesByLandlordId(landlordId);
    });
  }

  Future<void> updateProperty(PropertyModel propertyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(propertyRepositoryProvider).updateProperty(propertyId);
      return ref.read(propertyRepositoryProvider).getProperties();
    });
  }

  Future<void> removeProperty(String propertyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(propertyRepositoryProvider).deleteProperty(propertyId);
      return ref.read(propertyRepositoryProvider).getProperties();
    });
  }

  /// Remove a property from the current state (optimistic update)
  void removePropertyFromState(String propertyId) {
    state.whenData((properties) {
      state = AsyncValue.data(
        properties.where((p) => p.id != propertyId).toList(),
      );
    });
  }
}

final propertiesViewModelProvider =
    AsyncNotifierProvider<PropertiesViewmodel, List<PropertyModel>>(
      PropertiesViewmodel.new,
    );

final propertyViewModelProvider = FutureProvider.family<PropertyModel, String>((
  ref,
  id,
) async {
  final property = await ref
      .read(propertyRepositoryProvider)
      .getPropertyById(id);

  return property;
});
