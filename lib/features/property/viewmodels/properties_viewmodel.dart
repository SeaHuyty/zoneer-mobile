import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

class PropertiesViewmodel extends AsyncNotifier<List<PropertyModel>> {
  @override
  Future<List<PropertyModel>> build() async {
    return ref.read(propertyRepositoryProvider).getProperties();
  }

  Future<void> loadProperties() async {
    // Only show loading spinner when there is no data yet.
    // When refreshing after an optimistic update keep existing markers visible.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

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

  /// Optimistically insert a property at the front of the list.
  void optimisticallyAdd(PropertyModel property) {
    state.whenData((properties) {
      state = AsyncValue.data([property, ...properties]);
    });
  }

  /// Optimistically replace a property with the same id in the list.
  void optimisticallyUpdate(PropertyModel property) {
    state.whenData((properties) {
      state = AsyncValue.data(
        properties.map((p) => p.id == property.id ? property : p).toList(),
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
