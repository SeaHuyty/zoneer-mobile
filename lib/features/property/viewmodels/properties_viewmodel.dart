import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

class PropertiesViewmodel extends AsyncNotifier<List<PropertyModel>> {
  @override
  Future<List<PropertyModel>> build() async => [];

  Future<void> loadProperties() async {
    state = const AsyncValue.loading();

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
}

final propertiesViewModelProvider =
    AsyncNotifierProvider<PropertiesViewmodel, List<PropertyModel>>(
      PropertiesViewmodel.new,
    );
