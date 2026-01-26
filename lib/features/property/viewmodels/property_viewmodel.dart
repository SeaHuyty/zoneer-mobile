import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

class PropertyViewmodel extends Notifier<AsyncValue<PropertyModel>> {
  @override
  AsyncValue<PropertyModel> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadPropertyById(String id) async {
    state = const AsyncValue.loading();
    try {
      final property = await ref
          .read(propertyRepositoryProvider)
          .getPropertyById(id);
      state = AsyncValue.data(property);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createProperty(PropertyModel property) async {
    try {
      await ref.read(propertyRepositoryProvider).createProperty(property);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final propertyViewmodelProvider =
    NotifierProvider<PropertyViewmodel, AsyncValue<PropertyModel>>(() {
      return PropertyViewmodel();
    });
